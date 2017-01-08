const config  = require("../config.json");
const jenkins = require('jenkins')({ baseUrl: config.baseUrl, crumbIssuer: true});

function listBuilds(limit, callback){
	if (typeof limit === 'undefined') {
		limit = 10;
	}
	jenkins.job.get("Build", {depth: 1, tree: "builds[displayName,number]"}, (err, data) => {
		if (err) next(err);

		callback(data.builds.filter(k => {
			return k.displayName.startsWith("RC-") || k.displayName.startsWith("master-")
		}).slice(0, limit).map(k => {
			console.log(k);
			return {name: k.displayName, number: k.number}
		}));
	});
}

function listJobsByBuild(number, callback){
	if(typeof number === 'undefined'){
		throw new Error('number must be defined!');
	}
	jenkins.build.get("Build", 4, {depth: 2, tree: "building,duration,result,timestamp"}, (err, data) => {
		// if (err) next(err);
		console.log(data)
	});
}


module.exports.listBuilds = listBuilds;
module.exports.listJobsByBuild = listJobsByBuild;