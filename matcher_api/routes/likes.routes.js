// ===== IMPORTS =====
const { verifyToken, checkUserAgent } = require("../controllers/middleware.controller.js");
// ==========



module.exports = app => {
    const likes = require("../controllers/likes.controller.js");
    var router = require("express").Router();

    router.get("/", checkUserAgent, verifyToken, likes.getLikes);
    router.post("/send/:userTarget", checkUserAgent, verifyToken, likes.sendLike);

    router.delete("/reception/:userTarget", checkUserAgent, verifyToken, likes.deleteLikeReceived);

    router.get("/reception", checkUserAgent, verifyToken, likes.getLikesReception);
    router.get("/sent", checkUserAgent, verifyToken, likes.getLikesGiven);

    router.get("/daily", checkUserAgent, verifyToken, likes.getDailyLikes);
    router.post("/daily", checkUserAgent, verifyToken, likes.claimDailyLikes);
  
    app.use('/api/likes', router);
  };