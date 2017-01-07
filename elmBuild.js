const execFile = require('child_process').execFile;
const chokidar = require('chokidar');

function runElmMake(mainFile, dist) {
	execFile(
		'elm-make',
		[mainFile, '--output', dist], (error, stdout, stderr) => {
		if (error) {
			console.log(error);
		} else {
			console.log(stdout);
		}
	});
}

function setupElmBuild(watchFiles, mainFile, dist) {
	const watcher = chokidar.watch(watchFiles, {
		ignored: /(^|[\/\\])\../,
		persistent: true
	});

	watcher.on('change', function (path, stats) {
		console.log('FILE CHANGED');
		console.log('file', path);

		runElmMake(mainFile, dist);
	});

	runElmMake(mainFile, dist);
}

module.exports = setupElmBuild;
