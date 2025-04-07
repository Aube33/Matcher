// ===== IMPORTS =====
const { verifyToken } = require("../controllers/middleware.controller.js");
// ==========



module.exports = app => {
    const redirect = require("../controllers/redirect.controller.js");
    var router = require("express").Router();

    router.get("/resetpassword", redirect.resetpasswordRedirect);

    app.use('/api/redirect', router);
  };