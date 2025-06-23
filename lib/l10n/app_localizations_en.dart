// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '🏃‍♂️ Running Tracker';

  @override
  String get homeTitle => 'Home';

  @override
  String get profileTitle => 'Profile';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageTitle => 'Language';

  @override
  String get startRunning => 'Start Running';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationPermissionMessage => 'This app needs location permission to track your running route.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get deny => 'Deny';

  @override
  String get gettingLocation => 'Getting location...';

  @override
  String get locationReady => 'GPS location locked successfully';

  @override
  String get locationFailed => 'Location failed, using default location';

  @override
  String get gpsNotEnabled => 'GPS service not enabled';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String welcomeBack(String username) {
    return 'Welcome back, $username!';
  }

  @override
  String get username => 'Username';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get bio => 'Bio';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get selectAvatar => 'Select Avatar';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get remove => 'Remove';

  @override
  String get avatarSelected => 'Avatar selected, remember to save changes';

  @override
  String get avatarSet => 'Avatar set, remember to save changes';

  @override
  String get imageTooLarge => 'Image file too large, please select an image smaller than 2MB';

  @override
  String selectAvatarFailed(String error) {
    return 'Failed to select avatar: $error';
  }

  @override
  String cameraFailed(String error) {
    return 'Camera failed: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String languageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get countdown => 'Countdown';

  @override
  String get ready => 'Ready';

  @override
  String get go => 'Go!';

  @override
  String seconds(int count) {
    return '$count seconds';
  }

  @override
  String get running => 'Running';

  @override
  String get distance => 'Distance';

  @override
  String get time => 'Time';

  @override
  String get speed => 'Speed';

  @override
  String get pace => 'Pace';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stop => 'Stop';

  @override
  String get finish => 'Finish';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get loggedOut => 'Logged out';

  @override
  String get pleaseLoginFirst => 'Please login first to start running';

  @override
  String get permissionSettings => 'Permission Settings';

  @override
  String get initializingApp => 'Initializing app...';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get aboutApp => 'About App';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get runningTrackerTeam => 'Running Tracker Team';

  @override
  String get legalInfo => 'Legal Information';

  @override
  String get termsTitle => 'Terms of Service';

  @override
  String get privacyTitle => 'Privacy Policy';

  @override
  String lastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get termsContent1 => 'Welcome to Running Tracker! These terms and conditions outline the rules and regulations for the use of Running Tracker\'s mobile application.';

  @override
  String get termsContent2 => 'By accessing this app, we assume you accept these terms and conditions. Do not continue to use Running Tracker if you do not agree to take all of the terms and conditions stated on this page.';

  @override
  String get termsContent3 => '1. User Accounts';

  @override
  String get termsContent4 => 'When you create an account with us, you must provide information that is accurate, complete, and current at all times. You are responsible for safeguarding the password and for all activities that occur under your account.';

  @override
  String get termsContent5 => '2. Use License';

  @override
  String get termsContent6 => 'Permission is granted to temporarily use Running Tracker for personal, non-commercial transitory viewing only. This license shall automatically terminate if you violate any of these restrictions.';

  @override
  String get termsContent7 => '3. Privacy';

  @override
  String get termsContent8 => 'Your privacy is important to us. Please review our Privacy Policy, which also governs your use of the Service, to understand our practices.';

  @override
  String get termsContent9 => '4. Prohibited Uses';

  @override
  String get termsContent10 => 'You may not use our service for any unlawful purpose or to solicit others to perform unlawful acts, to violate any international, federal, provincial, or state regulations, rules, laws, or local ordinances.';

  @override
  String get termsContent11 => '5. Service Availability';

  @override
  String get termsContent12 => 'We reserve the right to withdraw or amend our service, and any service or material we provide via the app, in our sole discretion without notice.';

  @override
  String get termsContent13 => '6. Contact Information';

  @override
  String get termsContent14 => 'If you have any questions about these Terms and Conditions, please contact us at support@runningtracker.app';

  @override
  String get privacyContent1 => 'This Privacy Policy describes how Running Tracker collects, uses, and protects your information when you use our mobile application.';

  @override
  String get privacyContent2 => '1. Information We Collect';

  @override
  String get privacyContent3 => '• Account Information: When you create an account, we collect your username, email address, and optional profile information.';

  @override
  String get privacyContent4 => '• Location Data: With your permission, we collect GPS location data to track your running routes and provide mapping services.';

  @override
  String get privacyContent5 => '• Running Data: We store your running statistics, including distance, time, speed, and route information.';

  @override
  String get privacyContent6 => '• Device Information: We may collect information about your device, including device model, operating system, and app version.';

  @override
  String get privacyContent7 => '2. How We Use Your Information';

  @override
  String get privacyContent8 => '• To provide and maintain our running tracking services';

  @override
  String get privacyContent9 => '• To display your running statistics and progress';

  @override
  String get privacyContent10 => '• To improve our app functionality and user experience';

  @override
  String get privacyContent11 => '• To send you important updates about the app (with your consent)';

  @override
  String get privacyContent12 => '3. Information Sharing';

  @override
  String get privacyContent13 => 'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.';

  @override
  String get privacyContent14 => '4. Data Security';

  @override
  String get privacyContent15 => 'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.';

  @override
  String get privacyContent16 => '5. Your Rights';

  @override
  String get privacyContent17 => 'You have the right to access, update, or delete your personal information. You can do this through the app settings or by contacting us.';

  @override
  String get privacyContent18 => '6. Location Data';

  @override
  String get privacyContent19 => 'Location data is only collected when you actively use the running tracking feature and with your explicit permission. You can disable location access at any time through your device settings.';

  @override
  String get privacyContent20 => '7. Data Retention';

  @override
  String get privacyContent21 => 'We retain your data as long as your account is active or as needed to provide services. You may request deletion of your account and data at any time.';

  @override
  String get privacyContent22 => '8. Contact Us';

  @override
  String get privacyContent23 => 'If you have questions about this Privacy Policy, please contact us at privacy@runningtracker.app';

  @override
  String get appDescription => 'Professional running tracking app that records every step of your journey';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get technicalSupport => 'Technical Support';

  @override
  String get privacyConsultation => 'Privacy Consultation';

  @override
  String get allRightsReserved => 'All Rights Reserved';

  @override
  String get legalCompliance => 'This app complies with relevant laws and regulations to protect user privacy rights';

  @override
  String get aboutSubtitle => 'App info, version, legal information, contact';

  @override
  String languageSwitchFailed(String error) {
    return 'Language switch failed: $error';
  }

  @override
  String get gpsSettings => 'GPS Settings';

  @override
  String get simulateGps => 'Simulate GPS';

  @override
  String get simulateGpsDescription => 'Enable to use simulated GPS data for running tests';

  @override
  String get realGps => 'Real GPS';

  @override
  String get realGpsDescription => 'Use device\'s real GPS for location tracking';

  @override
  String get readyToRun => '🏃‍♂️ Ready to start running!';

  @override
  String get startYourJourney => '🎉 Start your running journey!';

  @override
  String get almostReady => '⚡ Almost ready...';

  @override
  String get gpsReady => 'GPS ready, current location locked!';

  @override
  String get gettingGpsLocation => 'Getting GPS location...';

  @override
  String get gpsServiceNotEnabled => 'GPS service not enabled, using default location';

  @override
  String runningMode(Object fps, Object mode) {
    return 'Running... (${fps}FPS $mode mode)';
  }

  @override
  String gpsReadyMode(Object fps, Object mode) {
    return 'GPS ready! 🎮 ${fps}FPS $mode mode';
  }

  @override
  String get currentLocation => '🏃‍♂️ Current Location';

  @override
  String get runningStarted => 'Running started!';

  @override
  String get runningCompleted => 'Running completed!';

  @override
  String pausedMode(Object fps, Object mode) {
    return 'Paused (${fps}FPS $mode mode)';
  }

  @override
  String get runningEnded => 'Running ended - Great job! 🎉';

  @override
  String get runningComplete => '🎉 Running Complete!';

  @override
  String get totalDistance => 'Total Distance';

  @override
  String get averageSpeed => 'Average Speed';

  @override
  String get caloriesBurned => 'Calories Burned';

  @override
  String get realDataNote => '📱 Using real GPS to track your running route';

  @override
  String get simulatedDataNote => '📱 This is simulated GPS data for testing purposes';

  @override
  String get startRealRun => 'Start Running';

  @override
  String get continueText => 'Continue';

  @override
  String get calories => 'Calories';

  @override
  String get threeDMode => '3D';

  @override
  String get twoDMode => '2D';

  @override
  String get kilometers => 'km';

  @override
  String get kilometersPerHour => 'km/h';

  @override
  String get kcal => 'kcal';

  @override
  String get close => 'Close';

  @override
  String get mode => ' mode';

  @override
  String get highFrameRate3DMode => 'High Frame Rate 3D Mode';

  @override
  String switchToFpsMode(String fps) {
    return '🎮 Switch to ${fps}FPS mode';
  }

  @override
  String switchToViewMode(String mode) {
    return '🌐 Switch to $mode view';
  }
}
