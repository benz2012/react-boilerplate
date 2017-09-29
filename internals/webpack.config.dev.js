const path = require('path')
const HtmlWebpackPlugin = require('html-webpack-plugin')

module.exports = {
  entry: {
    app: path.resolve(process.cwd(), './src/js/index.js')
  },
  output: {
    path: path.resolve(process.cwd(), 'public'),
    filename: 'bundle.dev.js'
  },
  module: {
    rules: [
      {
        test: /\.jsx?$/,
        exclude: /(node_modules)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['env', 'react'],
            cacheDirectory: true
          }
        }
      }
    ]
  },
  plugins: [
    new HtmlWebpackPlugin({
      template: './src/index.html',
      inject: true,
    })
  ],
  resolve: {
    extensions: ['.js', '.jsx']
  },
}
