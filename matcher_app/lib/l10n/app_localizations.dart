import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @errorOccured.
  ///
  /// In en, this message translates to:
  /// **'An error occured :('**
  String get errorOccured;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @addHobby.
  ///
  /// In en, this message translates to:
  /// **'Add +'**
  String get addHobby;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select an image'**
  String get selectImage;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @takePicture.
  ///
  /// In en, this message translates to:
  /// **'Take a picture'**
  String get takePicture;

  /// No description provided for @freeDailyLike.
  ///
  /// In en, this message translates to:
  /// **'free'**
  String get freeDailyLike;

  /// No description provided for @dailyLikes.
  ///
  /// In en, this message translates to:
  /// **'Daily likes'**
  String get dailyLikes;

  /// No description provided for @claim.
  ///
  /// In en, this message translates to:
  /// **'claim'**
  String get claim;

  /// No description provided for @newLabel.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newLabel;

  /// No description provided for @match.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// No description provided for @matches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get matches;

  /// No description provided for @matchUnavailblePopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Hello ?..'**
  String get matchUnavailblePopupTitle;

  /// No description provided for @matchUnavailablePopupContent.
  ///
  /// In en, this message translates to:
  /// **'This match is no longer available !'**
  String get matchUnavailablePopupContent;

  /// No description provided for @deleteThisMatch.
  ///
  /// In en, this message translates to:
  /// **'Delete this match'**
  String get deleteThisMatch;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable'**
  String get imageUnavailable;

  /// No description provided for @nameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Name unavailable'**
  String get nameUnavailable;

  /// No description provided for @tapToClose.
  ///
  /// In en, this message translates to:
  /// **'Tap to close'**
  String get tapToClose;

  /// No description provided for @deleteThisLike.
  ///
  /// In en, this message translates to:
  /// **'Delete this like'**
  String get deleteThisLike;

  /// No description provided for @confirmAction.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to do this?'**
  String get confirmAction;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get years;

  /// No description provided for @pleaseReconnect.
  ///
  /// In en, this message translates to:
  /// **'Please log in again'**
  String get pleaseReconnect;

  /// No description provided for @likeReception.
  ///
  /// In en, this message translates to:
  /// **'Received a like'**
  String get likeReception;

  /// No description provided for @likeReceptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification when you receive a like.'**
  String get likeReceptionDesc;

  /// Notif content when user receive like from another
  ///
  /// In en, this message translates to:
  /// **'You received a like {userName}'**
  String likeReceptionNotif(String userName);

  /// No description provided for @matchReception.
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get matchReception;

  /// No description provided for @matchReceptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification when you match with another user.'**
  String get matchReceptionDesc;

  /// Notif content when user match
  ///
  /// In en, this message translates to:
  /// **'You matched with {userName} !'**
  String matchReceptionNotif(String userName);

  /// No description provided for @messageReception.
  ///
  /// In en, this message translates to:
  /// **'Received new message'**
  String get messageReception;

  /// No description provided for @messageReceptionDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification when received new message.'**
  String get messageReceptionDesc;

  /// Notif content when user match
  ///
  /// In en, this message translates to:
  /// **'New message {userName} !'**
  String messageReceptionNotif(String userName);

  /// No description provided for @dailyLikesNotif.
  ///
  /// In en, this message translates to:
  /// **'Reset of daily likes'**
  String get dailyLikesNotif;

  /// No description provided for @dailyLikesNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'Notification when daily likes are available.'**
  String get dailyLikesNotifDesc;

  /// No description provided for @dailyLikesNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'❤️ It\'s time !'**
  String get dailyLikesNotifTitle;

  /// No description provided for @dailyLikeNotifContent.
  ///
  /// In en, this message translates to:
  /// **'Daily likes are now available !'**
  String get dailyLikeNotifContent;

  /// No description provided for @customNotif.
  ///
  /// In en, this message translates to:
  /// **'Custom notifications'**
  String get customNotif;

  /// No description provided for @customNotifDesc.
  ///
  /// In en, this message translates to:
  /// **'General custom notifications from our team'**
  String get customNotifDesc;

  /// No description provided for @notEnoughLikes.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of likes, come back tomorrow !'**
  String get notEnoughLikes;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops...'**
  String get oops;

  /// No description provided for @okay.
  ///
  /// In en, this message translates to:
  /// **'Okay'**
  String get okay;

  /// No description provided for @clickToView.
  ///
  /// In en, this message translates to:
  /// **'Click to view'**
  String get clickToView;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @changeMyEmail.
  ///
  /// In en, this message translates to:
  /// **'Change my email'**
  String get changeMyEmail;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address !'**
  String get pleaseEnterValidEmail;

  /// No description provided for @validateAccountWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Validate your account by clicking on the link received in your email inbox'**
  String get validateAccountWithEmail;

  /// Message to confirm email reset successfully sent
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to {email}'**
  String verifEmailSent(String email);

  /// No description provided for @emailUnvailable.
  ///
  /// In en, this message translates to:
  /// **'This email address is not available !'**
  String get emailUnvailable;

  /// No description provided for @pleaseConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your email address first !'**
  String get pleaseConfirmEmail;

  /// No description provided for @sucessConfirmEmail.
  ///
  /// In en, this message translates to:
  /// **'Email address confirmed!'**
  String get sucessConfirmEmail;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'A reset link has been sent to your email !'**
  String get passwordResetEmailSent;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @resetMyPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset my password'**
  String get resetMyPassword;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordRequirement.
  ///
  /// In en, this message translates to:
  /// **'10 characters, with : 1 Uppercase, 1 Lowercase\n1 Number, and 1 @\\\$!%*?&.€'**
  String get passwordRequirement;

  /// No description provided for @passwordForgot.
  ///
  /// In en, this message translates to:
  /// **'I forgot my password'**
  String get passwordForgot;

  /// No description provided for @receivedLikes.
  ///
  /// In en, this message translates to:
  /// **'Received likes'**
  String get receivedLikes;

  /// No description provided for @emptyLikesReception.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t received any likes yet'**
  String get emptyLikesReception;

  /// No description provided for @emptyMatchesReception.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any matches yet.'**
  String get emptyMatchesReception;

  /// No description provided for @takeFirstStep.
  ///
  /// In en, this message translates to:
  /// **'Take the first step'**
  String get takeFirstStep;

  /// No description provided for @wrongCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong credentials !'**
  String get wrongCredentials;

  /// No description provided for @loadMoreMessages.
  ///
  /// In en, this message translates to:
  /// **'Load more messages'**
  String get loadMoreMessages;

  /// No description provided for @typeAMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeAMessage;

  /// No description provided for @imageEdited.
  ///
  /// In en, this message translates to:
  /// **'Image edited'**
  String get imageEdited;

  /// No description provided for @imageTooBig.
  ///
  /// In en, this message translates to:
  /// **'The image is too large! Maximum 20 MB'**
  String get imageTooBig;

  /// No description provided for @editSuccess.
  ///
  /// In en, this message translates to:
  /// **'Edit successful !'**
  String get editSuccess;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'edit'**
  String get edit;

  /// No description provided for @addANote.
  ///
  /// In en, this message translates to:
  /// **'Add a note'**
  String get addANote;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @ageSearch.
  ///
  /// In en, this message translates to:
  /// **'Age search'**
  String get ageSearch;

  /// No description provided for @attractions.
  ///
  /// In en, this message translates to:
  /// **'Attractions'**
  String get attractions;

  /// No description provided for @relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationship;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'Weeks'**
  String get weeks;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profilePaused.
  ///
  /// In en, this message translates to:
  /// **'Profile paused'**
  String get profilePaused;

  /// No description provided for @profileNowPaused.
  ///
  /// In en, this message translates to:
  /// **'Your profile is now paused !'**
  String get profileNowPaused;

  /// No description provided for @profileNowVisible.
  ///
  /// In en, this message translates to:
  /// **'Your profile is now visible !'**
  String get profileNowVisible;

  /// No description provided for @logoutPopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Come back soon!'**
  String get logoutPopupTitle;

  /// No description provided for @logoutPopupContent.
  ///
  /// In en, this message translates to:
  /// **'Do you want to log out?'**
  String get logoutPopupContent;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @accountDeletePopupTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaving us ?'**
  String get accountDeletePopupTitle;

  /// No description provided for @accountDeletePopupContent.
  ///
  /// In en, this message translates to:
  /// **'Your account will be automatically deleted after 30 days'**
  String get accountDeletePopupContent;

  /// No description provided for @accountDeleteReloginToCancel.
  ///
  /// In en, this message translates to:
  /// **'Log in again to recover your account'**
  String get accountDeleteReloginToCancel;

  /// No description provided for @deleteMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete my account'**
  String get deleteMyAccount;

  /// No description provided for @legalNotice.
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get legalNotice;

  /// No description provided for @tos.
  ///
  /// In en, this message translates to:
  /// **'ToS'**
  String get tos;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @yourLoginInfo.
  ///
  /// In en, this message translates to:
  /// **'Your login information'**
  String get yourLoginInfo;

  /// No description provided for @whatsYourName.
  ///
  /// In en, this message translates to:
  /// **'What\'s your name ?'**
  String get whatsYourName;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @whenWereBorn.
  ///
  /// In en, this message translates to:
  /// **'When were you born ?'**
  String get whenWereBorn;

  /// No description provided for @agreeWith.
  ///
  /// In en, this message translates to:
  /// **'Agree with'**
  String get agreeWith;

  /// No description provided for @finalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get finalize;

  /// No description provided for @passwordSuccessUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated ! You can log in again'**
  String get passwordSuccessUpdated;

  /// No description provided for @delayExceededPleaseRestart.
  ///
  /// In en, this message translates to:
  /// **'The time limit has been exceeded ! Please try again'**
  String get delayExceededPleaseRestart;

  /// No description provided for @passwordDoesntRequirements.
  ///
  /// In en, this message translates to:
  /// **'The password doesn\'t meet the requirements!'**
  String get passwordDoesntRequirements;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @reEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter the password'**
  String get reEnterPassword;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid password !'**
  String get invalidPassword;

  /// No description provided for @passwordsDoesntMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match !'**
  String get passwordsDoesntMatch;

  /// No description provided for @searchNewProfiles.
  ///
  /// In en, this message translates to:
  /// **'Searching for new profiles...'**
  String get searchNewProfiles;

  /// No description provided for @niceTry.
  ///
  /// In en, this message translates to:
  /// **'Nice try !'**
  String get niceTry;

  /// No description provided for @pageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get pageNotFound;

  /// No description provided for @anAgePreference.
  ///
  /// In en, this message translates to:
  /// **'An age preference ?'**
  String get anAgePreference;

  /// No description provided for @validate.
  ///
  /// In en, this message translates to:
  /// **'Validate'**
  String get validate;

  /// No description provided for @andYourAttractions.
  ///
  /// In en, this message translates to:
  /// **'And your attractions'**
  String get andYourAttractions;

  /// No description provided for @whatsYourAttractions.
  ///
  /// In en, this message translates to:
  /// **'What are your attractions ?'**
  String get whatsYourAttractions;

  /// No description provided for @noGenderAvailable.
  ///
  /// In en, this message translates to:
  /// **'No gender available'**
  String get noGenderAvailable;

  /// No description provided for @whatsYourGender.
  ///
  /// In en, this message translates to:
  /// **'What is your gender ?'**
  String get whatsYourGender;

  /// No description provided for @pictures.
  ///
  /// In en, this message translates to:
  /// **'pictures'**
  String get pictures;

  /// No description provided for @addPicture.
  ///
  /// In en, this message translates to:
  /// **'Add a picture'**
  String get addPicture;

  /// No description provided for @whereAreYou.
  ///
  /// In en, this message translates to:
  /// **'Where are you located ?'**
  String get whereAreYou;

  /// No description provided for @yourSearchDistance.
  ///
  /// In en, this message translates to:
  /// **'Your search distance ?'**
  String get yourSearchDistance;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get birthDate;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @andOtherwise.
  ///
  /// In en, this message translates to:
  /// **'And otherwise'**
  String get andOtherwise;

  /// No description provided for @whyAreYouHere.
  ///
  /// In en, this message translates to:
  /// **'Why are you here ?'**
  String get whyAreYouHere;

  /// No description provided for @relationshipSearched.
  ///
  /// In en, this message translates to:
  /// **'What kind of relationship are you looking for ?'**
  String get relationshipSearched;

  /// No description provided for @noRelationshipAvailable.
  ///
  /// In en, this message translates to:
  /// **'No relationship available'**
  String get noRelationshipAvailable;

  /// No description provided for @apiUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Maintenance in progress, sorry for the inconvenience'**
  String get apiUnavailable;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get emailInvalid;

  /// No description provided for @passwordInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get passwordInvalid;

  /// No description provided for @firstNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid first name'**
  String get firstNameInvalid;

  /// No description provided for @unableToGetLocation.
  ///
  /// In en, this message translates to:
  /// **'Unable to get location'**
  String get unableToGetLocation;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
