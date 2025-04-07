// ===== IMPORTS =====
const { DataTypes } = require('sequelize');
// ==========

module.exports = (sequelize) => {
  const Chat = sequelize.define('chat', {
    cid: { // Chat ID
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      unique: true,
      primaryKey: true,
    },
    users: { // User IDs in chat
      type: DataTypes.ARRAY(DataTypes.UUID),
      allowNull: false
    },
    seen: { // Chat seen by user
      type: DataTypes.ARRAY(DataTypes.UUID),
      allowNull: false,
      defaultValue: []
    }
  });

  return Chat;
};
