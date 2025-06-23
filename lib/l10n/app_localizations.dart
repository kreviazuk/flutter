import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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
    Locale('zh')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'🏃‍♂️ Running Tracker'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @startRunning.
  ///
  /// In en, this message translates to:
  /// **'Start Running'**
  String get startRunning;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// No description provided for @locationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'This app needs location permission to track your running route.'**
  String get locationPermissionMessage;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @deny.
  ///
  /// In en, this message translates to:
  /// **'Deny'**
  String get deny;

  /// No description provided for @gettingLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting location...'**
  String get gettingLocation;

  /// No description provided for @locationReady.
  ///
  /// In en, this message translates to:
  /// **'Location ready'**
  String get locationReady;

  /// No description provided for @locationFailed.
  ///
  /// In en, this message translates to:
  /// **'Location failed, using default location'**
  String get locationFailed;

  /// No description provided for @gpsNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'GPS service not enabled'**
  String get gpsNotEnabled;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, {username}!'**
  String welcomeBack(String username);

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @selectAvatar.
  ///
  /// In en, this message translates to:
  /// **'Select Avatar'**
  String get selectAvatar;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @avatarSelected.
  ///
  /// In en, this message translates to:
  /// **'Avatar selected, remember to save changes'**
  String get avatarSelected;

  /// No description provided for @avatarSet.
  ///
  /// In en, this message translates to:
  /// **'Avatar set, remember to save changes'**
  String get avatarSet;

  /// No description provided for @imageTooLarge.
  ///
  /// In en, this message translates to:
  /// **'Image file too large, please select an image smaller than 2MB'**
  String get imageTooLarge;

  /// No description provided for @selectAvatarFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select avatar: {error}'**
  String selectAvatarFailed(String error);

  /// No description provided for @cameraFailed.
  ///
  /// In en, this message translates to:
  /// **'Camera failed: {error}'**
  String cameraFailed(String error);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String languageChanged(String language);

  /// No description provided for @countdown.
  ///
  /// In en, this message translates to:
  /// **'Countdown'**
  String get countdown;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @go.
  ///
  /// In en, this message translates to:
  /// **'Go!'**
  String get go;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{count} seconds'**
  String seconds(int count);

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @speed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @loggedOut.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get loggedOut;

  /// No description provided for @pleaseLoginFirst.
  ///
  /// In en, this message translates to:
  /// **'Please login first to start running'**
  String get pleaseLoginFirst;

  /// No description provided for @permissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Permission Settings'**
  String get permissionSettings;

  /// No description provided for @initializingApp.
  ///
  /// In en, this message translates to:
  /// **'Initializing app...'**
  String get initializingApp;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @developer.
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// No description provided for @runningTrackerTeam.
  ///
  /// In en, this message translates to:
  /// **'Running Tracker Team'**
  String get runningTrackerTeam;

  /// No description provided for @legalInfo.
  ///
  /// In en, this message translates to:
  /// **'Legal Information'**
  String get legalInfo;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsTitle;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyTitle;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String lastUpdated(String date);

  /// No description provided for @termsContent1.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Running Tracker! These terms and conditions outline the rules and regulations for the use of Running Tracker\'s mobile application.'**
  String get termsContent1;

  /// No description provided for @termsContent2.
  ///
  /// In en, this message translates to:
  /// **'By accessing this app, we assume you accept these terms and conditions. Do not continue to use Running Tracker if you do not agree to take all of the terms and conditions stated on this page.'**
  String get termsContent2;

  /// No description provided for @termsContent3.
  ///
  /// In en, this message translates to:
  /// **'1. User Accounts'**
  String get termsContent3;

  /// No description provided for @termsContent4.
  ///
  /// In en, this message translates to:
  /// **'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.'**
  String get termsContent4;

  /// No description provided for @termsContent5.
  ///
  /// In en, this message translates to:
  /// **'2. Use License'**
  String get termsContent5;

  /// No description provided for @termsContent6.
  ///
  /// In en, this message translates to:
  /// **'Permission is granted to temporarily use Running Tracker for personal, non-commercial transitory viewing only. This license shall automatically terminate if you violate any of these restrictions.'**
  String get termsContent6;

  /// No description provided for @termsContent7.
  ///
  /// In en, this message translates to:
  /// **'3. Privacy'**
  String get termsContent7;

  /// No description provided for @termsContent8.
  ///
  /// In en, this message translates to:
  /// **'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices.'**
  String get termsContent8;

  /// No description provided for @termsContent9.
  ///
  /// In en, this message translates to:
  /// **'4. Prohibited Uses'**
  String get termsContent9;

  /// No description provided for @termsContent10.
  ///
  /// In en, this message translates to:
  /// **'You may not use our service for any unlawful purpose or to solicit others to perform unlawful acts, to violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances.'**
  String get termsContent10;

  /// No description provided for @termsContent11.
  ///
  /// In en, this message translates to:
  /// **'5. Service Availability'**
  String get termsContent11;

  /// No description provided for @termsContent12.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to withdraw or amend our service, and any service or material we provide via the app, in our sole discretion without notice.'**
  String get termsContent12;

  /// No description provided for @termsContent13.
  ///
  /// In en, this message translates to:
  /// **'6. Contact Information'**
  String get termsContent13;

  /// No description provided for @termsContent14.
  ///
  /// In en, this message translates to:
  /// **'If you have any questions about these Terms and Conditions, please contact us at support@runningtracker.app'**
  String get termsContent14;

  /// No description provided for @privacyContent1.
  ///
  /// In en, this message translates to:
  /// **'This Privacy Policy describes how Running Tracker collects, uses, and protects your information when you use our mobile application.'**
  String get privacyContent1;

  /// No description provided for @privacyContent2.
  ///
  /// In en, this message translates to:
  /// **'1. Information We Collect'**
  String get privacyContent2;

  /// No description provided for @privacyContent3.
  ///
  /// In en, this message translates to:
  /// **'• Account Information: When you create an account, we collect your username, email address, and optional profile information.'**
  String get privacyContent3;

  /// No description provided for @privacyContent4.
  ///
  /// In en, this message translates to:
  /// **'• Location Data: With your permission, we collect GPS location data to track your running routes and provide mapping services.'**
  String get privacyContent4;

  /// No description provided for @privacyContent5.
  ///
  /// In en, this message translates to:
  /// **'• Running Data: We store your running statistics, including distance, time, speed, and route information.'**
  String get privacyContent5;

  /// No description provided for @privacyContent6.
  ///
  /// In en, this message translates to:
  /// **'• Device Information: We may collect information about your device, including device model, operating system, and app version.'**
  String get privacyContent6;

  /// No description provided for @privacyContent7.
  ///
  /// In en, this message translates to:
  /// **'2. How We Use Your Information'**
  String get privacyContent7;

  /// No description provided for @privacyContent8.
  ///
  /// In en, this message translates to:
  /// **'• To provide and maintain our running tracking services'**
  String get privacyContent8;

  /// No description provided for @privacyContent9.
  ///
  /// In en, this message translates to:
  /// **'• To display your running statistics and progress'**
  String get privacyContent9;

  /// No description provided for @privacyContent10.
  ///
  /// In en, this message translates to:
  /// **'• To improve our app functionality and user experience'**
  String get privacyContent10;

  /// No description provided for @privacyContent11.
  ///
  /// In en, this message translates to:
  /// **'• To send you important updates about the app (with your consent)'**
  String get privacyContent11;

  /// No description provided for @privacyContent12.
  ///
  /// In en, this message translates to:
  /// **'3. Information Sharing'**
  String get privacyContent12;

  /// No description provided for @privacyContent13.
  ///
  /// In en, this message translates to:
  /// **'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.'**
  String get privacyContent13;

  /// No description provided for @privacyContent14.
  ///
  /// In en, this message translates to:
  /// **'4. Data Security'**
  String get privacyContent14;

  /// No description provided for @privacyContent15.
  ///
  /// In en, this message translates to:
  /// **'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.'**
  String get privacyContent15;

  /// No description provided for @privacyContent16.
  ///
  /// In en, this message translates to:
  /// **'5. Your Rights'**
  String get privacyContent16;

  /// No description provided for @privacyContent17.
  ///
  /// In en, this message translates to:
  /// **'You have the right to access, update, or delete your personal information. You can do this through the app settings or by contacting us.'**
  String get privacyContent17;

  /// No description provided for @privacyContent18.
  ///
  /// In en, this message translates to:
  /// **'6. Location Data'**
  String get privacyContent18;

  /// No description provided for @privacyContent19.
  ///
  /// In en, this message translates to:
  /// **'Location data is only collected when you actively use the running tracking feature and with your explicit permission. You can disable location access at any time through your device settings.'**
  String get privacyContent19;

  /// No description provided for @privacyContent20.
  ///
  /// In en, this message translates to:
  /// **'7. Data Retention'**
  String get privacyContent20;

  /// No description provided for @privacyContent21.
  ///
  /// In en, this message translates to:
  /// **'We retain your data as long as your account is active or as needed to provide services. You may request deletion of your account and data at any time.'**
  String get privacyContent21;

  /// No description provided for @privacyContent22.
  ///
  /// In en, this message translates to:
  /// **'8. Contact Us'**
  String get privacyContent22;

  /// No description provided for @privacyContent23.
  ///
  /// In en, this message translates to:
  /// **'If you have questions about this Privacy Policy, please contact us at privacy@runningtracker.app'**
  String get privacyContent23;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Professional running tracking app that records every step of your journey'**
  String get appDescription;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @technicalSupport.
  ///
  /// In en, this message translates to:
  /// **'Technical Support'**
  String get technicalSupport;

  /// No description provided for @privacyConsultation.
  ///
  /// In en, this message translates to:
  /// **'Privacy Consultation'**
  String get privacyConsultation;

  /// No description provided for @allRightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All Rights Reserved'**
  String get allRightsReserved;

  /// No description provided for @legalCompliance.
  ///
  /// In en, this message translates to:
  /// **'This app complies with relevant laws and regulations to protect user privacy rights'**
  String get legalCompliance;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App info, version, legal information, contact'**
  String get aboutSubtitle;

  /// No description provided for @languageSwitchFailed.
  ///
  /// In en, this message translates to:
  /// **'Language switch failed: {error}'**
  String languageSwitchFailed(String error);

  /// No description provided for @readyToRun.
  ///
  /// In en, this message translates to:
  /// **'🏃‍♂️ Ready to start running!'**
  String get readyToRun;

  /// No description provided for @startYourJourney.
  ///
  /// In en, this message translates to:
  /// **'🎉 Start your running journey!'**
  String get startYourJourney;

  /// No description provided for @almostReady.
  ///
  /// In en, this message translates to:
  /// **'⚡ Almost ready...'**
  String get almostReady;

  /// No description provided for @gpsReady.
  ///
  /// In en, this message translates to:
  /// **'GPS ready, current location locked!'**
  String get gpsReady;

  /// No description provided for @gettingGpsLocation.
  ///
  /// In en, this message translates to:
  /// **'Getting GPS location...'**
  String get gettingGpsLocation;

  /// No description provided for @gpsServiceNotEnabled.
  ///
  /// In en, this message translates to:
  /// **'GPS service not enabled, using default location'**
  String get gpsServiceNotEnabled;

  /// No description provided for @runningMode.
  ///
  /// In en, this message translates to:
  /// **'Running... ({fps}FPS {mode} mode)'**
  String runningMode(Object fps, Object mode);

  /// No description provided for @gpsReadyMode.
  ///
  /// In en, this message translates to:
  /// **'GPS ready! 🎮 {fps}FPS {mode} mode'**
  String gpsReadyMode(Object fps, Object mode);

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'🏃‍♂️ Current Location'**
  String get currentLocation;

  /// No description provided for @runningStarted.
  ///
  /// In en, this message translates to:
  /// **'Running started!'**
  String get runningStarted;

  /// No description provided for @runningCompleted.
  ///
  /// In en, this message translates to:
  /// **'Running completed!'**
  String get runningCompleted;

  /// No description provided for @pausedMode.
  ///
  /// In en, this message translates to:
  /// **'Paused ({fps}FPS {mode} mode)'**
  String pausedMode(Object fps, Object mode);

  /// No description provided for @runningEnded.
  ///
  /// In en, this message translates to:
  /// **'Running ended - Great job! 🎉'**
  String get runningEnded;

  /// No description provided for @runningComplete.
  ///
  /// In en, this message translates to:
  /// **'🎉 Running Complete!'**
  String get runningComplete;

  /// No description provided for @totalDistance.
  ///
  /// In en, this message translates to:
  /// **'Total Distance'**
  String get totalDistance;

  /// No description provided for @averageSpeed.
  ///
  /// In en, this message translates to:
  /// **'Average Speed'**
  String get averageSpeed;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @simulatedDataNote.
  ///
  /// In en, this message translates to:
  /// **'📱 This is simulated data, actual use requires GPS enabled'**
  String get simulatedDataNote;

  /// No description provided for @startSimulatedRun.
  ///
  /// In en, this message translates to:
  /// **'Start Simulated Run'**
  String get startSimulatedRun;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @threeDMode.
  ///
  /// In en, this message translates to:
  /// **'3D'**
  String get threeDMode;

  /// No description provided for @twoDMode.
  ///
  /// In en, this message translates to:
  /// **'2D'**
  String get twoDMode;

  /// No description provided for @kilometers.
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get kilometers;

  /// No description provided for @kilometersPerHour.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kilometersPerHour;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **' mode'**
  String get mode;

  /// No description provided for @highFrameRate3DMode.
  ///
  /// In en, this message translates to:
  /// **'High Frame Rate 3D Mode'**
  String get highFrameRate3DMode;

  /// No description provided for @switchToFpsMode.
  ///
  /// In en, this message translates to:
  /// **'🎮 Switch to {fps}FPS mode'**
  String switchToFpsMode(String fps);

  /// No description provided for @switchToViewMode.
  ///
  /// In en, this message translates to:
  /// **'🌐 Switch to {mode} view'**
  String switchToViewMode(String mode);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
