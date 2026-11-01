let app;
let loadError = null;

try {
  app = require('../index.js');
} catch (err) {
  loadError = {
    message: err.message,
    stack: err.stack,
  };
}

module.exports = (req, res) => {
  if (loadError) {
    res.statusCode = 500;
    res.setHeader('Content-Type', 'application/json');
    return res.end(
      JSON.stringify({
        status: 'error',
        source: 'api/index.js wrapper',
        error: loadError.message,
        stack: loadError.stack,
      }, null, 2)
    );
  }
  return app(req, res);
};
