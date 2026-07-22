// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Repair Booking';

  @override
  String get splashTagline => 'Trusted home repairs';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to your account to continue';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsThemeSection => 'Appearance';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLightOnlySubtitle =>
      'The app always uses light mode for clear, consistent reading.';

  @override
  String get notificationFeedTitle => 'Notifications';

  @override
  String get notificationFeedSubtitle => 'Booking updates and messages';

  @override
  String get semanticsLoginButton => 'Sign in with phone';

  @override
  String get semanticsGoogleSignIn => 'Sign in with Google';

  @override
  String get bookingLoadError => 'Could not load booking';

  @override
  String get retry => 'Retry';
}
