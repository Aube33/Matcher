// ===== IMPORTS =====
require('dotenv').config();
const jwt = require('jsonwebtoken');
// ==========



/**
 * Simple validation of a Bearer Token
 * @param {*} req - Request
 * @param {*} res - Response
 * @returns 
 */
exports.validateVerif = async (req, res) => {
  return res.status(200).send();
}



/**
 * Generate a JWT (JSON Web Token) for a user
 * @param {*} user - User Datas
 * @returns 
 */
exports.generateJWT = function (user) {
    const payload = {
      uid: user.uid,
      name: user.name,
      email: user.email,
    };
  
    const options = {
      expiresIn: '90d',
      algorithm: 'HS256',
    };
  
    const secretKey = process.env.JWT_SECRET_KEY;
  
    const token = jwt.sign(payload, secretKey, options);
    return token;
}