// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get errorOccured => 'An error occured :(';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get addHobby => 'Add +';

  @override
  String get selectImage => 'Select an image';

  @override
  String get gallery => 'Gallery';

  @override
  String get takePicture => 'Take a picture';

  @override
  String get freeDailyLike => 'free';

  @override
  String get dailyLikes => 'Daily likes';

  @override
  String get claim => 'claim';

  @override
  String get newLabel => 'New';

  @override
  String get match => 'Match';

  @override
  String get matches => 'Matches';

  @override
  String get matchUnavailblePopupTitle => 'Hello ?..';

  @override
  String get matchUnavailablePopupContent => 'This match is no longer available !';

  @override
  String get deleteThisMatch => 'Delete this match';

  @override
  String get imageUnavailable => 'Image unavailable';

  @override
  String get nameUnavailable => 'Name unavailable';

  @override
  String get tapToClose => 'Tap to close';

  @override
  String get deleteThisLike => 'Delete this like';

  @override
  String get confirmAction => 'Do you really want to do this?';

  @override
  String get note => 'Note';

  @override
  String get years => 'years old';

  @override
  String get pleaseReconnect => 'Please log in again';

  @override
  String get likeReception => 'Received a like';

  @override
  String get likeReceptionDesc => 'Notification when you receive a like.';

  @override
  String likeReceptionNotif(String userName) {
    return 'You received a like $userName';
  }

  @override
  String get matchReception => 'New match';

  @override
  String get matchReceptionDesc => 'Notification when you match with another user.';

  @override
  String matchReceptionNotif(String userName) {
    return 'You matched with $userName !';
  }

  @override
  String get messageReception => 'Received new message';

  @override
  String get messageReceptionDesc => 'Notification when received new message.';

  @override
  String messageReceptionNotif(String userName) {
    return 'New message $userName !';
  }

  @override
  String get dailyLikesNotif => 'Reset of daily likes';

  @override
  String get dailyLikesNotifDesc => 'Notification when daily likes are available.';

  @override
  String get dailyLikesNotifTitle => '❤️ It\'s time !';

  @override
  String get dailyLikeNotifContent => 'Daily likes are now available !';

  @override
  String get customNotif => 'Custom notifications';

  @override
  String get customNotifDesc => 'General custom notifications from our team';

  @override
  String get notEnoughLikes => 'You\'re out of likes, come back tomorrow !';

  @override
  String get oops => 'Oops...';

  @override
  String get okay => 'Okay';

  @override
  String get clickToView => 'Click to view';

  @override
  String get changeEmail => 'Change email';

  @override
  String get emailAddress => 'Email address';

  @override
  String get changeMyEmail => 'Change my email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email address !';

  @override
  String get validateAccountWithEmail => 'Validate your account by clicking on the link received in your email inbox';

  @override
  String verifEmailSent(String email) {
    return 'A verification email has been sent to $email';
  }

  @override
  String get emailUnvailable => 'This email address is not available !';

  @override
  String get pleaseConfirmEmail => 'Please confirm your email address first !';

  @override
  String get sucessConfirmEmail => 'Email address confirmed!';

  @override
  String get passwordResetEmailSent => 'A reset link has been sent to your email !';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetMyPassword => 'Reset my password';

  @override
  String get password => 'Password';

  @override
  String get passwordRequirement => '10 characters, with : 1 Uppercase, 1 Lowercase\n1 Number, and 1 @\\\$!%*?&.€';

  @override
  String get passwordForgot => 'I forgot my password';

  @override
  String get receivedLikes => 'Received likes';

  @override
  String get emptyLikesReception => 'You haven\'t received any likes yet';

  @override
  String get emptyMatchesReception => 'You don\'t have any matches yet.';

  @override
  String get takeFirstStep => 'Take the first step';

  @override
  String get wrongCredentials => 'Wrong credentials !';

  @override
  String get loadMoreMessages => 'Load more messages';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get imageEdited => 'Image edited';

  @override
  String get imageTooBig => 'The image is too large! Maximum 20 MB';

  @override
  String get editSuccess => 'Edit successful !';

  @override
  String get edit => 'edit';

  @override
  String get addANote => 'Add a note';

  @override
  String get location => 'Location';

  @override
  String get gender => 'Gender';

  @override
  String get filters => 'Filters';

  @override
  String get ageSearch => 'Age search';

  @override
  String get attractions => 'Attractions';

  @override
  String get relationship => 'Relationship';

  @override
  String get weeks => 'Weeks';

  @override
  String get account => 'Account';

  @override
  String get profilePaused => 'Profile paused';

  @override
  String get profileNowPaused => 'Your profile is now paused !';

  @override
  String get profileNowVisible => 'Your profile is now visible !';

  @override
  String get logoutPopupTitle => 'Come back soon!';

  @override
  String get logoutPopupContent => 'Do you want to log out?';

  @override
  String get logout => 'Log out';

  @override
  String get accountDeletePopupTitle => 'Leaving us ?';

  @override
  String get accountDeletePopupContent => 'Your account will be automatically deleted after 30 days';

  @override
  String get accountDeleteReloginToCancel => 'Log in again to recover your account';

  @override
  String get deleteMyAccount => 'Delete my account';

  @override
  String get legalNotice => 'Legal Notice';

  @override
  String get tos => 'ToS';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get yourLoginInfo => 'Your login information';

  @override
  String get whatsYourName => 'What\'s your name ?';

  @override
  String get firstName => 'First name';

  @override
  String get whenWereBorn => 'When were you born ?';

  @override
  String get agreeWith => 'Agree with';

  @override
  String get finalize => 'Finalize';

  @override
  String get passwordSuccessUpdated => 'Password updated ! You can log in again';

  @override
  String get delayExceededPleaseRestart => 'The time limit has been exceeded ! Please try again';

  @override
  String get passwordDoesntRequirements => 'The password doesn\'t meet the requirements!';

  @override
  String get newPassword => 'New password';

  @override
  String get reEnterPassword => 'Re-enter the password';

  @override
  String get invalidPassword => 'Invalid password !';

  @override
  String get passwordsDoesntMatch => 'Passwords do not match !';

  @override
  String get searchNewProfiles => 'Searching for new profiles...';

  @override
  String get niceTry => 'Nice try !';

  @override
  String get pageNotFound => 'Page not found';

  @override
  String get anAgePreference => 'An age preference ?';

  @override
  String get validate => 'Validate';

  @override
  String get andYourAttractions => 'And your attractions';

  @override
  String get whatsYourAttractions => 'What are your attractions ?';

  @override
  String get noGenderAvailable => 'No gender available';

  @override
  String get whatsYourGender => 'What is your gender ?';

  @override
  String get pictures => 'pictures';

  @override
  String get addPicture => 'Add a picture';

  @override
  String get whereAreYou => 'Where are you located ?';

  @override
  String get yourSearchDistance => 'Your search distance ?';

  @override
  String get birthDate => 'Date of birth';

  @override
  String get newNote => 'New note';

  @override
  String get andOtherwise => 'And otherwise';

  @override
  String get whyAreYouHere => 'Why are you here ?';

  @override
  String get relationshipSearched => 'What kind of relationship are you looking for ?';

  @override
  String get noRelationshipAvailable => 'No relationship available';

  @override
  String get apiUnavailable => 'Maintenance in progress, sorry for the inconvenience';

  @override
  String get emailInvalid => 'Invalid email';

  @override
  String get passwordInvalid => 'Invalid password';

  @override
  String get firstNameInvalid => 'Invalid first name';

  @override
  String get unableToGetLocation => 'Unable to get location';
}
