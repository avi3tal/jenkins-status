const _ = require('lodash');
const config  = require("../config.json");
const jenkins = require('jenkins')({ baseUrl: config.baseUrl, crumbIssuer: true, promisify: true});

const rootProjectName = config.rootProjectName;

function handleBuilds(builds, limit) {
	return builds
		.filter(build =>
			build.displayName.startsWith("RC-") || build.displayName.startsWith("master-")
		)
		.slice(0, limit);
}

function listBuilds(limit) {
	if (typeof limit === 'undefined') {
		limit = 10;
	}

	if (!config.realEnv) {
		return new Promise(function (resolve, reject) {
			let data = require('../mocks/builds.json');
			let builds = handleBuilds(data.builds, limit);
			resolve(builds);
		});
	} else {
		return jenkins.job.get(rootProjectName, {
			depth: 1,
			tree: "builds[id,displayName,description,number,building,duration,timestamp,result,url]"
		})
			.then((data) => handleBuilds(data.builds, limit))
			.then(builds => builds.map(build => Object.assign({}, build, { projectName: rootProjectName })));
	}
}

function getDownstreamProjects(projectName, upstreamBuildNumber) {
	if (typeof projectName === 'undefined') {
		throw new Error('projectName must be defined!');
	}

	if (!config.realEnv) {
		return new Promise(function (resolve, reject) {
			let jobs = require('../mocks/jobs.json');
			resolve(jobs);
		});
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
								tree: 'id,building,description,displayName,duration,result,timestamp,url,subBuilds[abort,jobName,result,buildNumber]'
							})
								.then(build => Object.assign({}, build, {projectName: projectName}))
						}))
					});
			})
			.then(builds => {
				let buildsWithData =_.compact(builds);
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
	if(typeof buildNumber === 'undefined'){
		throw new Error('buildNumber must be defined!');
	}

	if (!config.realEnv) {
		return new Promise(function (resolve, reject) {
			let jobs = require('../mocks/jobs.json');
			resolve(jobs);
		});
	} else {
		return getDownstreamProjects(rootProjectName, buildNumber);
			// .catch(err => console.log('getDownstreamProjects error', err));

		// return jenkins.build.get("Build", buildNumber, {
		// 	depth: 2,
		// 	tree: "id,displayName,building,duration,result,timestamp"
		// });
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
