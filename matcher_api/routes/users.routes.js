// ===== IMPORTS =====
const { validateVerif } = require("../functions/jwt.functions.js");
const { checkUserAgent, verifyToken, fileFilterMiddleware } = require("../controllers/middleware.controller.js");

const multer = require('multer');
const { maxImageFileSize } = require("../config/users.config");
const multerUpload = multer({ limits: { fileSize: maxImageFileSize } });
// ==========



module.exports = app => {
    const users = require("../controllers/users.controller.js");
    var router = require("express").Router();
  
    // = AUTHENTICATION =
    router.post("/signup", checkUserAgent, users.createUser);
    router.post("/login", checkUserAgent, users.loginUser);
    router.get("/exist/:email", users.checkEmail)
    router.post("/logout", checkUserAgent, verifyToken, users.logoutUser);
    router.get("/authorize", checkUserAgent, verifyToken, validateVerif);

    router.post("/reset-password", checkUserAgent, users.resetPassword);
    router.post("/reset-password/:resetToken", checkUserAgent, users.updatePassword);

    router.post("/change-email", checkUserAgent, verifyToken, users.changeEmail);
    router.get("/change-email/:changeToken", users.updateEmail);


    // = PROFILE =
    router.post("/edit", checkUserAgent, verifyToken, users.editUser);

    router.get("/hobbies", checkUserAgent, users.getAllHobbies);
    router.get("/hobbies/:hobbyName", checkUserAgent, users.getHobby);

    router.get("/genders", checkUserAgent, users.getAllGender);
    router.get("/genders/:genderID", checkUserAgent, users.getGender);

    router.get("/relations", checkUserAgent, users.getAllRelations);
    router.get("/relations/:relID", checkUserAgent, users.getRelationShip);

    // = CHAT =
    router.get("/chats", checkUserAgent, verifyToken, users.getUserChats);


    // = IMAGES =
    router.post("/images/profile", multerUpload.array("images"), checkUserAgent, fileFilterMiddleware, verifyToken, users.postUserProfileImage);
    router.get("/images/:uid", checkUserAgent, verifyToken, users.getUserImages);
    router.post("/images", multerUpload.array("images"), checkUserAgent, fileFilterMiddleware, verifyToken, users.postUserImages);


    // = BASICS =
    //router.get("/", users.getAllUsers);
    router.get("/:uid", checkUserAgent, verifyToken, users.getUser);
    router.delete("/", checkUserAgent, verifyToken, users.deleteUser);

    app.use('/api/users', router);
  };