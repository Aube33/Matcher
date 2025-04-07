// ===== IMPORTS =====
const db = require("../models");
const { Op } = require('sequelize');
const Chat = db.chat;
const Message = db.message;
// ==========

/**
 * Set chat as read for user
 * @param {*} chat chat id
 * @param {*} uid user that made request
 * @param {*} options args of request
 * @returns 
 */
exports.setChatAsRead = async (chat, uid, options = {}) => {
    const { reset = false } = options;

    if (reset === true) {
        console.log("test 300")
        chat.seen = [];
        await chat.save();
    }

    try {
        console.log(typeof(chat.seen));
        if (!chat.seen.includes(uid)) {
            console.log("test 301")
            chat.seen.push(uid);
            await chat.changed("seen", true)
            await chat.save();
        }
        return chat;
    } catch (error) {
        console.error("Error updating chat's seen status:", error);
        throw error;
    }
    return chat;
};

/**
 * Get messages of chat from index and size
 * @param {*} chatId chat id
 * @param {*} index index to start
 * @param {*} size number of message to get
 * @returns 
 */
exports.getMessagesForChat = async (chatId, index, size) => {
    const messages = await Message.findAll({
        where: {
            cid: chatId,
        },
        order: [['created_at', 'DESC']],
        limit: size,
        offset: index,
    });

    return messages.length == 0 ? [] : messages.reverse();
}

/**
 * Add message with author and content to chat
 * @param {*} chatId chat id
 * @param {*} userId author of message
 * @param {*} content content of message
 * @returns 
 */
exports.addMessageToChat = async (chatId, userId, content) => {
    const message = await Message.create({
        cid: chatId,
        uid: userId,
        content: content,
    });

    return message;
};

/**
 * Create a new chat
 * @param {*} user1 - User 1 ID
 * @param {*} user2 - User 2 ID
 * @returns new chat data
 */
exports.createChat = async (user1, user2) => {
    try {
        const data = await Chat.create({users: [user1, user2]})
        return {data: data, err: null};
    } catch (e) {
        return {data: null, err: e};
    }
}
