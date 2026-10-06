const path = require("path");

module.exports = {
  mode: "development",
  entry: "./src/index.js",
  output: {
    path: path.resolve(__dirname, "dist"),
    filename: "bundle.js",
    clean: true
  },
  experiments: {
    css: true
  },
  module: {
    rules: [
      { test: /\.css$/, type: "css" }
    ]
  },
  devServer: {
    host: "0.0.0.0",
    port: 3000,
    static: {
      directory: path.resolve(__dirname, "public")
    }
  }
};
