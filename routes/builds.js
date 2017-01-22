const express = require('express');
const router = express.Router();
const jenkinsService = require("../service/jenkinsLib");


/* GET users listing. */
router.get('/', function(req, res, next) {
	jenkinsService.listBuilds(10).then(
		builds => res.send(builds),
		err => next(err)
	);
});

router.get('/:id', function(req, res, next) {
	jenkinsService.listJobsByBuild(parseInt(req.params.id, 10)).then(
		jobs => res.send(jobs),
		err => next(err)
	);
});

router.get('/downstream/:jobName/:buildId', function(req, res, next) {
	jenkinsService.getDownstreamProjects(req.params.jobName, parseInt(req.params.buildId, 10)).then(
		jobs => res.send(jobs),
		err => next(err)
	);
});


module.exports = router;