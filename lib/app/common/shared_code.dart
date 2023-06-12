import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/app.dart';
import 'package:cobonno/app/widgets/custom_info_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../l10n/l10n.dart';
import '../routes/router.gr.dart';
import '../widgets/custom_alert_dialog.dart';
import '../widgets/custom_error_dialog.dart';
import '../widgets/reconnecting_widget.dart';
import 'app_theme_data.dart';

class SharedCode {
  final BuildContext context;

  SharedCode(this.context);

  static String userImageUrl =
      'https://i.pinimg.com/originals/85/01/47/850147cf54b721cf3e4b370724a3ce7a.jpg';
  static String kidImageUrl =
      'https://i.pinimg.com/736x/6c/02/01/6c0201d4c1d6a259646e9e52cb36a649.jpg';
  static String storageEndpoint =
      'https://firebasestorage.googleapis.com/v0/b/cobonno-museum.appspot.com/o';

  static RegExp urlRegExp = RegExp(
      r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");

  static SystemUiOverlayStyle lightStatusBar() {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      systemNavigationBarColor: Color(0xFF000000),
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    );
  }

  static SystemUiOverlayStyle darkStatusBar() {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  static ThemeData datePickerTheme(BuildContext context) {
    return AppThemeData.getTheme(context).copyWith(
        textTheme: TextTheme(
      subtitle2: TextStyle(
          fontSize: 12.sp,
          color: Colors.black,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1),
      bodyText1: TextStyle(
          fontSize: 12.sp,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5),
      bodyText2: TextStyle(
          fontSize: 10.sp,
          color: Colors.black,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25),
    ));
  }

  String? emptyValidator(value) {
    return value.toString().trim().isEmpty
        ? AppLocalizations.of(context).emptyValidation
        : null;
  }

  String? usernameValidator(String? value) {
    final allowedCharactersRegex = RegExp(r'^[a-zA-Z0-9_\.]+$');
    final multiBytesRegex = RegExp(
        r'^[\u3000-\u303f]|[\u3040-\u309f]|[\u30a0-\u30ff]|[\uff00-\uffef]|[\u4e00-\u9faf]|[\u3400-\u4dbf]+/u');

    String validation = AppLocalizations.of(context).usernameValidation;

    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context).emptyValidation;
    }

    String specialCharValue = value.replaceAll(multiBytesRegex, '');
    specialCharValue = specialCharValue.replaceAll(allowedCharactersRegex, '');

    if (allowedCharactersRegex.hasMatch(value)) {
      return null;
    }

    if (multiBytesRegex.stringMatch(value) != null) {
      validation +=
          " ${AppLocalizations.of(context).alphanumericUsernameValidation}";
    }

    if (specialCharValue.trim().isNotEmpty) {
      validation +=
          " ${AppLocalizations.of(context).specialCharUsernameValidation}";
    }

    return validation;
  }

  String? passwordValidator(value) {
    return value.toString().length < 6
        ? AppLocalizations.of(context).passwordValidation
        : null;
  }

  String? emailValidator(value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return !emailValid ? AppLocalizations.of(context).emailValidation : null;
  }

  static bool emailValidatorBoolean(value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    return emailValid;
  }

  static bool phoneValidatorBoolean(value) =>
      RegExp(r'^[\+]?[(]?[0-9]{3}[)]?[-\s\.]?[0-9]{3}[-\s\.]?[0-9]{4,6}$')
          .hasMatch(value);

  String? passwordConfirmValidator(String value1, String value2) {
    if (value1.isEmpty || value2.isEmpty) {
      return AppLocalizations.of(context).confirmPasswordValidation;
    } else {
      return value2 != value1
          ? AppLocalizations.of(context).confirmPasswordValidation
          : null;
    }
  }

  Future<void> handleAuthenticationRouting(
      {BuildContext? logoutContext,
      AppRouter? appRouter,
      bool isLogout = false,
      bool emailVerified = false}) async {
    //debugPrint('handle auth routing 1 $isLogout');
    if (isLogout && logoutContext != null) {
      //debugPrint('handle auth routing');
      await logout();
      Future.delayed(Duration.zero, () {
        logoutContext.loaderOverlay.hide();
        AutoRouter.of(logoutContext).pushAndPopUntil(const LoginRoute(),
            predicate: (Route<dynamic> route) => false);
      });
    } else {
      //debugPrint('handle auth routing 2');
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        //debugPrint('handle auth routing 3');
        checkRoute(context, user,
            appRouter: appRouter, emailVerified: emailVerified);
      });
    }
  }

  static void checkRoute(BuildContext context, User? user,
      {AppRouter? appRouter, bool emailVerified = false}) async {
    appRouter = MyApp.getAppRouter(context) ?? appRouter;
    StackRouter router = appRouter ?? AutoRouter.of(context);
    //debugPrint('user check route $user');
    if (user == null) {
      if (appRouter != null) {
        //debugPrint('router name: ${appRouter.current.name}');
        if (appRouter.current.name != 'LanguageSelectRoute') {
          if (appRouter.current.name == 'SplashRoute') {
            router.pushAndPopUntil(const LanguageSelectRoute(),
                predicate: (Route<dynamic> route) => false);
          } else {
            router.pushAndPopUntil(const LoginRoute(),
                predicate: (Route<dynamic> route) => false);
          }
        }
      } else {
        router.pushAndPopUntil(const LoginRoute(),
            predicate: (Route<dynamic> route) => false);
      }
    } else {
      //debugPrint('user email verified: ${user.emailVerified}');
      //debugPrint('user metadata: ${user.metadata}');
      //debugPrint('user info: ${user.providerData.first.providerId}');
      try {
        if (user.providerData.first.providerId == 'phone' ||
            user.providerData.first.providerId == 'password') {
          // disable phone verification
          // if (user.phoneNumber != null && user.phoneNumber!.trim().isNotEmpty) {
          //   router.pushAndPopUntil(const HomeRoute(),
          //    predicate: (Route<dynamic> route) => false);
          // } else {
          //   router.replace(const VerifyPhoneRoute());
          // }

          // enable email verification
          if (user.emailVerified || emailVerified) {
            router.pushAndPopUntil(const HomeRoute(),
                predicate: (Route<dynamic> route) => false);
          } else {
            router.replace(const EmailVerificationRoute());
          }
        } else {
          String displayName = user.displayName ?? '';
          //debugPrint('display name ${user.displayName}');
          if (displayName.trim().isNotEmpty) {
            router.pushAndPopUntil(const HomeRoute(),
                predicate: (Route<dynamic> route) => false);
          } else {
            router.replace(IdentityFormRoute(user: user));
          }
        }
      } catch (e) {
        // router.replace(const VerifyPhoneRoute());
        router.replace(const EmailVerificationRoute());
      }
    }

    if (context.loaderOverlay.visible) {
      if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
        context.loaderOverlay.hide();
      }
    }
  }

  static void showAlertDialog(
      BuildContext context, String title, String content, Function onYesTap,
      [String? noTitle, String? yesTitle, bool isNo = true]) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomAlertDialog(
            title: title,
            content: content,
            onYesTap: onYesTap,
            context: context,
            noTitle: noTitle,
            yesTitle: yesTitle,
            isNo: isNo,
          );
        });
  }

  static void showErrorDialog(
      BuildContext context, String title, String content) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomErrorDialog(title: title, content: content);
        });
  }

  static void showInfoDialog(
      BuildContext context, String title, String content, String titleButton) {
    showDialog(
        context: context,
        builder: (context) {
          return CustomInfoDialog(
            title: title,
            content: content,
            titleButton: titleButton,
          );
        });
  }

  static void showSnackBar(BuildContext context, String status, String content,
      {Duration? duration}) {
    Color color = Colors.green;
    switch (status) {
      case 'success':
        color = Colors.green;
        break;
      case 'error':
        color = Colors.red;
        break;
    }
    SnackBar snackBar = SnackBar(
      content: Text(content, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      duration: duration ?? const Duration(milliseconds: 4000),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static String loremIpsum() {
    return 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ullamcorper felis et nisl dignissim, id rhoncus ex bibendum.';
  }

  static Widget buildBackButtonToRegister(BuildContext context) {
    return IconButton(
        onPressed: () async {
          await logout();
          Future.delayed(Duration.zero, () {
            AutoRouter.of(context).replace(const RegisterRoute());
          });
        },
        icon: const Icon(Icons.arrow_back, semanticLabel: 'Back'));
  }

  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await logoutSocial();
  }

  static Future<void> logoutSocial() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    try {
      await FacebookAuth.instance.logOut();
    } catch (_) {}
  }

  Future<void> initDynamicLinks({AppRouter? appRouter}) async {
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      //debugPrint('deep link init $deepLink');
      handleDeepLink(deepLink, appRouter: appRouter);
    } else {
      //debugPrint('deep link null and user: ${FirebaseAuth.instance.currentUser}');
      handleAuthenticationRouting(appRouter: appRouter);
    }

    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData? dynamicLink) async {
      // debugPrint('dynamic link $dynamicLink');
      final Uri? deepLink = dynamicLink?.link;
      handleDeepLink(deepLink, appRouter: appRouter);
    }, onError: (e) async {
      SharedCode.showErrorDialog(context, 'Error', e.toString());
      context.loaderOverlay.hide();
    });
  }

  Future<void> handleDeepLink(Uri? deepLink, {AppRouter? appRouter}) async {
    //debugPrint('testing');
    context.loaderOverlay.show();
    debugPrint('uri deep link $deepLink');

    if (deepLink != null) {
      try {
        FirebaseAuth auth = FirebaseAuth.instance;

        //Get actionCode from the dynamicLink
        var actionCode = deepLink.queryParameters['oobCode'];
        //debugPrint('action code $actionCode');
        //debugPrint('deep link ${deepLink.toString()}');

        if (actionCode != null) {
          try {
            //debugPrint('action code not null');
            await auth.checkActionCode(actionCode);
            //debugPrint('action code not null 2');
            await auth.applyActionCode(actionCode);
            //debugPrint('action code not null 3');

            // If successful, reload the user:
            await auth.currentUser?.reload();
            await Future.delayed(const Duration(seconds: 2));
            //debugPrint('current user ${FirebaseAuth.instance.currentUser?.emailVerified}');
            //debugPrint('success auth email ${auth.currentUser?.emailVerified}');
            Future.delayed(Duration.zero, () {
              handleAuthenticationRouting(
                  appRouter: appRouter, emailVerified: true);
            });
          } on FirebaseAuthException catch (e) {
            SharedCode.showErrorDialog(context, 'Error',
                e.message ?? AppLocalizations.of(context).invalidCode);
            SharedCode.checkRoute(context, FirebaseAuth.instance.currentUser,
                appRouter: appRouter);
          }
        }
      } catch (e) {
        //debugPrint('error catch ${e.toString()}');
        SharedCode.showErrorDialog(context, 'Error', e.toString());
        context.loaderOverlay.hide();
      }
    }
  }
}
