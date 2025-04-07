// ===== IMPORTS =====
const { getMessaging } = require("firebase-admin/messaging");
const db = require("../models");
const { createChat } = require("../functions/chat.functions");
const { createUserLikes, getUserLikes, removeUserLikes, hasUserClaimDailyLikes } = require("../functions/likes.functions");
const User = db.users;
const Flow = db.flow;
const Op = db.Sequelize.Op;
// ==========



/**
 * Get received likes of User Request
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getLikesReception = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas and send likes received
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }
    
        return res.status(200).send(user.likesReceived)
    } catch (err) {
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Get likes given by User Request
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getLikesGiven = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas and send likes given
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        return res.status(200).send(user.likesGiven)
    } catch (err) {
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Get likes number of User Request
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getLikes = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas and send likes number
        const user = await User.findOne({ where: { uid: req.uid } });
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        let likesAmount = 0;
        if (await hasUserClaimDailyLikes(req.uid)){
            const userLikes = await getUserLikes(req.uid);
            likesAmount = userLikes.amount;
        }
    
        return res.status(200).send({likes: likesAmount})
    } catch (err) {
        console.error(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Function to send like to user
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.sendLike = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    const userTargetUid = req.params.userTarget;

    try {
        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        if (user.likesGiven[userTargetUid]!=null){
            return res.status(403).send({ message: "Already liked"});
        }

        // Get targeted user datas
        const userTarget = await User.findOne({ where: { uid: userTargetUid } })
        if (userTarget==null){
            return res.status(404).send({ message: "Unknow user target" });
        }

        // Verify if user like the correct targeted user at index in user Flow
        const userFlow = await Flow.findOne({ where: { uid: req.uid } })
        if (userFlow!=null 
            && user.likesReceived[userTargetUid]==null 
            //&& userFlow.index <= userFlow.recommendation.length-1 ????
            && userFlow.recommendation != null && !userFlow.recommendation.some(item => item.uid === userTargetUid)
            && userFlow.futureRecommendation !=null && !userFlow.futureRecommendation.some(item => item.uid === userTargetUid))
            {

            console.log("Invalid like from flow index")
            return res.status(403).send({ message: "Can't like this user"});
        }

        // Send like to User Request
        const userLikes = await getUserLikes(user.uid);

        if (!userLikes || userLikes.amount <= 0) {
            return res.status(403).send({ message: "Not enough likes"});
        }

        await removeUserLikes(user.uid, 1);
        user.sendLike(userTarget.uid);

        // Receive like to user target
        userTarget.getLike(user.uid);

        let message = {}

        // If there is a match
        if (user.likesReceived[userTarget.uid]!=null && userTarget.likesReceived[user.uid]!=null){
            message = {
                data: {
                  type: 'match',
                  userName: user.name,
                  userID: user.uid
                },
                token: userTarget.tokenNotifications
            };

            // Create chat and add User Request and user target to it
            const { data, err } = await createChat(user.uid, userTarget.uid);
            if (err==null){
                user.statistics.matchs++;
                delete user.likesGiven[userTarget.uid];
                delete user.likesReceived[userTarget.uid];
                await user.update({ 
                    statistics: user.statistics,
                    likesGiven: user.likesGiven,
                    likesReceived: user.likesReceived,
                });
                user.changed("statistics", true)
                user.changed("likesGiven", true)
                user.changed("likesReceived", true)
                user.save()

                userTarget.statistics.matchs++;
                delete userTarget.likesGiven[user.uid];
                delete userTarget.likesReceived[user.uid];
                await userTarget.update({ 
                    statistics: userTarget.statistics,
                    likesGiven: userTarget.likesGiven,
                    likesReceived: userTarget.likesReceived,
                });
                userTarget.changed("statistics", true)
                userTarget.changed("likesGiven", true)
                userTarget.changed("likesReceived", true)
                userTarget.save()

            } else {
                return res.status(500).send({ message: "Internal server error" });
            }

        } else {
            message = {
                data: {
                    type: 'like',
                    userName: user.name,
                    userID: user.uid
                },
                token: userTarget.tokenNotifications
            };
        }

        console.log(userTarget.tokenNotifications);

        // Send notification (match or like)
        if(userTarget.tokenNotifications!=null){
            getMessaging().send(message)
            .then((response) => {
                console.log(response);
                console.log('Successfully sent notification like/match:', response);
            })
            .catch((error) => {
                console.log('Error sending notification like/match:', error);
            });
        }
        
        return res.status(200).send({likes: userLikes.amount});
    } catch (err) {
        console.log(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Permit to delete a received like
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.deleteLikeReceived = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    const userIDTarget = req.params.userTarget;

    try {

        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // If like exist delete like
        if (user.likesReceived[userIDTarget]==null){
            return res.status(400).send({ message: "Invalid like deletion" });
        }

        delete user.likesReceived[userIDTarget];
        user.changed("likesReceived", true);
        await user.save();

        return res.status(200).send({ message: "Like deletion successful" });
    } catch (err) {
        console.error(err);
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Get the remaining time of daily likes
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getDailyLikes = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
    
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // Get if user exist in Likes table
        const userLikesClaimed = await hasUserClaimDailyLikes(req.uid);

        return res.status(200).send({dailyLikesClaimed: userLikesClaimed});
    } catch (err) {
        return res.status(500).send({ message: "Internal server error" });
    }
};


/**
 * Permit to claim the daily likes
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.claimDailyLikes = async (req, res) => {
    // If there is no uid provided (really strange :/)
    if (req.uid==null){
        return res.status(400).send({ message: "Invalid user" });
    }

    try {
        // Get User Request datas
        const user = await User.findOne({ where: { uid: req.uid } })
        if (user==null){
            return res.status(400).send({ message: "Invalid user" });
        }
        if (user.isVerif==false){
            return res.status(401).send({ message: "Please verify your email first" });
        }

        // Get if user exist in DailyLikes table
        const userLikesExist = await hasUserClaimDailyLikes(req.uid);
        if (!userLikesExist){
            const userLikes = await createUserLikes(req.uid);
            return res.status(200).send({likes: userLikes.amount});
        }

        return res.status(403).send({ message: "Unauthorized" });
    } catch (err) {
        return res.status(500).send({ message: "Internal server error" });
    }
};