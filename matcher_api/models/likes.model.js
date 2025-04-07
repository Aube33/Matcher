// ===== IMPORTS =====
const { DataTypes } = require('sequelize');
const { dailyLikesAmount, maxLikes } = require('../config/likes.config');
// ==========



module.exports = (sequelize) => {
  const Likes = sequelize.define('likes', {
    uid: { // User ID
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      unique: true
    },
    amount : { // Amount of likes
      type: DataTypes.SMALLINT,
      allowNull: false,
      defaultValue: dailyLikesAmount,
      validate: {
        min: {
          args: [0], // Minimal value
          msg: 'Le nombre de like possédé ne peut pas être inférieur à 0',
        },
        max: {
          args: [maxLikes], // Maximal value
          msg: 'Le nombre de like possédé ne peut pas être supérieur à 999',
        },
      },
    }
  });

  return Likes;
};
