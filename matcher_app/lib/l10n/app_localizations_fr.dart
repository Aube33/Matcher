// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Salut Monde!';

  @override
  String get errorOccured => 'Une erreur est survenue :(';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get addHobby => 'Ajouter +';

  @override
  String get selectImage => 'Selectionner une image';

  @override
  String get gallery => 'Gallerie';

  @override
  String get takePicture => 'Prendre une photo';

  @override
  String get freeDailyLike => 'free';

  @override
  String get dailyLikes => 'Likes journaliers';

  @override
  String get claim => 'obtenir';

  @override
  String get newLabel => 'New';

  @override
  String get match => 'Match';

  @override
  String get matches => 'Matches';

  @override
  String get matchUnavailblePopupTitle => 'Allo ?..';

  @override
  String get matchUnavailablePopupContent => 'Ce match n\'est plus disponible !';

  @override
  String get deleteThisMatch => 'Supprimer ce match';

  @override
  String get imageUnavailable => 'Image indisponible';

  @override
  String get nameUnavailable => 'Nom indisponible';

  @override
  String get tapToClose => 'Cliquez pour fermer';

  @override
  String get deleteThisLike => 'Supprimer ce like';

  @override
  String get confirmAction => 'Voulez-vous vraiment faire ça ?';

  @override
  String get note => 'Note';

  @override
  String get years => 'ans';

  @override
  String get pleaseReconnect => 'Veuillez vous reconnecter';

  @override
  String get likeReception => 'Réception d\'un like';

  @override
  String get likeReceptionDesc => 'Notification lorsque vous recevez un like.';

  @override
  String likeReceptionNotif(String userName) {
    return 'Nouveau like $userName';
  }

  @override
  String get matchReception => 'Alerte d\'un nouveau match';

  @override
  String get matchReceptionDesc => 'Notification lorsque vous avez un nouveau match.';

  @override
  String matchReceptionNotif(String userName) {
    return 'Nouveau match avec $userName !';
  }

  @override
  String get messageReception => 'Réception d\'un message';

  @override
  String get messageReceptionDesc => 'Notification lorsque vous recevez un message.';

  @override
  String messageReceptionNotif(String userName) {
    return 'Nouveau message $userName !';
  }

  @override
  String get dailyLikesNotif => 'Réinitialisation des likes journaliers';

  @override
  String get dailyLikesNotifDesc => 'Notification lorsque les likes journaliers sont disponibles.';

  @override
  String get dailyLikesNotifTitle => '❤️ C\'est l\'heure !';

  @override
  String get dailyLikeNotifContent => 'Les likes journaliers sont de nouveau disponibles !';

  @override
  String get customNotif => 'Notifications customisées';

  @override
  String get customNotifDesc => 'Notifications en tout genre de notre équipe';

  @override
  String get notEnoughLikes => 'Vous êtes à court de likes, revenez demain !';

  @override
  String get oops => 'Oups...';

  @override
  String get okay => 'D\'accord';

  @override
  String get clickToView => 'Cliquez pour consulter';

  @override
  String get changeEmail => 'Modifier l\'adresse email';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get changeMyEmail => 'Modifier mon email';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer une adresse email valide !';

  @override
  String get validateAccountWithEmail => 'Validez votre compte en cliquant sur le lien reçu dans votre boîte mail';

  @override
  String verifEmailSent(String email) {
    return 'Un email de vérification a été envoyé à $email';
  }

  @override
  String get emailUnvailable => 'Cette adresse email n\'est pas disponible !';

  @override
  String get pleaseConfirmEmail => 'Veuillez confirmer votre adresse email';

  @override
  String get sucessConfirmEmail => 'Adresse email confirmée !';

  @override
  String get passwordResetEmailSent => 'Un lien de réinitialisation vous a été envoyé par email !';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get resetMyPassword => 'Réinitialiser mon mot de passe';

  @override
  String get password => 'Mot de passe';

  @override
  String get passwordRequirement => '10 caractères, dont : 1 Majuscule, 1 Minuscule\n1 Chiffre, 1 @\\\$!%*?&.€';

  @override
  String get passwordForgot => 'J\'ai oublié mon mot de passe';

  @override
  String get receivedLikes => 'Likes reçus';

  @override
  String get emptyLikesReception => 'Vous n\'avez pas encore reçu de like';

  @override
  String get emptyMatchesReception => 'Vous n\'avez pas de matchs pour l\'instant';

  @override
  String get takeFirstStep => 'Faites le premier pas';

  @override
  String get wrongCredentials => 'Mauvais identifiants !';

  @override
  String get loadMoreMessages => 'Charger plus de messages';

  @override
  String get typeAMessage => 'Entrez un message...';

  @override
  String get imageEdited => 'Image modifiée';

  @override
  String get imageTooBig => 'L\'image est trop volumineuse ! Maximum 20 Mo';

  @override
  String get editSuccess => 'Modification effectuée !';

  @override
  String get edit => 'modifier';

  @override
  String get addANote => 'Ajoutez une note';

  @override
  String get location => 'Localisation';

  @override
  String get gender => 'Genre';

  @override
  String get filters => 'Filtres';

  @override
  String get ageSearch => 'Ages';

  @override
  String get attractions => 'Attirances';

  @override
  String get relationship => 'Relation';

  @override
  String get weeks => 'Semaines';

  @override
  String get account => 'Compte';

  @override
  String get profilePaused => 'Profil en pause';

  @override
  String get profileNowPaused => 'Votre profil est maintenant en pause !';

  @override
  String get profileNowVisible => 'Votre profil est de nouveau visible !';

  @override
  String get logoutPopupTitle => 'revenez vite !';

  @override
  String get logoutPopupContent => 'Voulez-vous vous déconnecter ?';

  @override
  String get logout => 'Déconnexion';

  @override
  String get accountDeletePopupTitle => 'Vous nous quittez ?';

  @override
  String get accountDeletePopupContent => 'Votre compte sera automatiquement supprimé au bout de 30 jours';

  @override
  String get accountDeleteReloginToCancel => 'Reconnectez-vous pour récupérer votre compte';

  @override
  String get deleteMyAccount => 'Supprimer mon compte';

  @override
  String get legalNotice => 'Mentions Légales';

  @override
  String get tos => 'CGU';

  @override
  String get termsOfService => 'Conditions Générales d\'Utilisation';

  @override
  String get yourLoginInfo => 'Tes informations de connexion';

  @override
  String get whatsYourName => 'Comment t\'appelles-tu ?';

  @override
  String get firstName => 'Prénom';

  @override
  String get whenWereBorn => 'Quand es-tu ne(e) ?';

  @override
  String get agreeWith => 'Accepter les';

  @override
  String get finalize => 'Finaliser';

  @override
  String get passwordSuccessUpdated => 'Mot de passe mis à jour ! Vous pouvez vous reconnecter';

  @override
  String get delayExceededPleaseRestart => 'Le délai a été dépassé ! Veuillez recommencer';

  @override
  String get passwordDoesntRequirements => 'Le mot de passe ne respecte pas les consignes !';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get reEnterPassword => 'Réentrez le mot de passe';

  @override
  String get invalidPassword => 'Mot de passe invalide !';

  @override
  String get passwordsDoesntMatch => 'Les mots de passe ne correspondent pas !';

  @override
  String get searchNewProfiles => 'Recherche de nouveaux profils en cours...';

  @override
  String get niceTry => 'Bien essayé !';

  @override
  String get pageNotFound => 'Page introuvable';

  @override
  String get anAgePreference => 'Une preference d\'age ?';

  @override
  String get validate => 'Valider';

  @override
  String get andYourAttractions => 'Et tes attirances';

  @override
  String get whatsYourAttractions => 'Quelles sont tes attirances';

  @override
  String get noGenderAvailable => 'Aucun genre disponible';

  @override
  String get whatsYourGender => 'Quel est ton genre ?';

  @override
  String get pictures => 'photos';

  @override
  String get addPicture => 'Ajouter une image';

  @override
  String get whereAreYou => 'Ou te situes-tu ?';

  @override
  String get yourSearchDistance => 'Ta distance de recherche ?';

  @override
  String get birthDate => 'Date de naissance';

  @override
  String get newNote => 'Nouvelle note';

  @override
  String get andOtherwise => 'Et sinon';

  @override
  String get whyAreYouHere => 'pourquoi es-tu ici ?';

  @override
  String get relationshipSearched => 'Relation recherchee ?';

  @override
  String get noRelationshipAvailable => 'Aucune relation disponible';

  @override
  String get apiUnavailable => 'Une maintenance est en cours, désolé pour le désagrément';

  @override
  String get emailInvalid => 'Adresse email invalide';

  @override
  String get passwordInvalid => 'Mot de passe invalide';

  @override
  String get firstNameInvalid => 'Prénom invalide';

  @override
  String get unableToGetLocation => 'Impossible d\'obtenir la localisation';
}
