import 'package:cobonno/app/common/shared_code.dart';
import 'package:cobonno/app/routes/router.gr.dart';
import 'package:cobonno/bootstrap.dart';
import 'package:cobonno/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'app/app.dart';
import 'app/common/shared_preferences_service.dart';
import 'l10n/l10n.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  //debugPrint("Handling a background message: ${message.messageId}");
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: DefaultFirebaseOptions.currentPlatform.projectId,
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  //debugPrint('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //debugPrint('Got a message whilst in the foreground!');
    //debugPrint('Message data: ${message.data}');
    if (message.notification != null) {
      //debugPrint('Message also contained a notification: ${message.notification}');
    }
  });

  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(seconds: 0),
  ));

  await remoteConfig.fetchAndActivate();

  await remoteConfig.setDefaults(const {
    "signup_with_invitation": false,
    "signup_invitation_code": 'CB12345',
  });

  final appRouter = AppRouter();
  String language = await SharedPreferencesService().getLanguage();
  bool isProduction = DefaultFirebaseOptions.currentPlatform.projectId == 'cobonno-prod';

  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? dynamicLink) async {
    final Uri? deepLink = dynamicLink?.link;
    BuildContext context = NavigationService.navigatorKey.currentContext!;
    if (deepLink == null || deepLink.queryParameters['oobCode'] == null) return;
    context.loaderOverlay.show();
    FirebaseAuth auth = FirebaseAuth.instance;
    String actionCode = deepLink.queryParameters['oobCode']!;
    try {
      await auth.checkActionCode(actionCode);
      await auth.applyActionCode(actionCode);
      await auth.currentUser?.reload();
      await Future.delayed(const Duration(seconds: 2));
    } on FirebaseAuthException catch (e) {
      SharedCode.showErrorDialog(context, 'Error', e.message ?? AppLocalizations.of(context).invalidCode);
    }
    context.loaderOverlay.hide();
    // ignore: use_build_context_synchronously
    SharedCode.checkRoute(context, FirebaseAuth.instance.currentUser, appRouter: appRouter);
  });

  // if (kIsWeb) {
  //   await FacebookAuth.i.webInitialize(
  //     appId: '3008904299255918',
  //     cookie: true,
  //     xfbml: true,
  //     version: 'v13.0',
  //   );
  // }

  // Get any initial links
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  return await bootstrap(() => Sizer(builder: (_, __, ___) {
        return MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          debugShowCheckedModeBanner: false,
          navigatorKey: NavigationService.navigatorKey,
          home: MyApp(
            language: language,
            isProduction: isProduction,
            appRouter: appRouter,
            deepLink: initialLink,
          ),
        );
      }));
}
