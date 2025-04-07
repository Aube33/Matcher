// ===== IMPORTS =====
const db = require("../models");
const { Op } = require('sequelize');
const Flow = db.flow;

const { profileConsultedDelay } = require("../config/flow.config");
// ==========



/**
 * Permit to dertermine score of compatibility between 2 users
 * @param {*} currentUser - user 1 datas
 * @param {*} user2 - user 2 datas
 * @returns Final score of compatibility
 */
exports.determineScore = function (currentUser, user2){
    // Age points
    const ageDifference = currentUser.ageMaxSought-currentUser.ageMinSought;
    const agePerfect = Math.floor(ageDifference/2)+currentUser.ageMinSought;

    const user2Age = exports.getAgeFromDate(user2.birthday);

    const agePoints = calculAgePts(ageDifference, agePerfect, user2Age);


    // Location points
    const locPoints = calculLocationPts(currentUser.location.coordinates, user2.location.coordinates, currentUser.searchDist);

    // Hobbies points
    const hobbiePoints = calculHobbiesPts(currentUser.hobbies, user2.hobbies);

    return parseFloat(((agePoints+locPoints+hobbiePoints)*user2.boost).toFixed(2));
}



// ===== AGE =====
/**
 * Permit to calculate age from birthday date
 * @param {*} birthday - Birthday date as String
 * @returns calculated age
 */
exports.getAgeFromDate = function(date) {
    const birthDate = new Date(date);
    if (isNaN(birthDate.getTime())) {
        throw new Error('Invalid birth date');
    }

    const now = new Date();
    let ageInYears = now.getFullYear() - birthDate.getFullYear();
    const ageInMonths = now.getMonth() - birthDate.getMonth();
    const ageInDays = now.getDate() - birthDate.getDate();

    if (ageInMonths < 0 || (ageInMonths === 0 && ageInDays < 0)) {
        ageInYears--;
    }

    return ageInYears;
};


/**
 * Permit to calculate age score
 * @param {*} diff - Difference of age
 * @param {*} perfect - Perfect age
 * @param {*} ageUser - Current user age
 * @returns points of age
 */
function calculAgePts (diff, perfect, ageUser) {
    const value=Math.abs(Math.abs(ageUser-perfect)-diff);
    return Math.abs(value*100/diff);
}
// ==========



// ===== LOCATION =====
/**
 * Permit to convert degres to radian
 * @param {*} deg - Degres input
 * @returns degres to radian
 */
function degToRad(deg) { return deg * (Math.PI / 180); }


/**
 * Calculate the distance between 2 coordinates
 * @param {*} lat1 - Latitiude 1
 * @param {*} lon1 - Longitude 1
 * @param {*} lat2 - Latitiude 2
 * @param {*} lon2 - Longitude 2
 * @returns the distance in km
 */
exports.distanceBtw2Coord = function(lat1, lon1, lat2, lon2) {
    const rayonTerre = 6371;
    const dLat = degToRad(lat2 - lat1);
    const dLon = degToRad(lon2 - lon1);

    const a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(degToRad(lat1)) * Math.cos(degToRad(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = rayonTerre * c;
    return distance;
}


/**
 * Permit to calculate distance score
 * @param {*} coordUser1 - Coordinates user 1
 * @param {*} coordUser2 - Coordinates user 2
 * @param {*} distanceSearch - Wanted distance
 * @returns points of distance
 */
function calculLocationPts (coordUser1, coordUser2, distanceSearch) {
    const distance = exports.distanceBtw2Coord(coordUser1[0], coordUser1[1], coordUser2[0], coordUser2[1]);
    return (distanceSearch-Math.abs(distance))/distanceSearch*100
}
// ==========



// ===== HOBBIES =====
/**
 * Permit to calculate hobbies score
 * @param {*} hobbiesUser1 - List of user 1 hobbies
 * @param {*} hobbiesUser2 - List of user 2 hobbies
 * @returns points of hobbies
 */
function calculHobbiesPts(hobbiesUser1, hobbiesUser2) {
    let counter=0
    hobbiesUser1.forEach(hobby => {
        if(hobbiesUser2.includes(hobby)){
            counter+=1;
        }
    });
    return Math.floor(counter*120/3)
}
// ==========



/**
 * Clean consulted profiles from all user's flow
 */
exports.cleanUpConsultedProfiles = async () => {
    console.log("Flows consulted profile cleanup start");
    try {
        const flows = await Flow.findAll();
  
        for (const flow of flows) {
            // Filter consultedProfiles where delay > profileConsultedDelay
            const updatedConsultedProfiles = flow.consultedProfiles.filter(profile => {
                if (!profile.delay) return true;

                // Check if delay is within profileConsultedDelay
                const delayDate = new Date(profile.delay);
                const twentyFourHoursAgo = new Date(Date.now() - profileConsultedDelay);
                return delayDate > twentyFourHoursAgo;
            });
    
            // Update the flow only if changes were made
            if (updatedConsultedProfiles.length !== flow.consultedProfiles.length) {
                flow.consultedProfiles = updatedConsultedProfiles;
                await flow.changed("consultedProfiles", true);
                await flow.save();
            }
        }
    
        console.log('Flows cleanup completed successfully.');
    } catch (error) {
        console.error('Error during flows cleanup:', error);
    }
}