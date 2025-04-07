// ===== IMPORTS =====
const { ValidationErrorItem } = require("sequelize");
const { verifyToken, checkUserAgent } = require("../controllers/middleware.controller.js");
// ==========



module.exports = app => {
    const chat = require("../controllers/chat.controller.js");
    var router = require("express").Router();

    router.get("/all/", checkUserAgent, verifyToken, chat.getAllChat);
    router.delete("/:chatId", checkUserAgent, verifyToken, chat.deleteChat);
    router.get("/:chatId", checkUserAgent, verifyToken, chat.getChat);
    router.post("/:chatId", checkUserAgent, verifyToken, chat.sendChatMessage);
  
    app.use('/api/chat', router);
  };