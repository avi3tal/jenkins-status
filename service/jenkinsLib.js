const config  = require("../config.json");
const jenkins = require('jenkins')({ baseUrl: config.baseUrl, crumbIssuer: true});

function listBuilds(limit, callback){
	if (typeof limit === 'undefined') {
		limit = 10;
	}
	jenkins.job.get("Build", {depth: 1, tree: "builds[displayName,number]"}, (err, data) => {
		if (err) next(err);

		callback(data.builds.slice(0, limit).map(k => {
			console.log(k);
			return {name: k.displayName, number: k.number}
		}));
	});
}


module.exports.listBuilds = listBuilds;