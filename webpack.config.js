var webpack = require('webpack');
var path = require('path');
var WebpackCleanupPlugin = require('webpack-cleanup-plugin');
var UglifyJsPlugin = require('uglifyjs-webpack-plugin');
var HtmlWebpackPlugin = require('html-webpack-plugin');

module.exports = {
  entry: {
    app: './src/app.js',
    bicycle: './src/bicycle.js',
    beer: './src/beer.js',
    vendor: [
      'mapbox-gl/dist/mapbox-gl.js'
    ]
  },
  output: {
    path: path.join(__dirname, 'demo'),
    filename: 'js/[name].[chunkhash].js',
  },
  resolve: {
    extensions: ['.js']
  },
  module: {
    noParse: [
      /mapbox-gl\/dist\/mapbox-gl.js/
    ],
    rules: [
      {
        test: /.js?$/,
        use: ['babel-loader'],
        exclude: /node_modules/,
      }
    ]
  },
  plugins: [
    new webpack.NoEmitOnErrorsPlugin(),
    new webpack.optimize.CommonsChunkPlugin({name: 'vendor'}),
    new WebpackCleanupPlugin({exclude: [
        "doc/**/*",
        "logo/**/*",
        "sprites/**/*",
        "styles/**/**",
        "favicon.ico",
        "manifest.json",
        "robots.txt",
        "sw.js"
    ]}),
    // new UglifyJsPlugin(),
    new HtmlWebpackPlugin({
      template: './src/template.html',
      title: 'Žemėlapis',
      chunksSortMode: 'manual',
      chunks: ['vendor', 'app']
    }),
    new HtmlWebpackPlugin({
      template: './src/template.html',
      filename: 'bicycle.html',
      title: 'Dviračių žemėlapis',
      chunksSortMode: 'manual',
      chunks: ['vendor', 'bicycle', 'app']
    }),
    new HtmlWebpackPlugin({
      template: './src/template.html',
      filename: 'beer.html',
      title: 'Craft alaus žemėlapis',
      chunksSortMode: 'manual',
      chunks: ['vendor', 'beer', 'app']
    })
  ]
};