const { getMessaging } = require("firebase-admin/messaging");
const db = require("../models");
const User = db.users;
const Op = db.Sequelize.Op;

exports.sendDailyLikesNotification = async () => {
    try {
        const users = await User.findAll({
            where: {
                tokenNotifications: {
                    [Op.ne]: null
                }
            }
        });
        
        if (users.length === 0) {
            console.log('Aucun utilisateur avec un token trouvé');
            return;
        }

        const tokens = users.map(user => user.tokenNotifications);

        message = {
            data: {
                type: 'dailyLikes',
            },
            tokens: tokens
        };

        return await getMessaging().sendEachForMulticast(message)
    } catch (err) {
        console.log(err);
    }
}