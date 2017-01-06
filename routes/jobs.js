var express = require('express');
var router = express.Router();
var jenkins = require('jenkins')({ baseUrl: 'http://admin:!Q@W3e4r@192.168.200.137:8080', crumbIssuer: true });

/* GET users listing. */
router.get('/', function(req, res, next) {
	jenkins.job.list((err, data) => {
		if (err) throw err;
		res.send(data);
	});
});

router.get('/:id', function(req, res, next) {
	jenkins.job.get(req.params.id, (err, data) => {
		if (err) throw err;
		res.send(data);
	});
});

module.exports = router;