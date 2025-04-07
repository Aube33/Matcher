module.exports = {
    userDestroyPermanentMaxDay: 30, // Delay in days before complete user deletion after paranoid delete
    nameMaxLength: 20, // Maximal length of First name of user
    emailMaxLength: 320, // Maximal length of e-mail address
    passwordMaxLength: 64, // Maximal length of password
    userUnverifiedDestroyMaxDay: 2, // Delay in days before destroy unverified users

    noteMaxLength: 1000,
    searchMinDist: 1,
    searchMaxDist: 500,
    hobbyNameMaxLength: 20,

    maxImageFileSize: 20 * 1024 * 1024,

    ageMinRange: 18, // Minimal accepted age
    ageMaxRange: 127, // Maximal accepted age
    tokenVerifDuration: 10, // Duration in minute of token after his creation

    nameRegex: /^[a-zàâçéèêëîïôûùüÿñæœ .-]+$/i, // First name regex
    passwordRegex: /^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@$!%*?&.€]).{10,}$/, // Password regex
    //emailRegex: /^[a-zA-Z0-9.!#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/
    emailRegex: /^([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x22([^\x0d\x22\x5c\x80-\xff]|\x5c[\x00-\x7f])*\x22))*\x40([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d)(\x2e([^\x00-\x20\x22\x28\x29\x2c\x2e\x3a-\x3c\x3e\x40\x5b-\x5d\x7f-\xff]+|\x5b([^\x0d\x5b-\x5d\x80-\xff]|\x5c[\x00-\x7f])*\x5d))*$/ // Email regex
}