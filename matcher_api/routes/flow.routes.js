// ===== IMPORTS =====
const { verifyToken, checkUserAgent } = require("../controllers/middleware.controller.js");
// ==========



module.exports = app => {
    const flow = require("../controllers/flow.controller.js");
    var router = require("express").Router();

    router.get("/", checkUserAgent, verifyToken, flow.getFlow);
  
    app.use('/api/flow', router);
  };