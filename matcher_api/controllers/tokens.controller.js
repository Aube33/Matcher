// ===== IMPORTS =====
const db = require("../models");
const User = db.users;
const Op = db.Sequelize.Op;
const { sha2, checkToken } = require("../functions/tokens.functions");
const { sendDailyLikesNotification } = require("../functions/notifs.functions");
const { getMessaging } = require("firebase-admin/messaging");
// ==========

// ===== REDIRECTS =====
const redirectValidateNewEmail = "https://matcher-app.fr/validation"
const redirectValidateChangeEmail = "https://matcher-app.fr/validation"
const redirectValiatePasswordChange = "https://matcher-app.fr/validation?resetPassword"
// ==========

/**
 * Permit to save notification token to User Request
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.saveNotificationToken = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    // Get token
    if (!req.body.token) {
        return res.status(400).send({message: "Invalid token"});
    }

    try {
        // Get User Request datas and set new token
        const user = await User.findOne({ where: { uid: req.uid } });
        if (!user) {
            return res.status(400).send({ message: "Invalid user" });
        }
    
        await user.update({ tokenNotifications: req.body.token });
        return res.status(200).send({ message: "Notif Token saved" });
    } catch (err) {
        return res.status(500).send({ message: "Internal server error" });
    }
}


/**
 * 
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.validateToken = async (req, res) => {
    // Get token
    const token = req.params.token || req.query.token;
  
    try {
        // Get user datas with token
        const user = await User.findOne({ where: { token: sha2(token) } });
        if (!user) {
            return res.status(401).send({ message: "Invalid token" });
        } else if (new Date(user.tokenTTL).getTime()<new Date().getTime()){
            return res.status(403).send({ message: "Expired token" })
        }
    
        // Verifiy token passed as param and change user token
        const isValidToken = checkToken(token, user.token);
        if (isValidToken){
            if (user.isVerif==false){ // Permit to verify new user email
                await user.update({ isVerif: true, token: null, tokenTTL: null })
                return res.redirect(302, redirectValidateNewEmail);
                
            } else if (user.isVerif==true && user.newEmail!=null){ // Permit to change user email to another
                await user.update({ email: user.newEmail, token: null, tokenTTL: null, newEmail: null });
                return res.redirect(302, redirectValidateChangeEmail);
        
            } else if (user.isVerif==true && user.newEmail==null){ // Permit to change user password
                //await user.update({ token: null, tokenTTL: null });
                // FAIRE OUVRIR L'APPLICATION POUR FORMULAIRE DE RESET
                //return res.status(200).send({ message: "Redirect password change" });
                return res.redirect(302, redirectValiatePasswordChange);
            }

            return res.status(200).send({ message: "Token successful" });
        } else {
            return res.status(401).send({ message: "Invalid token" });
        }
  
    } catch (err) {
      console.error(err);
      return res.status(500).send({ message: "Internal server error" });
    }
};



/**
 * Permit to test notification token
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.testNotificationToken = async (req, res) => {

    try {
        // Get User Request datas and set new token
        const user = await User.findOne({ where: { uid: "1f943ea8-1186-4a66-89be-b7fdde0bfa9b" } });
        if (!user) {
            return res.status(400).send({ message: "Invalid user" });
        }

        message = {
            data: {
                type: 'custom',
                title: "test",
                description: "test 2"
            },
            token: user.tokenNotifications
        };

        await getMessaging().send(message)

        return res.status(200).send({ message: "Notif sent" });
    } catch (err) {
        console.log(err);
        return res.status(500).send({ message: "Internal server error" });
    }
}