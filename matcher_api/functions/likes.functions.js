// ===== IMPORTS =====
const db = require("../models");
const Likes = db.likes;
const { maxLikes } = require("../config/likes.config");
// ==========

/**
 * Check if user has claimed daily likes
 * @param {*} userId user id
 * @returns 
 */
exports.hasUserClaimDailyLikes = async (userId) => {
    const count = await Likes.count({
        where: { uid: userId }
    });
    return count > 0;
}

/**
 * Add user to likes database
 * @param {*} userId user id
 * @param {*} amount amount of like to set
 * @returns 
 */
exports.createUserLikes = async (userId, amount = null) => {
    let userData = {
        uid: userId
    };

    if (amount != null){
        userData.amount = amount
    }
    return Likes.create(userData);
}

/**
 * Get user data in likes database
 * @param {*} userId user id
 * @returns 
 */
exports.getUserLikes = async (userId) => {
    let userLikes = await Likes.findOne({ where: { uid: userId } });
    return userLikes;
}

/**
 * Add likes to user
 * @param {*} userId user id
 * @param {*} amount amount to add
 * @returns 
 */
exports.addUserLikes = async (userId, amount) => {
    let userLikes = await exports.getUserLikes(userId);
    if (!userLikes) {
        userLikes = await exports.createUserLikes(userId);
    }
    userLikes.amount = Math.min(userLikes.amount + amount, maxLikes);
    userLikes.changed("amount", true);
    await userLikes.save();
    return userLikes;
}

/**
 * Remove likes to user
 * @param {*} userId user id
 * @param {*} amount amount to remove
 * @returns 
 */
exports.removeUserLikes = async (userId, amount) => {
    const userLikes = await exports.getUserLikes(userId);
    if (userLikes) {
        userLikes.amount = Math.max(userLikes.amount - amount, 0);
        userLikes.changed("amount", true);
        await userLikes.save();
    }
    return userLikes.amount || 0;
}