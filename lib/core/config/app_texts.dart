abstract final class AppTexts {
  static const String appTitle = 'GOWASH';
  static const String appVersion = '1.0.0';
  static const String appLegalese =
      'Application de réservation de lavage de voiture mobile.';

  static const String authWelcomeBackTitle = 'Bienvenue de retour';
  static const String authWelcomeBackSubtitle =
      'Connectez-vous pour gérer vos réservations et entrer en contact avec des professionnels certifiés.';
  static const String authCreateAccountTitle = 'Créer votre compte';
  static const String authCreateAccountSubtitle =
      'Créez un compte pour réserver des services de lavage de voiture mobile avec des professionnels certifiés.';
  static const String authTopLoginAction = 'SE CONNECTER';
  static const String authPrimaryLogin = 'SE CONNECTER';
  static const String authPrimaryCreateAccount = 'CRÉER UN COMPTE';
  static const String authForgotPassword = 'Mot de passe oublié ?';
  static const String authLabelFullName = 'Nom complet';
  static const String authLabelPhone = 'Téléphone';
  static const String authLabelEmail = 'Email';
  static const String authLabelPassword = 'Mot de passe';
  static const String authLabelConfirmPassword = 'Confirmer le mot de passe';
  static const String authHintName = 'Alan Anderson';
  static const String authHintEmail = 'alan.anderson@mail.com';
  static const String authHintPassword = '**************';
  static const String authHintPhone = '(409) 444-6666';
  static const String authValidationEmail =
      'Veuillez entrer une adresse email valide.';
  static const String authValidationPasswordMissing =
      'Veuillez entrer votre mot de passe.';
  static const String authValidationResetNeedsEmail =
      'Veuillez entrer votre email pour réinitialiser le mot de passe.';
  static const String authValidationFullName =
      'Veuillez entrer votre nom complet.';
  static const String authValidationPhone =
      'Veuillez entrer un numéro de téléphone valide.';
  static const String authValidationPasswordLength =
      'Le mot de passe doit contenir au moins 6 caractères.';
  static const String authValidationPasswordMismatch =
      'Les mots de passe ne correspondent pas.';
  static const String authResetSent =
      'Email de réinitialisation du mot de passe envoyé.';
  static const String authLoginFailed =
      'Impossible de se connecter pour le moment.';
  static const String authSignUpFailed =
      'Une erreur est survenue lors de la création de votre compte.';
  static const String authSignUpSuccess =
      'Compte créé. Email de vérification envoyé.';
  static const String authTermsPrefix =
      'En vous inscrivant, vous acceptez nos ';
  static const String authTermsAndConditions = 'Conditions générales';
  static const String authTermsAndJoiner = '\net ';
  static const String authPrivacyPolicy = 'Politique de confidentialité';

  static const String onboardingChooseService = 'Choisissez votre service';
  static const String onboardingGoWashPrefix = 'Go Wash ';
  static const String onboardingMapHint =
      'Vous pouvez changer à tout moment depuis la carte.';
  static const String onboardingContinue = 'CONTINUER';
  static const String onboardingServiceCar = 'Voiture';
  static const String onboardingServiceInterior = 'Intérieur';
  static const String onboardingServiceExterior = 'Extérieur';
  static const String onboardingSubtitleCar =
      'Planifiez votre lavage de voiture mobile dès aujourd\'hui et profitez de la commodité ultime.';
  static const String onboardingSubtitleInterior =
      'Offrez à l\'intérieur de votre voiture une expérience de nettoyage luxueuse. Réservez dès aujourd\'hui !';
  static const String onboardingSubtitleExterior =
      'Un look éclatant avec notre lavage extérieur premium. Planifiez dès maintenant !';

  static const String homeSearchHint = 'Rechercher par nom ou zone';
  static const String homeCategoryCar = 'VOITURE';
  static const String homeCategoryInterior = 'INTÉRIEUR';
  static const String homeCategoryExterior = 'EXTÉRIEUR';
  static const String homeDrawerTagline = 'Peut-être un slogan ici';
  static const String homeDrawerMyAccount = 'Mon compte';
  static const String homeDrawerFindWasher = 'Trouver un laveur';
  static const String homeDrawerMyWashes = 'Mes lavages';
  static const String homeDrawerHelp = 'Aide';
  static const String homeDrawerAbout = 'À propos';
  static const String homeDrawerFooter =
      'Conditions générales  ·  Politique de confidentialité';
  static const String homeClosest = 'Le plus proche';
  static const String homeSearchPrompt = 'Rechercher par nom de laveur';
  static const String homeNoWasherMatch =
      'Aucun laveur ne correspond encore à ce nom.';
  static const String homeStartSearch =
      'Commencez une recherche pour afficher les laveurs autour de vous.';
  static const String homeNoFilterResults =
      'Aucun laveur ne correspond encore à ce filtre.';
  static const String homeFirestoreLoadFailed =
      'Impossible de charger les emplacements des laveurs depuis Firestore.';
  static const String homeLocationAllowTitle = 'Autoriser la localisation';
  static const String homeLocationAllowContent =
      'Nous utilisons votre localisation uniquement lorsque vous commencez une recherche afin de vous montrer les laveurs les plus proches.';
  static const String homeLocationNotNow = 'Pas maintenant';
  static const String homeContinue = 'Continuer';
  static const String homeLocationServicesTitle = 'Activer la localisation';
  static const String homeLocationServicesContent =
      'a localisation est désactivée sur ce téléphone. Activez-la afin que nous puissions centrer la carte autour de vous.';
  static const String homeLater = 'Plus tard';
  static const String homeOpenSettings = 'Ouvrir les paramètres';
  static const String homeLocationBlockedTitle = 'Localisation bloquée';
  static const String homeLocationBlockedContent =
      'La permission de localisation est bloquée pour cette application. Ouvrez les paramètres de l\'application pour autoriser l\'accès lorsque vous recherchez un laveur.';
  static const String homeAppSettings = 'Paramètres de l\'application';
  static const String homeFilterTopWasher = 'Meilleur laveur';
  static const String homeFilterDistance = '5 km';
  static const String homeFilterVerified = 'Vérifié';
  static const String homeFilterAvailableNow = 'Disponible maintenant';
  static const String homeYourLocation = 'Votre localisation';

  static const String bookingOrderSummaryTitle = 'Résumé de la commande';
  static const String bookingSectionService = 'SERVICE';
  static const String bookingSectionPaymentMethod = 'MODE DE PAIEMENT';
  static const String bookingNoPaymentMethods =
      'Aucune méthode de paiement n\'a encore été trouvée dans Firestore pour ce compte.';
  static const String bookingPromoHint = 'Entrez le code promo';
  static const String bookingPromoApply = 'APPLIQUER';
  static const String bookingPromoInfo =
      'Les codes promo peuvent être liés une fois que votre champ backend est prêt.';
  static const String bookingTermsPrefix =
      'En appuyant sur "PAYER MAINTENANT", vous acceptez nos ';
  static const String bookingCheckout = 'PAYER';
  static const String bookingReservationCreated =
      'Réservation créée avec succès.';
  static const String bookingReservationFailed =
      'Une erreur est survenue lors de la création de votre réservation.';
  static const String bookingTotal = 'Total';
  static const String bookingCarType = 'Type de véhicule';
  static const String bookingChooseVehicle = '1. CHOISISSEZ VOTRE VÉHICULE';
  static const String bookingChoosePackage =
      '2. CHOISISSEZ VOTRE FORFAIT DE LAVAGE';
  static const String bookingAddons = '3. OPTIONS SUPPLÉMENTAIRES';
  static const String bookingNoPackages =
      'Aucun forfait publié ne correspond encore à cette catégorie de véhicule.';
  static const String bookingNoAddons =
      'Aucun add-on publié n\'est encore disponible pour ce forfait.';
  static const String bookingBookNow = 'RÉSERVER MAINTENANT';
  static const String bookingPhotos = 'PHOTOS';
  static const String bookingBestOffer = 'MEILLEURE OFFRE';
  static const String bookingOrdersInProgress = 'EN COURS';
  static const String bookingOrdersCompleted = 'COMPLÉTÉ';
  static const String bookingEmptyCompleted =
      'Les réservations terminées apparaîtront ici une fois qu\'une réservation est terminée.';
  static const String bookingEmptyInProgress =
      'Les réservations en cours apparaîtront ici après le paiement.';
  static const String bookingReviewFlow =
      'Le flux d\'évaluation peut être connecté ensuite.';
  static const String bookingNoWasherPhone =
      'Le numéro de téléphone du laveur n\'est pas encore disponible.';
  static const String bookingNoInvoice =
      'L\'URL de la facture n\'est pas encore disponible.';
  static const String bookingMessagingComing =
      'La messagerie peut être connectée lorsque le flux de chat est prêt.';
  static const String bookingReservationLabelDate = 'Date';
  static const String bookingReservationLabelWasher = 'Laveur';
  static const String bookingReservationLabelVehicle = 'Véhicule';
  static const String bookingReservationLabelPackage = 'Forfait';
  static const String bookingReservationLabelAddons = 'Options supplémentaires';
  static const String bookingReservationLabelProgress = 'Progression';
  static const String bookingReservationActionInvoice = 'FACTURE';
  static const String bookingReservationActionMessage = 'MESSAGE';
  static const String bookingReservationActionReview = 'LAISSER UN AVIS';
  static const String bookingReservationActionCallWasher = 'APPELER LE LAVEUR';

  static const String profileHeader = 'Mon compte';
  static const String profileUpdated = 'Profil mis à jour.';
  static const String profileUpdateFailed =
      'Impossible de mettre à jour votre profil pour le moment.';
  static const String profileLogoutFailed =
      'Impossible de se déconnecter pour le moment.';
  static const String profileDeleteTitle = 'Supprimer le compte ?';
  static const String profileDeleteContent =
      'Cette action est permanente et peut nécessiter une connexion récente.';
  static const String profileCancel = 'Annuler';
  static const String profileDelete = 'Supprimer';
  static const String profileDeleteMobileOnly =
      'La suppression du compte est disponible uniquement sur mobile connecté.';
  static const String profileDeleteRequiresRelogin =
      'Veuillez vous déconnecter et vous reconnecter avant de supprimer votre compte.';
  static const String profileDeleteFailed =
      'Impossible de supprimer votre compte pour le moment.';
  static const String profileSectionPersonalInfo = 'INFORMATIONS PERSONNELLES';
  static const String profileSectionResources = 'RESSOURCES';
  static const String profileSectionAccount = 'COMPTE';
  static const String profileMaskedPassword = '**************';
  static const String profileAddresses = 'Adresses';
  static const String profileAddressSoon =
      'La gestion des adresses sera disponible bientôt.';
  static const String profileLanguage = 'Langue';
  static const String profileAbout = 'À propos';
  static const String profileAccountAndData = 'Compte et données';
  static const String profileAccountAndDataSoon =
      'Les outils de gestion du compte et des données seront disponibles bientôt.';
  static const String profilePayments = 'Paiements';
  static const String profilePaymentsSoon =
      'La gestion des paiements sera disponible bientôt.';
  static const String profileUsingApp = 'Utilisation de Go Wash';
  static const String profileHelpSoon =
      'Les guides d\'aide seront disponibles bientôt.';
  static const String profileFaq = 'FAQ';
  static const String profileFaqSoon =
      'Le contenu de la FAQ sera disponible bientôt.';
  static const String profileLogout = 'Se déconnecter';
  static const String profileDeleteAccount = 'Supprimer le compte';
  static const String profileEditTitle = 'Modifier le profil';
  static const String profileEditLabelFullName = 'Nom complet';
  static const String profileEditSave = 'Enregistrer les modifications';
  static const String profileValidationPhone =
      'Veuillez entrer un numéro de téléphone valide.';

  static String homeResultsCount(int count) => '$count RÉSULTATS';

  static String bookingCallNumber(String phoneNumber) => 'Appeler $phoneNumber';
}
