import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../app.dart';
import '../../common/shared_code.dart';
import '../../common/styles.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  late User _user;

  @override
  void initState() {
    _user = FirebaseAuth.instance.currentUser!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(AppLocalizations.of(context).emailVerification),
          leading: SharedCode.buildBackButtonToRegister(context)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Styles.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(_user.email ?? ''),
              Text(AppLocalizations.of(context).emailVerificationDescription),
              SizedBox(height: 2.h),
              ElevatedButton(
                  onPressed: () async {
                    context.loaderOverlay.show();
                    try {
                      // This are based on appstore and playstore
                      var actionCodeSettingsDev = ActionCodeSettings(
                        url: 'https://cobonno.page.link/verify?email=${_user.email}',
                        dynamicLinkDomain: 'cobonno.page.link',
                        androidPackageName: 'com.ardgets.cobonno.dev',
                        iOSBundleId: 'com.cobonno.app',
                        handleCodeInApp: true,
                        androidInstallApp: true,
                        androidMinimumVersion: '12',
                      );

                      var actionCodeSettings = ActionCodeSettings(
                        url: 'https://ardgets.page.link/verify?email=${_user.email}',
                        dynamicLinkDomain: 'ardgets.page.link',
                        androidPackageName: 'com.cobonno.app',
                        iOSBundleId: 'com.cobonno',
                        handleCodeInApp: true,
                        androidInstallApp: true,
                        androidMinimumVersion: "12",
                      );

                      bool isProduction = MyApp.getIsProduction(context);

                      await _user.sendEmailVerification(
                          isProduction ? actionCodeSettings : actionCodeSettingsDev);

                      // if (Platform.isAndroid) {
                      //   await _user.sendEmailVerification(isProduction ? actionCodeSettings : actionCodeSettingsDev);
                      // } else {
                      //   await _user.sendEmailVerification();
                      // }
                      Future.delayed(Duration.zero, () {
                        SharedCode.showSnackBar(
                            context,
                            'success',
                            AppLocalizations.of(context)
                                .sendEmailVerificationDescription(_user.email ?? ''));
                        context.loaderOverlay.hide();
                        // SharedCode(context)
                        //     .handleAuthenticationRouting(logoutContext: context, isLogout: true);
                      });
                    } catch (e) {
                      //debugPrint(e.toString());
                      context.loaderOverlay.hide();
                      SharedCode.showErrorDialog(
                          context, AppLocalizations.of(context).error, e.toString());
                    }
                  },
                  child: Text(AppLocalizations.of(context).sendEmailVerification)),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }
}
