const int lastMessagePreviewLength = 27;

RegExp nameRegex = RegExp(r'^[a-zàâçéèêëîïôûùüÿñæœ .-]+$', caseSensitive: false);
const int nameMaxLength = 20;
const int emailMaxLength = 320;

RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@$!%*?&.€]).{10,64}$');
const int passwordMaxLength = 64;

const int noteMaxLength  = 1000;
const int hobbyNameMaxLength = 20;