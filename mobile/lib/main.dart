<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repair_booking/l10n/app_localizations.dart';

import 'firebase_bootstrap.dart';
import 'router/app_router.dart';
import 'services/api_service.dart';
import 'ui/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await initializeFirebaseApp();
  } catch (e, st) {
    debugPrint('Firebase init skipped: $e');
    if (kDebugMode) {
      debugPrint('$st');
    }
  }

  await ApiService().init();

=======
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ui/themes/app_theme.dart';
import 'ui/screens/splash_screen.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  await ApiService().init();
  
  // Set preferred orientations
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
<<<<<<< HEAD

=======
  
  // Set system UI overlay style for light theme
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
<<<<<<< HEAD

=======
  
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
  runApp(
    const ProviderScope(
      child: RepairBookingApp(),
    ),
  );
}

<<<<<<< HEAD
class RepairBookingApp extends ConsumerWidget {
  const RepairBookingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
      builder: (context, child) {
        return Semantics(
          container: true,
          label: AppLocalizations.of(context).appTitle,
          child: child ?? const SizedBox.shrink(),
        );
      },
=======
class RepairBookingApp extends StatelessWidget {
  const RepairBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Repair Booking',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
>>>>>>> 7a99d2a4973779009dc79d478870a5ac6e594739
    );
  }
}
