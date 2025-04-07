// ===== IMPORTS =====
const db = require("../models");
const { Op } = require('sequelize');
const Users = db.users;

const { distanceBtw2Coord, getAgeFromDate } = require("../functions/flow.functions.js")
const { userDestroyPermanentMaxDay, userUnverifiedDestroyMaxDay } = require("../config/users.config");
// ==========

/**
 * Used to make user get data of another user
 * @param {*} userID user id
 * @param {*} targetID target user id
 * @returns 
 */
exports.getUserFromID = async (userID, targetID) => {
    try {
        // Find User Request in database
        const user = await Users.findOne({ where: { uid: userID } })
        if (user==null){
            return null;
        }
    
        // Find User Target in database
        const targetUser = await Users.findOne({ where: { uid: targetID } })
        if (targetUser==null){
            return null;
        }
    
        // Get User Request and User Target coordinates to calcul distance
        const currentUserCoord = user.location.coordinates;
        const userTargetCoord = targetUser.location.coordinates;
    
        // Future response with public datas
        let dataRes = {
            uid: targetUser.uid,
            name: targetUser.name,
            age: getAgeFromDate(targetUser.birthday),
            hobbies: targetUser.hobbies,
            distance: Math.round(distanceBtw2Coord(currentUserCoord[0], currentUserCoord[1], userTargetCoord[0], userTargetCoord[1])),
            liked: user.likesGiven[targetUser.uid]!=null,
            bio: targetUser.bio,
        }
    
        // Add private datas if User Request is requesting himself
        if (targetUser.uid == user.uid){
            dataRes["email"] = user.email;
            dataRes["searchDist"] = user.searchDist;
            dataRes["birthday"] = user.birthday;
            dataRes["ageMinSought"] = user.ageMinSought;
            dataRes["ageMaxSought"] = user.ageMaxSought;
            dataRes["gender"] = user.gender;
            dataRes["attractions"] = user.attractions;
            dataRes["relationShip"] = user.relationShip;
            dataRes["location"] = user.location;
        }
        return dataRes;
    } catch (error) {
        console.error(error);
        return null;
    }
}


/**
 * Permanent deletion of paranoidly deleted users above 30 days
 */
exports.deleteParanoidUsers = async () => {
    try {
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - userDestroyPermanentMaxDay);
    
        const paranoidDeletedUsers = await Users.findAll({
          where: {
            deletedAt: {
              [Op.lt]: thirtyDaysAgo
            },
          },
          paranoid: false
        });
    
        paranoidDeletedUsers.forEach(async user => {
          await user.destroy({force: true});
          console.log(`User ${user.id} deleted.`);
        });
    
        console.log('Paranoid deleted users older than 30 days have been removed.');
    } 
    catch (error) {
        console.error('Error while deleting paranoid deleted users:', error);
    }
}

/**
 * Deletion of unverified users above 2 days
 */
exports.deleteUnverifiedUsers = async () => {
    try {
        const twoDaysAgo = new Date();
        twoDaysAgo.setDate(twoDaysAgo.getDate() - userUnverifiedDestroyMaxDay);

        const unverifiedUsers = await Users.findAll({
            where: {
                isVerif: false,
                updatedAt: {
                    [Op.lt]: twoDaysAgo
                }
            }
        });

        unverifiedUsers.forEach(async user => {
            await user.destroy({force: true});
            console.log(`User ${user.id} (unverified) deleted.`);
        });

        console.log('Unverified users inactive for more than 2 days have been removed.');
    } catch (error) {
        console.error('Error while deleting unverified users:', error);
    }
};

exports.isOver18 = (birthday) => {
    const birthDate = new Date(birthday);
    const today = new Date();

    let age = today.getFullYear() - birthDate.getFullYear();

    const monthDifference = today.getMonth() - birthDate.getMonth();
    if (monthDifference < 0 || (monthDifference === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age >= 18;
}