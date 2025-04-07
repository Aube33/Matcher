// ===== IMPORTS =====
const { getMessaging } = require("firebase-admin/messaging");
const db = require("../models");
const User = db.users;
const Chat = db.chat;
const Op = db.Sequelize.Op;
const { addMessageToChat, getMessagesForChat, setChatAsRead } = require("../functions/chat.functions");
const { UnknownChatError } = require("../config/errors.config");
const { messagePerIndex } = require("../config/chat.config");
// ==========



/**
 * Get all existing chats
 * @param {*} req - Request
 * @param {*} res - Response
 */
exports.getAllChat = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        const chatsData = await Chat.findAll();
        return res.status(200).send(chatsData);
    } catch (error) {
        console.log(error);
        return res.status(500).send({ message: "Interal server error" })
    }
};


/**
 * Get a specific chat from ID
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getChat = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    // Get targeted chat ID
    const chatId = req.params.chatId;

    try {

        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // Get targeted chat datas
        let chat = await Chat.findOne({ where: {
            [Op.and]: [
                { cid: chatId },
                { users: { [Op.contains]: [user.uid] }, },
            ]
        }});
    
        if (chat==null){
            throw new UnknownChatError(`Chat with ID ${chatId} not found`);
        }
    
        const messageLength = !req.query.m || req.query.m <= 0 || req.query.m >= messagePerIndex ? messagePerIndex : req.query.m;
        const messageIndex = !req.query.i || req.query.i <= 0 ? 0 : req.query.i;
        chat.dataValues.messages = await getMessagesForChat(chatId, messageIndex, messageLength);
        chat.dataValues.showMatchAnim = false;

        const lastMessage = chat.dataValues.messages[chat.dataValues.messages.length - 1];

        // If request is first from match to display Match animation on app
        if(chat.dataValues.messages.length == 0 && !chat.seen.includes(user.uid)){
            chat = await setChatAsRead(chat, user.uid, { reset: false });
            chat.dataValues.showMatchAnim = true;
        }
        // If request comes from other user and is not preview of lastMessage in chat list
        if (lastMessage && lastMessage.uid != user.uid && messageLength>1){
            chat = await setChatAsRead(chat, user.uid, { reset: false });
        }

        return res.status(200).send(chat);
    } catch (err) {
        if (err instanceof UnknownChatError){
            return res.status(404).send({ message: "Unknow chat" });
        }
        console.error(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};

/**
 * Permit to send a message to a targeted chat from ID
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.sendChatMessage = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    // Get targeted chat ID
    const chatId = req.params.chatId;
    if (req.body == null || req.body.content == null || req.body.content === "") {
        return res.status(400).send({ message: "Invalid message content" });
    }

    try {
        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user == null) {
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif === false) {
            res.status(401).send({ message: "Please verify your email first" });
            return;
        }

        // Get targeted chat datas
        let chat = await Chat.findOne({
            where: {
                [Op.and]: [
                    { cid: chatId },
                    { users: { [Op.contains]: [user.uid] }, },
                ]
            }
        })
        if (chat == null) {
            throw new UnknownChatError(`Chat with ID ${chatId} not found`);
        }

        // Add the new message to chat messages
        const newMessage = await addMessageToChat(chatId, user.uid, req.body.content);
        chat = await setChatAsRead(chat, user.uid, { reset: true });

        // Get all device tokens of users in the chat to send them notification
        const otherUsers = chat.users.filter(function (uid) {
            return uid !== req.uid;
        });

        let receiversTokens = [];
        for(const receiverUid of otherUsers){
            const otherUser = await User.findOne({ where: { uid: receiverUid } });
            if(otherUser!=null && otherUser.tokenNotifications!=null){
                receiversTokens.push(otherUser.tokenNotifications);
            }
        }

        let message = {
            data: {
                type: 'message',
                cid: chatId,
                senderName : user.name,
                sender: newMessage.uid,
                time: newMessage.created_at.toISOString(),
                content: newMessage.content,
            },
        };

        // Different methods if need to send notifications to one or multiple people
        if(receiversTokens.length==1 && receiversTokens[0] != null){
            message["token"] = receiversTokens[0];

            getMessaging().send(message)
            .then((response) => {
                console.log('Successfully sent message:', response);
            })
            .catch((error) => {
                console.log('Error sending message:', error);
            });
        } else if(receiversTokens.length>1){
            message["tokens"] = receiversTokens;
            
            getMessaging().sendEachForMulticast(message)
            .then((response) => {
                console.log(response.successCount + ' messages were sent successfully', response);
            })
            .catch((error) => {
                console.log('Error sending message:', error);
            });
        }

        return res.status(200).send(newMessage);
    } catch (err) {
        if(err instanceof UnknownChatError){
            return res.status(404).send({ message: "Unknown chat" });
        }
        console.error(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Permit to delete a chat from ID
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.deleteChat = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    // Get targeted chat ID
    const chatId = req.params.chatId;

    try {
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // Get targeted chat datas
        const chat = await Chat.findOne({ where: {
            [Op.and]: [
                { cid: chatId },
                { users: { [Op.contains]: [user.uid] }, },
            ]
        }})
    
        if (chat==null){
            throw new UnknownChatError(`Chat with ID ${chatId} not found`);
        }

        await chat.destroy();

        // Send silent notification to silent delete chat
        if(userConcerned.uid != user.uid && userConcerned.tokenNotifications != null){
            message = {
                data: {
                    type: 'deleteMatch',
                    userID: user.uid,
                    chatID: chat.cid
                },
                token: userConcerned.tokenNotifications
            };

            getMessaging().send(message)
            .then((response) => {
                console.log('Successfully sent silent notification for match deletion:', response);
            })
            .catch((error) => {
                console.log('Error sending silent notification for match deletion:', error);
            });
        }

        return res.status(200).send({ message: "Chat deletion successful" });
    } catch (err) {
        if(err instanceof UnknownChatError){
            return res.status(404).send({ message: "Unknown chat" });
        }
        console.error(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};