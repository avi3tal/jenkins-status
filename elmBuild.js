const execFile = require('child_process').execFile;
const chokidar = require('chokidar');

function setupElmBuild(watchFiles, mainFile, dist) {
	const watcher = chokidar.watch(watchFiles, {
		ignored: /(^|[\/\\])\../,
		persistent: true
	});

	watcher.on('change', function (path, stats) {
		console.log('FILE CHANGED');
		console.log('file', path);

		execFile('./node_modules/elm/Elm-Platform/0.18.0/.cabal-sandbox/bin/elm-make', [mainFile, '--output', dist], (error, stdout, stderr) => {
			if (error) {
				console.log(error);
			}
			console.log(stdout);
		});
	});
}

module.exports = setupElmBuild;
