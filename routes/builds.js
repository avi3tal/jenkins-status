const express = require('express');
const router = express.Router();
const jenkinsService = require("../service/jenkinsLib");


/* GET users listing. */
router.get('/', async function(req, res, next) {
	try {
		let builds = await jenkinsService.listBuilds(10);
		res.send(builds);
	} catch (err) {
		next(err);
	}
});

router.get('/:id', async function(req, res, next) {
	try {
		let buildId = parseInt(req.params.id, 10);
		let jobs = await jenkinsService.listJobsByBuild(buildId);
		res.send(jobs);
	} catch (err) {
		next(err);
	}
});

router.get('/downstream/:jobName/:buildId', async function(req, res, next) {
	try {
		let { buildId, jobName } = req.params;
		buildId = parseInt(buildId, 10);
		let jobs = await jenkinsService.getDownstreamProjects(jobName, buildId);
		res.send(jobs);
	} catch (err) {
		next(err);
	}
});


module.exports = router;