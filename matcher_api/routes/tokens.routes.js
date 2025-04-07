// ===== IMPORTS =====
const { verifyToken, checkUserAgent } = require("../controllers/middleware.controller.js");
// ==========



module.exports = app => {
    const tokens = require("../controllers/tokens.controller.js");
    var router = require("express").Router();

    router.get("/validate/:token", tokens.validateToken);
    router.get("/notifications/test", tokens.testNotificationToken);
    router.post("/notifications", checkUserAgent, verifyToken, tokens.saveNotificationToken);
  
    app.use('/api/tokens', router);
  };