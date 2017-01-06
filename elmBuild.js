const execFile = require('child_process').execFile;
const chokidar = require('chokidar');

function setupElmBuild(src, dist) {
	const watcher = chokidar.watch(src, {
		ignored: /(^|[\/\\])\../,
		persistent: true
	});

	watcher.on('change', function (path, stats) {
		console.log('FILE CHANGED');
		console.log('stats', stats);
		console.log('path', path);

		//elm-make src/Main.elm --output public/javascripts/app.js
		execFile('./node_modules/elm/Elm-Platform/0.18.0/.cabal-sandbox/bin/elm-make', [src, '--output', dist], (error, stdout, stderr) => {
			if (error) {
				console.log(error);
			}
			console.log(stdout);
		});
	});
}

module.exports = setupElmBuild;
