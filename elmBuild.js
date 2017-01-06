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
		execFile('elm-make', [src, '--output', dist], (error, stdout, stderr) => {
			if (error) {
				throw error;
			}
			console.log(stdout);
		});
	});
}

module.exports = setupElmBuild;
