const { Sequelize } = require('sequelize');
const dbConfig = require("../config/db.config.js");

const sequelize = new Sequelize(dbConfig.DB, dbConfig.USER, dbConfig.PASSWORD, {
  host: dbConfig.HOST,
  port: dbConfig.PORT,
  dialect: dbConfig.dialect,
  pool: {
    max: dbConfig.pool.max,
    min: dbConfig.pool.min,
    acquire: dbConfig.pool.acquire,
    idle: dbConfig.pool.idle
  },
  logging: false,
});

const db = {};

db.Sequelize = Sequelize;
db.sequelize = sequelize;

db.users = require("./users.model.js")(sequelize, Sequelize);
db.flow = require("./flow.model.js")(sequelize, Sequelize);
db.chat = require("./chat.model.js")(sequelize, Sequelize);
db.message = require("./message.model.js")(sequelize, Sequelize);
db.likes = require("./likes.model.js")(sequelize, Sequelize);


db.message.belongsTo(db.chat, { foreignKey: 'cid', targetKey: 'cid' });
db.message.belongsTo(db.users, { foreignKey: 'uid', targetKey: 'uid' });

// Relation One-to-Many
db.chat.hasMany(db.message, {
  foreignKey: 'cid',
  sourceKey: 'cid',
  onDelete: 'CASCADE',
});

// Relation One-to-Many
db.users.hasMany(db.message, {
  foreignKey: 'uid',
  onDelete: 'CASCADE',
});

module.exports = db;