// ===== IMPORTS =====
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const { tokenVerifDuration } = require('../config/users.config');
// ==========



/**
 * Permit to hash a value with sha256
 * @param {*} value - Input value
 * @returns Input value hashed with sha256
 */
exports.sha2 = function (value) {
    const sha256Hash = crypto.createHash('sha256');
    sha256Hash.update(value);
    return sha256Hash.digest('hex');
}


/**
 * Permit to create a new token hashed with sha256
 * @returns generated token
 */
exports.generateToken = function () {
    const uuid = uuidv4();
    return {
        token:uuid, 
        tokenHash: exports.sha2(uuid),
        tokenTTL: new Date((Math.floor(Date.now()/1000)+(tokenVerifDuration*60))*1000)
    }
}


/**
 * Permit to verify a token passed as parameter
 * @param {*} enteredToken - Input token
 * @param {*} userToken - Saved user token
 * @returns True if entered token is user token
 */
exports.checkToken = function (enteredToken, userToken) {
    return exports.sha2(enteredToken)==userToken;
}