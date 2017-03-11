module.exports = {
	entry: './src/index.js',

	output: {
		path: './public/javascripts',
		filename: 'index.js'
	},

	resolve: {
		modules: ['node_modules'],
		extensions: ['.js', '.elm']
	},

	module: {
		loaders: [
			{
				test: /\.elm$/,
				exclude: [/elm_stuff/, /node_modules/],
				loader: 'elm-webpack-loader?cwd=.'
			}
		],

		noParse: /\.elm$/
	}
};