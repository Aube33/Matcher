// ===== IMPORTS =====
const db = require("../models");
const User = db.users;
const Chat = db.chat;
const Op = db.Sequelize.Op;

const { sendVerifEmail, sendResetPasswordEmail, sendChangeMailEmail, sendDeleteAccountEmail } = require('../email/emailSystem');
const { generateToken, sha2 } = require("../functions/tokens.functions");
const { generateJWT } = require("../functions/jwt.functions");
const { ageMinRange, ageMaxRange, hobbyNameMaxLength, passwordRegex, emailRegex, emailMaxLength, passwordMaxLength, nameMaxLength, nameRegex, searchMinDist, searchMaxDist, noteMaxLength } = require("../config/users.config");
const { Hobbies } = require("../config/hobbies.config.js");
const { Genders } = require("../config/gender.config.js");
const { RelationShips } = require("../config/relations.config.js");
const { distanceBtw2Coord, getAgeFromDate } = require("../functions/flow.functions.js");
const { hasUserClaimDailyLikes, getUserLikes } = require("../functions/likes.functions.js");
const { getMessagesForChat } = require("../functions/chat.functions.js");
const { isOver18 } = require("../functions/users.function.js");
const { IMAGES_HOST, IMAGES_PORT } = require("../config/images.config.js");
const fs = require('fs');
const e = require("cors");

// ==========



// ===== BASICS =====

/**
 * Create a user in database. Request need datas
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.createUser = async (req, res) => {
  // User Name verification
  if (!req.body.name || req.body.name.length>nameMaxLength || !nameRegex.test(req.body.name)) {
    return res.status(400).send({message: "Invalid name"});
  }

  // User Email verification
  else if(!req.body.email || req.body.email.length>emailMaxLength || !emailRegex.test(req.body.email)) {
    return res.status(400).send({message: "Invalid email"});
  }
  
  // User Password verification
  else if(!req.body.password || req.body.password.length>passwordMaxLength || !passwordRegex.test(req.body.password)) {
    return res.status(400).send({message: "Invalid password"});
  }
  
  else if(!req.body.location) {
    return res.status(400).send({message: "Invalid location"});
  }
  
  else if(!req.body.searchDist || req.body.searchDist<searchMinDist || req.body.searchDist>searchMaxDist) {
    return res.status(400).send({message: "Invalid search Distance"});
  }
  
  else if(!req.body.birthday || !isOver18(req.body.birthday)) {
    return res.status(400).send({message: "Invalid birthday"});
  }
  
  else if(!req.body.ageMinSought || req.body.age<ageMinRange || req.body.age>ageMaxRange) {
    return res.status(400).send({message: "Invalid minimum age sought"});
  }
  
  else if(!req.body.ageMaxSought || req.body.age<ageMinRange || req.body.age>ageMaxRange) {
    return res.status(400).send({message: "Invalid maximum age sought"});
  }
  
  else if(!req.body.gender || !Object.keys(Genders).includes(req.body.gender.toString())) {
    return res.status(400).send({message: "Invalid gender"});
  }
  
  else if(!req.body.attractions || req.body.attractions.length > Object.keys(Genders).length || !req.body.attractions.every(e => Object.keys(Genders).includes(e.toString()))){
    return res.status(400).send({message: "Invalid attractions"});
  }
  
  else if(!req.body.relationShip || !Object.keys(RelationShips).includes(req.body.relationShip.toString())){
    return res.status(400).send({message: "Invalid relationship"});
  }
  
  else if(!req.body.hobbies || !req.body.hobbies.every(hobby => hobby.length <= hobbyNameMaxLength)) {
    return res.status(400).send({message: "Invalid hobbies"});
  }

  // Define a User if all checks are correct
  const user = {
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
    location: req.body.location,
    searchDist: req.body.searchDist,
    birthday: req.body.birthday,
    ageMinSought: req.body.ageMinSought,
    ageMaxSought: req.body.ageMaxSought,
    gender: req.body.gender,
    attractions: req.body.attractions,
    relationShip: req.body.relationShip,
    hobbies: req.body.hobbies,
  };

  // Generate token for Email confirmation
  const { token, tokenHash, tokenTTL } = generateToken();
  user.token=tokenHash;
  user.tokenTTL=tokenTTL;

  try {
    // Create User in the database
    const createdUser = await User.create(user);
    res.status(201).send({message: "User created! Please confirm email"});
    const emailRes = await sendVerifEmail(user.email, token)
    console.log(emailRes);
  } catch (error){
    console.log(`Error while creating new user: ${error}`);
    try {
      res.status(500).send({
        message: "Internal server error"
      })
    } catch (error) {
      console.log("Error user creation")
      console.log(error)
    }
  }
};


/**
 * Get user data from ID
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getUser = async (req, res) => {
  const userID = req.uid;

  // If there is no uid provided (really strange :/)
  if (req.uid==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  // Verification of User Target param
  const targetID = req.params.uid;
  if(targetID==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  try {

    // Find User Request in database
    const user = await User.findOne({ where: { uid: userID } })
    if (user==null){
      return res.status(400).send({ message: "Invalid user" });
    } 
    else if (user.isVerif==false){
      return res.status(401).send({ message: "Please verify your email first" });
    }

    // Find User Target in database
    const targetUser = await User.findOne({ where: { uid: targetID } })
    if (targetUser==null){
      res.status(404).send({ message: "Unknow user target" });
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

      let likesAmount = 0;
      const hasClaimedDailyLikes = await hasUserClaimDailyLikes(user.uid);
      if(hasClaimedDailyLikes){
        const userLikes = await getUserLikes(user.uid);
        likesAmount = userLikes.amount;
      }

      dataRes["email"] = user.email;
      dataRes["searchDist"] = user.searchDist;
      dataRes["birthday"] = user.birthday;
      dataRes["ageMinSought"] = user.ageMinSought;
      dataRes["ageMaxSought"] = user.ageMaxSought;
      dataRes["gender"] = user.gender;
      dataRes["attractions"] = user.attractions;
      dataRes["relationShip"] = user.relationShip;
      dataRes["location"] = user.location;
      dataRes["likes"] = likesAmount;
      dataRes["paused"] = user.paused;

      dataRes["hasClaimedDailyLikes"] = hasClaimedDailyLikes;
    }
    return res.status(200).send(dataRes);
  } catch (error) {
    console.error(error);
    return res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Permit to user to edit there datas
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns
 */
exports.editUser = async (req, res) => {

  // If there is no uid provided (really strange :/)
  if (req.uid==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  // Get all field that user need to edit
  let userUpates = {}

  if (req.body.name != null && req.body.name.length<=nameMaxLength && nameRegex.test(req.body.name)) {
    userUpates["name"] = req.body.name
  }

  if (req.body.location != null) {
    userUpates["location"] = req.body.location
  }

  if (req.body.searchDist != null && req.body.searchDist>=searchMinDist && req.body.searchDist<=searchMaxDist) {
    userUpates["searchDist"] = req.body.searchDist
  }

  if (req.body.birthday != null && isOver18(req.body.birthday)) {
    userUpates["birthday"] = req.body.birthday
  }

  if (req.body.ageMinSought != null && req.body.ageMinSought>=ageMinRange && req.body.ageMinSought<=ageMaxRange) {
    userUpates["ageMinSought"] = req.body.ageMinSought
  }

  if (req.body.ageMaxSought != null  && req.body.ageMaxSought>=ageMinRange && req.body.ageMaxSought<=ageMaxRange) {
    userUpates["ageMaxSought"] = req.body.ageMaxSought
  }

  if (req.body.gender != null && Object.keys(Genders).includes(req.body.gender.toString())) {
    userUpates["gender"] = req.body.gender
  }

  if (req.body.attractions != null && req.body.attractions.length <= Object.keys(Genders).length && req.body.attractions.every(e => Object.keys(Genders).includes(e.toString()))) {
    userUpates["attractions"] = req.body.attractions
  }

  if (req.body.relationShip != null && Object.keys(RelationShips).includes(req.body.relationShip.toString())) {
    userUpates["relationShip"] = req.body.relationShip
  }

  if (req.body.hobbies != null && req.body.hobbies.every(hobby => hobby.length <= hobbyNameMaxLength)) {
    userUpates["hobbies"] = req.body.hobbies
  }

  if (req.body.bio != null && req.body.bio.length<=noteMaxLength) {
    userUpates["bio"] = req.body.bio
  }

  if (req.body.paused != null) {
    userUpates["paused"] = req.body.paused
  }

  try {

    // Get User Request
    const user = await User.findOne({ where: { uid: req.uid } });
    if (!user) {
      return res.status(404).send({ message: "User not found." });
    }

    await user.update(userUpates);
    return res.status(200).send({ message: "User updated successfuly"});
  } catch (err) {
    console.log(err)
    return res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Permit a user to delete paranoidly his account.
 * 30 days (or other if config changed) after the deletion the account will be permanently deleted.
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.deleteUser = async (req, res) => {

  // If there is no uid provided (really strange :/)
  const userId = req.uid;
  if(req.uid==null){
    return res.status(400).send({message: "Invalid user"});
  }

  try {
    const user = await User.findOne({ where: { uid: userId } });
    if (!user) {
      return res.status(400).send({message: "Invalid user"});
    }

    // Paranoidly delete user
    user.destroy().then(deletedUser => {
      if (deletedUser) {
        // Send email to inform account deletion
        sendDeleteAccountEmail(user.email);
        return res.status(200).send({ message: "User deleted"});
      }
    })
    .catch(error => {
      console.log(error);
      return res.status(500).send({ message: 'Internal server error' });
    });

  } catch (err) {
    console.log(err);
    return res.status(500).send({ message: 'Internal server error' });
  }
};
// ==========



// ===== HOBBIES =====
/**
 * Get all hobbies datas
 * @param {*} req - Request
 * @param {*} res - Response
 */
exports.getAllHobbies = (req, res) => {
  if(Hobbies!=undefined && Hobbies!=null){
    return res.status(200).send({Hobbies});
  } else {
    return res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Get one hobby datas
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getHobby = (req, res) => {
  const hobbyName = req.params.hobbyName;

  if(Hobbies==undefined || Hobbies==null){
    return res.status(500).send({ message: "Internal server error" });
  }

  if(hobbyName!=null && Hobbies[hobbyName]!=undefined){
    res.status(200).send({ hobby: Hobbies[hobbyName] });
  } else {
    res.status(404).send({ message: "Unknow hobby" });
  }
};
// ==========



// ===== GENDERS =====
/**
 * Get all genders datas
 * @param {*} req - Request
 * @param {*} res - Response
 */
exports.getAllGender = (req, res) => {
  if(Genders!=undefined && Genders!=null){
    return res.status(200).send({Genders});
  } else {
    res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Get one gender datas
 * @param {*} req 
 * @param {*} res 
 * @returns 
 */
exports.getGender = (req, res) => {
  const genderID = req.params.genderID;

  if(Genders==undefined || Genders==null){
    return res.status(500).send({ message: "Internal server error" });
  }

  if(genderID!=null && Genders[genderID]!=undefined){
    return res.status(200).send({ gender: Genders[genderID] });
  } else {
    return res.status(404).send({ message: "Unknow gender" });
  }
};
// ==========



// ===== RELATIONS =====
/**
 * Get all relations data
 * @param {*} req - Request 
 * @param {*} res - Response
 */
exports.getAllRelations = (req, res) => {
  if(RelationShips!=undefined || RelationShips!=null){
    res.status(200).send({
      RelationShips
    });
  } else {
    res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Get one relation datas
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getRelationShip = (req, res) => {
  const relID = req.params.relID;

  if(RelationShips==undefined || RelationShips==null){
    return res.status(500).send({ message: "Internal server error" });
  }
  if(relID!=null && RelationShips[relID]!=undefined){
    res.status(200).send({ relation: RelationShips[relID] });
  } else {
    res.status(404).send({ relation: "Unknow relationShip" });
  }
};
// ==========



// ===== AUTHENTICATION =====
/**
 * Check if user exist from email
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns boolean
 */
exports.checkEmail = async (req, res) => {
  const { email } = req.params;

  try {
    // Get User datas
    const user = await User.findOne({ where: { email }, paranoid: false });
    if (!user) {
      return res.status(200).send({ exists: false });
    }
    return res.status(200).send({ exists: true })
  } catch (err) {
    console.error("Error (checkEmail) checking email:", err);
    res.status(500).send({ message: "Internal server error" });
  }
};

/**
 * Permit User to login
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.loginUser = async (req, res) => {

  // Get user Email and Password from request
  if (!req.body.email) {res.status(400).send({message: "Invalid email"}); return;}
  else if(!req.body.password) {res.status(400).send({message: "Invalid password"}); return;}
  const { email, password } = req.body;

  try {
    // Get User datas
    const user = await User.findOne({ where: { email }, paranoid: false });
    if (!user) {
      return res.status(404).send({ message: `Unknow user` });
    }

    // Verify user password
    const isValidPassword = await user.validPassword(password);
    if (isValidPassword==true) {

      // Check user Email confirmation
      if (user.isVerif==true){

        // Restore user if it was paranoidly deleted
        if (user.deletedAt !== null) {
          await user.restore();
          console.log('User restored:', user.email);
        }

        // Send JWT Token as response
        res.status(200).send(generateJWT(user));
      } else {
        res.status(201).send({ message: "Account not confirmed" });
      }
    } else {
      res.status(401).send({ message: "Bad authentication" });
    }
  } catch (err) {
    console.error(err);
    res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Permit User to logout
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.logoutUser = async (req, res) => {

  // If there is no uid provided (really strange :/)
  if (req.uid==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  try {
    // Get User Request
    const user = await User.findOne({ where: { uid: req.uid } });
    if (!user) {
      return res.status(404).send({ message: "User not found." });
    }

    await user.update({ tokenNotifications: null });
    return res.status(200).send('Logout successfuly');
  } catch (err) {
    return res.status(500).send({ message: "Internal server error"});
  }
};


function logRequest(req, message) {
  const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress;
  const timestamp = new Date().toISOString();
  const logMessage = `[${timestamp}] IP: ${ip}, Message: ${message}\n`;

  fs.appendFile('bizarre.txt', logMessage, (err) => {
    if (err) {
      console.error('Failed to write to bizarre.txt:', err);
    }
  });
}

/**
 * Permit to send email with password reset url
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.resetPassword = async (req, res) => {
  const emailMaxLength = 255; // Assurez-vous que cette constante est définie correctement
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Exemple de regex pour valider un email

  // Get user Email
  if (!req.body.email || req.body.email.length > emailMaxLength || !emailRegex.test(req.body.email)) {
    return res.status(400).send({ message: "Invalid email" });
  }
  const { email } = req.body;

  try {
    // Get user datas
    const user = await User.findOne({ where: { email } });

    if (!user) {
      logRequest(req, "No user found with this email.");
      return res.status(200).send({ message: "If account exist reset email sent" });
    }

    if (user.isVerif == false) {
      logRequest(req, "User is not verified.");
      return res.status(200).send({ message: "If account exist reset email sent" });
    }

    console.log("test bizarre 2");

    // Token generation to send email user reset url
    const { token, tokenHash, tokenTTL } = generateToken();
    await user.update({ token: tokenHash, tokenTTL: tokenTTL });
    await sendResetPasswordEmail(user.email, token); // FAIRE OUVRIR APP POUR FORMULAIRE RESET

    logRequest(req, "Reset email sent.");
    return res.status(200).send({ message: "If account exist reset email sent" });
  } catch (err) {
    console.error(err);
    logRequest(req, "Internal server error.");
    return res.status(500).send({ message: "Internal server error" });
  }
};



/**
 * Permit to change user'password
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.updatePassword = async (req, res) => {

  // Get user new password
  if(!req.body.newPassword || req.body.newPassword>passwordMaxLength || !passwordRegex.test(req.body.newPassword)) {
    return res.status(400).send({message: "Invalid new password"});
  }

  const { resetToken } = req.params;
  const { newPassword } = req.body;

  try {
    // Get the user with reset token and check if token is valid
    const user = await User.findOne({ where: { token: sha2(resetToken) } });
    if (!user) {
      return res.status(401).send({ message: 'Invalid token' });
    } else if (new Date(user.tokenTTL).getTime()<new Date().getTime()){
      return res.status(403).send({ message: "Expired token" });
    }

    // Update user account with new password and reset token
    await user.updatePassword(newPassword);
    await user.update({ token: null, tokenTTL: null });

    return res.status(200).send({ message: 'Password updated successfully' });
  } catch (error) {
      console.error(error);
      return res.status(500).send({ message: 'Internal server error' });
  }
};


/**
 * Permit to send user email with email reset url
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.changeEmail = async (req, res) => {

  // Get user new email
  if (!req.body.newEmail || req.body.newEmail>emailMaxLength || !emailRegex.test(req.body.newEmail)) {
    return res.status(400).send({message: "Invalid new email"});
  }
  const { newEmail } = req.body;

  try {
    // Check if user with new email already exist and if User Request is valid
    const checkUser = await User.findOne({ where: { email: newEmail } });
    const user = await User.findOne({ where: { uid: req.uid } })

    if (checkUser) {
      res.status(403).send({ message: `User with email ${newEmail} already exist` });
      return;
    }
    if (user.isVerif==false){
      res.status(401).send({ message: "Please verify your email first" });
      return;
    }

    // Generate new token for email reset url
    const { token, tokenHash, tokenTTL } = generateToken();
    await user.update({ token: tokenHash, tokenTTL: tokenTTL, newEmail: newEmail });
    const emailRes = await sendChangeMailEmail(newEmail, token)
    console.log(emailRes);

    return res.status(200).send({ message: "Email to change email sent" })
  } catch (err) {
    console.error(err);
    res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Permit to change user's email
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.updateEmail = async (req, res) => {

  // Get unique token to change user email
  const { changeToken } = req.params;

  try {
    // Get the user with reset token and check if token is valid
    const user = await User.findOne({ where: { token: sha2(changeToken) } });
    if (!user) {
      return res.status(401).send({ message: 'Invalid token' });
    } else if (new Date(user.tokenTTL).getTime()<new Date().getTime()){
      return res.status(403).send({ message: "Expired token" });
    }

    // Update email and delete token
    await user.update({ token: null, tokenTTL: null, email: user.newEmail, newEmail: null });
    return res.status(200).send({ message: 'Email updated successfuly' });
  } catch (error) {
      console.error(error);
      return res.status(500).send({ message: 'Internal server error' });
  }
};

// ==========



// ===== CHATS =====
/**
 * Get all chats of a user
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getUserChats = async (req, res) => {

  // If there is no uid provided (really strange :/)
  if (req.uid==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  try {
    // Get User Request
    const user = await User.findOne({ where: { uid: req.uid } });
    if (!user) {
      return res.status(404).send({ message: "User not found." });
    }

    const userChats = await Chat.findAll({ where: {
      users: { [Op.contains]: [user.uid] }
    }})

    return res.status(200).send(userChats);
  } catch (err) {
    return res.status(500).send({ message: "Internal server error"});
  }
}

// ==========



// ===== IMAGES =====
/**
 * Permit to get profile images of a targeted user.
 * This function contact images server.
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.getUserImages = async (req, res) => {

  // If there is no uid provided (really strange :/)
  if (req.uid==null){
    return res.status(400).send({ message: "Invalid user" });
  }

  // Get targeted user id
  const targetUserId = req.params.uid;
  if (!targetUserId) {
    return res.status(400).send({message: "Invalid user"});
  }

  try {
    // Get targeted user datas
    const user = await User.findOne({ where: { uid: targetUserId } });
    if (!user) {
      return res.status(400).send({ message: "Invalid user" });
    }

    (async () => {
      try {

        // Fetch user images
        // ?pp = profile avatar image
        // ?img = profile images

        const query = new URLSearchParams(req.query);
        const queryString = query.toString();

        const resImage = await fetch(`http://${IMAGES_HOST}:${IMAGES_PORT}/images/${targetUserId}?${queryString}`, {
          method: 'GET',
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        });

        if(resImage.status==200){
          return res.status(200).send(await resImage.json())
        } else {
          console.log(resImage.status)
          return res.status(500).send({ message: 'Internal server error' });
        }
      } catch (err) {
        console.log(err)
        return res.status(500).send({ message: 'Internal server error' });
      }
    })();

  } catch (err) {
    console.log(err)
    res.status(500).send({ message: "Internal server error" });
  }
};


/**
 * Permit to edit images of user with new images
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.postUserImages = async (req, res) => {
  // If there is no uid provided (really strange :/)
  if(req.uid==null){
    return res.status(400).send({message: "Invalid user"});
  }

  try {
    // Get targeted user datas
    const user = await User.findOne({ where: { uid: req.uid } });
    if (!user) {
      return res.status(400).send({message: "Invalid user"});
    }

    (async () => {
      try {
        // = Get images uploaded by user and set them in FormData =
        let images = req.files;
        if (!images) {
          return res.status(400).send({ message: "No images" });
        }
        const formData = new FormData();

        // Get image indexs to edit
        if (req.body.imagesIndex){
          const indexs = JSON.parse(req.body.imagesIndex);
          formData.append('imagesIndex', indexs);
        }

        if (!Array.isArray(images)){
          images = [images];
        }

        // Add images buffer to FormData
        images.forEach(image => {
          const blob = new Blob([image.buffer], { type: image.mimetype });
          formData.append('images', blob, {
            filename: image.originalname,
            contentType: image.mimetype
          });
        });   
        
        // Request to images server with new images
        const resImage = await fetch(`http://${IMAGES_HOST}:${IMAGES_PORT}/upload/${req.uid}`, {
          method: 'POST',
          body: formData
        });

        if(resImage.status==200){
          return res.status(200).send({ message: "Upload successful" });
        } else {
          return res.status(500).send({ message: 'Internal server error' });
        }
      } catch (err) {
        console.log(err);
        return res.status(500).send({ message: 'Internal server error' });
      }
    })();

  } catch (err) {
    console.log(err);
    return res.status(500).send({ message: 'Internal server error' });
  }
};


/**
 * Permit to edit profile image of user with new image
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.postUserProfileImage = async (req, res) => {
  // If there is no uid provided (really strange :/)
  if(req.uid==null){
    return res.status(400).send({message: "Invalid user"});
  }

  try {
    // Get targeted user datas
    const user = await User.findOne({ where: { uid: req.uid } });
    if (!user) {
      return res.status(400).send({message: "Invalid user"});
    }

    (async () => {
      try {
        // = Get images uploaded by user and set them in FormData =
        let image = req.files;
        const formData = new FormData();

        if (Array.isArray(image)){
          image = image[0];
        }

        // Add images buffer to FormData
        if(image){
          const blob = new Blob([image.buffer], { type: image.mimetype });
          formData.append('image', blob, {
            filename: image.originalname,
            contentType: image.mimetype
          });
        }
        
        // Request to images server with new images
        const resImage = await fetch(`http://${IMAGES_HOST}:${IMAGES_PORT}/upload/profile/${req.uid}`, {
          method: 'POST',
          body: formData
        });

        if(resImage.status==200){
          return res.status(200).send({ message: "Upload successful" });
        } else {
          return res.status(500).send({ message: 'Internal server error' });
        }
      } catch (err) {
        console.log(err);
        return res.status(500).send({ message: 'Internal server error' });
      }
    })();

  } catch (err) {
    console.log(err);
    return res.status(500).send({ message: 'Internal server error' });
  }
};
// ==========



// ===== ADMIN =====
/**
 * Get all users (paranoidly delete too) and there datas (ADMIN)
 * @param {*} req - Request
 * @param {*} res - Response
 */
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.findAll({ paranoid: false });
    res.json(users);
  } catch (error) {
    console.error(`Error retrieving users: ${error}`);
    res.status(500).json({ message: 'Failed to retrieve users' });
  }
};


/**
 * Get all user datas (ADMIN)
 * @param {*} req - Request
 * @param {*} res - Response
 */
exports.getUserAdmin = async (req, res) => {
  const id = req.params.id;

  try {
    const userData = await User.findByPk(id);
    if(userData){
      res.status(200).send(userData);
    } else {
      res.status(404).send({
        message: `Cannot find User with id=${id}.`
      })
    }
  } catch (error) {
    console.error(`Error retrieving users: ${error}`);
    res.status(500).json({ message: 'Internal server error' });
  }
};

// ==========