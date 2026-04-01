import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();

    // Request notification permission
    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token (for sending targeted notifications)
    final token = await messaging.getToken(
      vapidKey: 'YOUR_VAPID_KEY', // Generated in Firebase Console
    );
    debugPrint('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message in foreground: ${message.notification?.title}');
    });
  } catch (e) {
    debugPrint('Firebase init skipped (not configured): $e');
  }

  // Crashlytics error handling (mobile only — not available on web)
  if (!kIsWeb) {
    try {
      // Import firebase_crashlytics dynamically for mobile builds
      // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      // PlatformDispatcher.instance.onError = (error, stack) {
      //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      //   return true;
      // };
    } catch (_) {}
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: SmartFujairahApp()),
    ),
  );
}
