const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function (app) {
  app.use(
    "/api",
    createProxyMiddleware({
      target: process.env.REACT_APP_BASE_URL || "http://localhost:4066",
      changeOrigin: true,
      pathRewrite: {
        "^/api": "/api", // rewrite path
      },
    })
  );
};
