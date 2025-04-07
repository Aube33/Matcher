// ===== IMPORTS =====
const { DataTypes } = require('sequelize');
const db = require("../models");
// ==========

module.exports = (sequelize) => {
  const Message = sequelize.define('message', {
    cid: { // Chat id
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
    },
    uid: { // Author id
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
    },
    content: { // Content of message
      type: DataTypes.TEXT,
      allowNull: false
    },
    created_at: { // Creation date
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    },
    liked: { // Likes of users
      type: DataTypes.ARRAY(DataTypes.UUID),
      defaultValue: []
    }
  });

  return Message;
};