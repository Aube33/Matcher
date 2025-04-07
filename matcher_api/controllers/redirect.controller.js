// ===== IMPORTS =====
const db = require("../models");
const User = db.users;
const Op = db.Sequelize.Op;
const { getMessaging } = require("firebase-admin/messaging");
// ==========


/**
 * Permit to test notification token
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.resetpasswordRedirect = async (req, res) => {
    try {
        const token = req.query.token;

        if (!token) {
            return res.status(400).send('Token is required');
        }

        const redirectUrl = `matcher://resetpassword?token=${encodeURIComponent(token)}`;

        return res.redirect(302, redirectUrl);
    } catch (err) {
        console.log(err);
        return res.status(500).send({ message: "Internal server error" });
    }
}