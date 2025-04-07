// ===== IMPORTS =====
require('dotenv').config();
const jwt = require('jsonwebtoken');
const { maxImageFileSize } = require("../config/users.config");
// ==========

/**
 * Validation of User Agent
 * @param {*} req - Request
 * @param {*} res - Response
 * @param {*} next - Next Request
 * @returns 
 */
exports.checkUserAgent = (req, res, next) =>  {
    const allowedUserAgent = 'MatcherAgent';
    const userAgent = req.get('User-Agent');

    if (userAgent !== allowedUserAgent) {
        console.log("bad agent");
        return res.status(403).send({ message: "Unauthorized" });
    }

    next();
}

/**
 * Validation Files
 * @param {*} req - Request
 * @param {*} res - Response
 * @param {*} next - Next Request
 * @returns 
 */
exports.fileFilterMiddleware = (req, res, next) => {
    if (!req.files || req.files.length === 0) {
        return res.status(400).send({ message: "No files uploaded" });
    }

    for (const file of req.files) {
        const { mimetype, size } = file;

        if (!["image/png", "image/jpg", "image/jpeg"].includes(mimetype)) {
        return res.status(415).send({ message: `Unsupported file type: ${mimetype}` });
        }

        if (size > maxImageFileSize) {
        return res.status(413).send({ message: `File too large: ${file.originalname}` });
        }
    }

    next();
};


/**
 * Validation of Bearer Token
 * @param {*} req - Request
 * @param {*} res - Response
 * @param {*} next - Next Request
 * @returns 
 */
exports.verifyToken = (req, res, next) => {
    const secretKey = process.env.JWT_SECRET_KEY;
  
    // Get given Bearer Token
    const bearer = req.header('Authorization');
    if (!bearer || bearer.split(' ').length==1){
      return res.status(401).send({ message: 'Invalid token' });
    }
    const token=bearer.split(' ')[1];
  
    if (!token) {
      return res.status(401).send({ message: 'Missing token' });
    }
  
    // Verification of token
    jwt.verify(token, secretKey, { algorithms: ['HS256'] }, (err, decoded) => {
      if (err) {
        return res.status(401).send({ message: 'Invalid token' });
      }
      req.uid = decoded.uid;
      next();
    });
  };