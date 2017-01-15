const express = require('express');
const router = express.Router();
const config  = require('../config.json');
const jenkins = require("../service/jenkinsLib");


/* GET users listing. */
router.get('/', function(req, res, next) {
	jenkins.listBuilds(10).then(
		builds => res.send(builds),
		err => next(err)
	);
});

router.get('/:id', function(req, res, next) {
	jenkins.listJobsByBuild(req.params.id).then(
		jobs => res.send(jobs),
		err => next(err)
	);
});

module.exports = router;