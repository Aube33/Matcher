// ===== IMPORTS =====
const express = require('express');
const cors = require("cors");
const firebaseAdmin = require('firebase-admin');
const firebaseServiceAccount = require("./firebase/matcher-159e1-firebase-adminsdk-lczk6-ec4d9eb9c0.json");
const bodyParser = require('body-parser');
const cron = require('node-cron');
const { sendDailyLikesNotification } = require('./functions/notifs.functions');
const { cleanUpConsultedProfiles } = require("./functions/flow.functions");
const { deleteUnverifiedUsers, deleteParanoidUsers } = require("./functions/users.function");

const PORT = process.env.API_PORT;
// ==========



// ===== FIREBASE =====
firebaseAdmin.initializeApp({
  credential: firebaseAdmin.credential.cert(firebaseServiceAccount)
});
// ==========



// ===== DATABASE =====
const db = require("./models");
const sequelize = db.sequelize;
const Op = db.Sequelize.Op;

const Users = db.users;
const Likes = db.likes;
const Flow = db.flow;

sequelize.sync({ force: false, alter: false }).then(() => {
  console.log("Drop and re-sync db.");
});

db.chat.sync({ force: false, alter: false }).then(() => {
  console.log("Drop and re-sync db.");
});
// ==========



// ===== APP CONFIG =====
const app = express();
var corsOptions = {
    origin: `http://matcher-api-docker:${PORT}`
  };
app.use(cors(corsOptions));
app.use(express.json());
app.use(express.urlencoded({extended: true}));
// ==========



// ===== ROUTES =====
require("./routes/tokens.routes")(app);
require("./routes/users.routes")(app);
require("./routes/flow.routes")(app);
require("./routes/likes.routes")(app);
require("./routes/redirect.routes")(app);
require("./routes/chat.routes")(app);

app.get("/", (req, res) => {
  res.json({ message: "Hello young people" });
});

app.get("/api/check", (req, res) => {
  return res.status(200).json({ 
    message: "The API, she's just living her life, nice and easy.", 
  });
});

// 404
app.use((req, res, next) => {
  return res.status(403).send({ message: "Unauthorized" });
});

// ==========



// ===== Daily likes =====
cron.schedule('0 8 * * *', async () => {
  await sendDailyLikesNotification();
});


// ===== Check users deleted 30 days + Reset Daily Likes =====
cron.schedule('0 0 * * *', async () => {

  // Reset likes database
  try{
    await Likes.destroy({ where: {} });
  } catch(error){
    console.log("Error while deleting Likes table: ", error);
  }

  await cleanUpConsultedProfiles();

  await deleteParanoidUsers();

  await deleteUnverifiedUsers();
});
// ==========



// ===== SERVER =====
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server is running on port ${PORT}.`);
});
// ==========
