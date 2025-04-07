class InsufficientLikesError extends Error {
    constructor(message) {
        super(message);
        this.name = "InsufficientLikesError";
        this.code = "INSUFFICIENT_LIKES";
    }
}

class UnknownChatError extends Error {
    constructor(message) {
        super(message);
        this.name = "UnknownChatError";
        this.code = "UNKNOWN_CHAT";
    }
}

module.exports = {
    InsufficientLikesError,
    UnknownChatError
};