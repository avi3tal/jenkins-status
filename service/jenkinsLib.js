const config  = require("../config.json");
const jenkins = require('jenkins')({ baseUrl: config.baseUrl, crumbIssuer: true});

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
		return new Promise(function (resolve, reject) {
			jenkins.job.get("Build", {
				depth: 1,
				tree: "builds[id,displayName,number,building,timestamp,result]"
			}, (err, data) => {
				if (err) { reject(err); }
				else {
					let builds = handleBuilds(data.builds, limit);
					resolve(builds);
				}
			});
		});
	}
}

function listJobsByBuild(number) {
	if(typeof number === 'undefined'){
		throw new Error('number must be defined!');
	}

	if (!config.realEnv) {
		return new Promise(function (resolve, reject) {
			let jobs = require('../mocks/jobs.json');
			resolve(jobs);
		});
	} else {
		return new Promise(function (resolve, reject) {
			jenkins.build.get("Build", number, {depth: 2, tree: "building,duration,result,timestamp"}, (err, data) => {
				if (err) {
					reject(err);
				}
				else {
					resolve(data);
				}
			});
		});
	}
}


module.exports.listBuilds = listBuilds;
module.exports.listJobsByBuild = listJobsByBuild;