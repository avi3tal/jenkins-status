const express = require('express');
const router = express.Router();
const jenkins = require('jenkins')({ baseUrl: 'http://admin:!Q@W3e4r@192.168.200.137:8080', crumbIssuer: true });

/* GET users listing. */
router.get('/', function(req, res, next) {

	let b = [
		{name: "master-1111"},
		{name: "RC-3333"},
		{name: "master-2222"},
		{name: "master-4444"}
	];

	res.send(b);

	// jenkins.job.get("Build", (err, data) => {
	// 	if (err) throw err;
	//
	// 	res.send(data);
	// });
});

router.get('/:id', function(req, res, next) {
	let j = {
		displayName: "master-1111",
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