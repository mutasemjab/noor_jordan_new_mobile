import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:noor/firebase_options.dart';

import 'core/constants/app_colors.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

final FlutterLocalNotificationsPlugin localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Android channel id + iOS sound filename for the custom
/// notification sound. Android channel sound is immutable once created on a
/// device, so this uses a fresh id (`noor_custom_sound_channel`) to ensure
/// the new sound takes effect on all existing installs.
const _bellChannelId = 'noor_custom_sound_channel';
const _iosSoundFile = 'custom_sound.caf';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ar', null);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestNotificationPermissions();
    await _initLocalNotifications();
    _listenForegroundMessages();
    _listenNotificationTaps();
  } catch (_) {
    // Firebase not configured — continue without it
  }

  await setupLocator();

  runApp(const NoorApp());
}

Future<void> _requestNotificationPermissions() async {
  try {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('🔔 Notification Permission Status: ${settings.authorizationStatus}');

    await localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  } catch (e) {
    debugPrint('⚠️ Error requesting notification permissions: $e');
  }
}

Future<void> _initLocalNotifications() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const initSettings =
      InitializationSettings(android: androidInit, iOS: iosInit);
  await localNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (response) {
      final payload = response.payload;
      if (payload == null || payload.isEmpty) return;
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        _routePushTap(data);
      } catch (_) {}
    },
  );

  // Create the channel up front with the custom sound baked in — Android
  // ignores sound changes on a channel that already exists, so this only
  // takes effect the first time this channel id is seen on a device.
  const bellChannel = AndroidNotificationChannel(
    _bellChannelId,
    'مدارس نور الأردن',
    description: 'إشعارات المدرسة',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('custom_sound'),
  );
  await localNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(bellChannel);
}

void _listenForegroundMessages() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _bellChannelId,
          'مدارس نور الأردن',
          channelDescription: 'إشعارات المدرسة',
          importance: Importance.high,
          priority: Priority.high,
          color: AppColors.primary,
          sound: const RawResourceAndroidNotificationSound('custom_sound'),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: _iosSoundFile,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  });
}

/// Handles a push tap when the app was already running in the background
/// (onMessageOpenedApp) and when it was launched cold from a terminated
/// state by tapping the notification (getInitialMessage).
void _listenNotificationTaps() {
  FirebaseMessaging.onMessageOpenedApp
      .listen((message) => _routePushTap(message.data));

  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message == null) return;
    // The router isn't attached yet at this point in a cold start — wait
    // for the first frame before pushing.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _routePushTap(message.data));
  });
}

/// Central push-payload router: a `type` (or `screen`) field in the FCM
/// data payload decides which screen to open on tap.
void _routePushTap(Map<String, dynamic> data) {
  final type = data['type'] as String? ?? data['screen'] as String?;
  switch (type) {
    case 'bus_tracking':
    case 'bus_approaching':
      appRouter.push('/bus-tracking');
      break;
    default:
      break;
  }
}

class NoorApp extends StatelessWidget {
  const NoorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'مدارس نور الأردن الدولية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
