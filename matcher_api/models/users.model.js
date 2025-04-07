// ===== IMPORTS =====
const { DataTypes, Op } = require('sequelize');
const { ageMinRange, ageMaxRange, emailMaxLength, nameMaxLength, passwordMaxLength } = require('../config/users.config');
const bcrypt = require('bcrypt');
const { maxLikes } = require('../config/likes.config');
// ==========



module.exports = (sequelize) => {
  const User = sequelize.define('user', {
    uid: { // User ID in UUIDv4 format
      type: DataTypes.UUID,
      defaultValue: DataTypes.UUIDV4,
      allowNull: false,
      unique: true,
      primaryKey: true,
    },
    name: { // First name
      type: DataTypes.STRING(nameMaxLength*2),
      allowNull: false,
    },
    email: { // E-mail
      type: DataTypes.STRING(emailMaxLength),
      allowNull: false,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    password: { // Password
      type: DataTypes.STRING(passwordMaxLength),
      allowNull: false,
    },
    salt: { // Password salt
      type: DataTypes.STRING,
      allowNull: true,
    },
    isVerif: { // Is account verified ?
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    location: { // Geographical location
      type: DataTypes.GEOGRAPHY('POINT'),
      allowNull: false,
    },
    searchDist: { // Geographic search distance in km
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    birthday: { // Date of birthday
      type: DataTypes.DATE,
      allowNull: false,
      validate: {
        min: {
          args: [new Date(Date.now() - ageMinRange * 365 * 24 * 60 * 60 * 1000)],
          msg: "L'âge est trop petit",
        },
        max: {
          args: [new Date(Date.now() - ageMaxRange * 365 * 24 * 60 * 60 * 1000)],
          msg: "L'âge est trop grand",
        },
      },
    },
    ageMinSought: { // Minimal search age
      type: DataTypes.SMALLINT,
      allowNull: false,
      validate: {
        min: {
          args: [ageMinRange],
          msg: `L\'âge minimum recherché ne peut pas être inférieur à ${ageMinRange}.`,
        },
        max: {
          args: [ageMaxRange],
          msg: `L\'âge minimum recherché ne peut pas dépasser ${ageMaxRange}.`,
        },
       },
    },
    ageMaxSought: { // Maximal search age
      type: DataTypes.SMALLINT,
      allowNull: false,
      validate: {
        min: {
          args: [ageMinRange],
          msg: `L\'âge maximum recherché ne peut pas être inférieur à ${ageMinRange}.`,
        },
        max: {
          args: [ageMaxRange],
          msg: `L\'âge maximum ne peut pas dépasser ${ageMaxRange}.`,
        },
      },
    },
    gender: { // Genre
      type: DataTypes.SMALLINT,
      allowNull: false,
    },
    attractions: { // Attractions
      type: DataTypes.ARRAY(DataTypes.SMALLINT),
      allowNull: false,
    },
    relationShip: { // Desired Relationship
      type: DataTypes.SMALLINT,
      allowNull: false,
    },
    likesReceived: { // List of likes received
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {}
    },
    likesGiven: { // List of likes given
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {}
    },
    hobbies: { // Hobbies
      type: DataTypes.ARRAY(DataTypes.STRING),
      allowNull: false,
      validate: {
        isSpecificLength(value) {
          if (value.length !== 3) {
            throw new Error('hobbies must only have three items')
          }
        }  
      },
    },
    token: { // Token (E-mail confirmation, e-mail edition, password update)
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: null
    },
    tokenTTL: { // Time To Live of Token
      type: DataTypes.DATE,
      allowNull: true,
      defaultValue: null
    },
    newEmail: { // E-mail
      type: DataTypes.STRING(320),
      allowNull: true,
      defaultValue: null,
      unique: true,
      validate: {
        isEmail: true,
      },
    },
    language: { // Language
      type: DataTypes.STRING,
      allowNull: false,
      defaultValue: 'fr',
    },
    bio: { // Biography
      type: DataTypes.TEXT,
      allowNull: false,
      defaultValue: "",
    },
    boost: { // Boost of search
      type: DataTypes.SMALLINT,
      allowNull: false,
      defaultValue: 1,
    },
    tokenNotifications: { // Token for notification (Firebase system)
      type: DataTypes.STRING,
      allowNull: true,
      defaultValue: null,
    },
    statistics: { // Statistics of user
      type: DataTypes.JSONB,
      allowNull: false,
      defaultValue: {
        "view": 0,
        "time": 0,
        "likes": 0,
        "matchs": 0
      }
    },
    paused: { // Visibility of user
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false
    }
  },{
    // Permit to delete paranoidly (not really) users
    paranoid: true
  });


  //=== HOOKS ===
  User.beforeCreate(async (user, options) => {
    const {salt, password} = await hashPassword(user.password);
    user.password=password;
    user.salt=salt;
  });
  // ======


  //=== FUNCTION USER ===

  /**
   * Add new like to user given likes
   * @param {*} userTargetUid - UID of targeted user
   */
  User.prototype.sendLike = async function (userTargetUid) {
    this.likesGiven[userTargetUid] = new Date();
    this.changed("likesGiven", true);
    this.save();
  };

  /**
   * Add new like to user received likes
   * @param {*} userTargetUid - UID of targeted user
   */
  User.prototype.getLike = async function (userTargetUid) {
    this.likesReceived[userTargetUid] = new Date();
    this.statistics.likes++;
    this.changed("statistics", true);
    this.changed("likesReceived", true);
    this.save();
  };

  /**
   * Function to check if entered password is correct
   * @param {*} enteredPassword - Password entered
   * @returns Boolean that return true if password is correct
   */
  User.prototype.validPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
  };

  /**
   * Permit to update user password with new password
   * @param {*} newPassword - New password
   */
  User.prototype.updatePassword = async function (newPassword) {
    const {salt, password}=await hashPassword(newPassword);
    this.password=password;
    this.salt=salt;
    await this.save();
  };
  // ======


  //=== FUNCTION ===
  const hashPassword = async function (password) {
    // === Password Hash + Salt ===
    const saltRounds = 15; 
    const salt = await bcrypt.genSalt(saltRounds);

    const hashedPassword = await bcrypt.hash(password, salt);
    return {
      salt: salt,
      password: hashedPassword
    };
  }
  // ======


  
  return User;
};
