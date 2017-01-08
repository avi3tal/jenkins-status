const express = require('express');
const router = express.Router();
const config  = require('../config.json');
const jenkins = require("../service/jenkinsLib");


/* GET users listing. */
router.get('/', function(req, res, next) {

	// TODO remove if condition
	// allow working only with real environments
	// or using External Mocker
	if(!config.realEnv)
		res.send([
			{name: "master-1111", number: 1111},
			{name: "RC-3333", number: 3333},
			{name: "master-2222", number: 2222},
			{name: "master-4444", number: 4444}
		]);
	else
		jenkins.listBuilds(10, (item) => {
			res.send(item)
		});
});

router.get('/:id', function(req, res, next) {
	jenkins.listJobsByBuild(req.params.id);

	let j = {
		displayName: req.params.id,
		jobs: [
			{
				name: "Build",
				color: "red",
				timestamp: 1483693575274,
				downstream: [],
				building: false
			},
			{
				name: "Smoke",
			 	color: "blue",
				building: false,
				timestamp: 1483693575274,
				downstream: [
					{
						name: "TestFast",
						color: "blue",
						building: false,
						timestamp: 1483693575274,
						downstream: []
					},
					{
						name: "RunE2E",
						color: "blue",
						building: false,
						timestamp: 1483693575274,
						downstream: [
							{
								name: "Migration-Server-Upgrade",
								color: "blue",
								building: false,
								timestamp: 1483693575274,
								downstream: []
							},
							{
								name: "testkit",
								color: "red",
								building: false,
								timestamp: 1483693575274,
								downstream: []
							}
						]
					}
				]
			},
			{
				name: "PostSmoke",
				color: "red",
				building: true,
				timestamp: 1483693575274,
				downstream: [
					{
						name: "DployAndTest",
						color: "blue",
						building: true,
						timestamp: 1483693575274,
						downstream: []
					},
					{
						name: "RunE2E",
						color: "blue",
						building: false,
						timestamp: 1483693575274,
						downstream: [
							{
								name: "BuildInstance",
								color: "blue",
								building: false,
								timestamp: 1483693575274,
								downstream: []
							},
							{
								name: "testkit",
								color: "red",
								building: false,
								timestamp: 1483693575274,
								downstream: []
							},
							{
								name: "testR",
								color: "blue",
								building: false,
								timestamp: 1483693575274,
								downstream: []
							}
						]
					}
				]

			},
			{
				name: "Nightly",
				color: "red",
				building: false,
				timestamp: 1483693575274,
				downstream: [
					{
						name: "Stress",
						color: "blue",
						building: false,
						timestamp: 1483693575274,
						downstream: [
							{
								name: "RunE2E",
								color: "blue",
								building: false,
								timestamp: 1483693575274,
								downstream: [
									{
										name: "BuildInstance",
										color: "blue",
										building: false,
										timestamp: 1483693575274,
										downstream: []
									},
									{
										name: "testkit",
										color: "red",
										building: false,
										timestamp: 1483693575274,
										downstream: []
									}
								]
							}
						]
					}
				]
			}
		]
	};
	res.send(j);

	// jenkins.job.get("Build", (err, data) => {
	// 	if (err) throw err;
	//
	// 	res.send(data);
	// });
});

module.exports = router;