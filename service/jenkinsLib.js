const _ = require('lodash');
const config = require('../config');
const jenkins = require('jenkins')({ baseUrl: config.baseUrl, crumbIssuer: true, promisify: true});

const rootProjectName = config.rootProjectName;
const isProd = config.env === 'PROD';

function handleBuilds(builds, limit) {
	return builds
		.filter(build => _.some(config.buildPrefixes, prefix => build.displayName.startsWith(prefix)))
		.slice(0, limit);
}

async function listBuilds(limit) {
	if (typeof limit === 'undefined') {
		limit = config.rootProjectsLimit;
	}

	if (!isProd) {
		let data = require('../mocks/builds.json');
		let builds = handleBuilds(data.builds, limit);
		return Promise.resolve(builds);
	} else {
		let response = await jenkins.job.get(rootProjectName, {
			depth: 1,
			tree: "builds[id,displayName,description,number,building,duration,timestamp,result,url]"
		});
		let normalizedBuilds = handleBuilds(response.builds, limit)
			.map(build => Object.assign({}, build, { projectName: rootProjectName }));
		return Promise.resolve(normalizedBuilds);
	}
}

function getDownstreamProjects(projectName, upstreamBuildNumber) {
	if (typeof projectName === 'undefined') {
		throw new Error('projectName must be defined!');
	}

	if (!isProd) {
		let jobs = require('../mocks/jobs.json');
		return Promise.resolve(jobs);
	} else {
		return jenkins.job.get(projectName, {
			tree: "downstreamProjects[name]"
		})
			.then(data => data.downstreamProjects.map(downstreamProject => downstreamProject.name))
			.then(downstreamProjects => {
				let requestPromises = downstreamProjects.map(downstreamProject =>
					jenkins.job.get(downstreamProject, {
						depth: 1,
						tree: 'name,builds[id,actions[causes[upstreamBuild,upstreamProject]]]'
					})
						.then((data) => {
							let foundBuild = _.find(data.builds, (build) =>
								_.find(build.actions, (action) =>
									_.find(action.causes, (cause) =>
										cause !== undefined
											? cause.upstreamBuild === upstreamBuildNumber
											: false
									)
								)
							);
							return foundBuild
								? { name: data.name, id: foundBuild.id }
								: undefined
						})
				);
				return Promise.all(requestPromises)
					.then(builds => {
						return Promise.all(builds.map(build => {
							if (build === undefined) { return undefined; }
							let projectName = build.name;
							return jenkins.build.get(projectName, build.id, {
								tree: 'id,building,description,displayName,duration,result,timestamp,url,subBuilds[abort,jobName,result,buildNumber],actions[failCount,skipCount,totalCount,causes[upstreamBuild,upstreamProject],triggeredBuilds[*]]'
							})
								.then(build => {
									let results = _.find(build.actions, { '_class': 'hudson.tasks.junit.TestResultAction' });
									let causes = _.find(build.actions, { '_class': 'hudson.model.CauseAction' });
									let parent = _.find(causes.causes, { '_class': 'hudson.model.Cause$UpstreamCause' });
									let triggeredBuildsAction = _.find(build.actions, { '_class': 'hudson.plugins.parameterizedtrigger.BuildInfoExporterAction'});
									console.log('projectName', projectName, build.id);
									console.log('displayName', build.displayName);
									let build_ = Object.assign({}, _.omit(build, 'actions'), {projectName: projectName, results: results, parent: parent});
									if (triggeredBuildsAction && triggeredBuildsAction.triggeredBuilds.length > 0) {
										return Promise.all(triggeredBuildsAction.triggeredBuilds.map(triggeredBuild => {
											let projectName_ = _.trim(triggeredBuild.fullDisplayName.replace(triggeredBuild.displayName, ''));
											return jenkins.build.get(projectName_, parseInt(triggeredBuild.id, 10), {
												tree: 'id,building,description,displayName,duration,result,timestamp,url,subBuilds[abort,jobName,result,buildNumber],actions[failCount,skipCount,totalCount,causes[upstreamBuild,upstreamProject],triggeredBuilds[*]]'
											})
												.then((build) => {
													let results = _.find(build.actions, { '_class': 'hudson.tasks.junit.TestResultAction' });
													let causes = _.find(build.actions, { '_class': 'hudson.model.CauseAction' });
													let parent = _.find(causes.causes, { '_class': 'hudson.model.Cause$UpstreamCause' });
													return Object.assign({}, _.omit(build, 'actions'), {projectName: projectName_, results: results, parent: parent});
												});
										})).then((response) => _.flatten(_.concat([build_], response)));
									}
									return build_;
								})
						}))
					});
			})
			.then(builds => {
				let buildsWithData =_.compact(_.flatten(builds));
				if (buildsWithData.length > 0) {
					return Promise.all(buildsWithData.map(buildWithData =>
						getDownstreamProjects(buildWithData.projectName, parseInt(buildWithData.id, 10))
					))
						.then(nextBuilds => _.flatten(_.concat(buildsWithData, nextBuilds)));
				} else {
					return buildsWithData;
				}
			});
	}
}

function listJobsByBuild(buildNumber) {
	if(typeof buildNumber === 'undefined') {
		throw new Error('buildNumber must be defined!');
	}

	if (!isProd) {
		let jobs = require('../mocks/jobs.json');
		return Promise.resolve(jobs);
	} else {
		return getDownstreamProjects(rootProjectName, buildNumber);
	}
}

module.exports.listBuilds = listBuilds;
module.exports.listJobsByBuild = listJobsByBuild;
module.exports.getDownstreamProjects = getDownstreamProjects;


/*
 order

 1. handleBuilds()
 2. on build click (example: 5313):
 	2.1 /job/Build/api/json?tree=downstreamProjects[name] (example: brings 'Smoke')
 	2.2 determine downstream project id for chosen Build
 		2.2.1 job/Smoke/api/json?depth=1&tree=builds[id,actions[causes[upstreamBuild,upstreamProject]]]
 		2.2.2 from 'builds' find 'causes' where 'upstreamBuild' is chosen build id (ex: 5313)
		2.2.3 take its 'id'
	2.3 bring builds info: /job/Smoke/70/api/json?depth=0&tree=id,building,description,displayName,duration,result,timestamp,url,subBuilds[abort,jobName,result,buildNumber]
	2.4 on current build click (ex: Smoke, 70) bring it's sub projects and do as in 2.1 forward

*/
