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
  String get locationReady => 'Location ready';

  @override
  String get locationFailed => 'Failed to get location';

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
}
