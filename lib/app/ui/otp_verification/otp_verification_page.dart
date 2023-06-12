import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sizer/sizer.dart';

import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../data/services/database_service.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_mouse_pointer.dart';

class OtpVerificationPage extends StatefulWidget {
  const OtpVerificationPage({Key? key, required this.phoneNumber}) : super(key: key);
  final String phoneNumber;

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _otpController = TextEditingController();
  String? verificationIdDevice;
  int? resendTokenDevice;
  Timer? _timer;
  late Duration _start;
  final int _otpDuration = 30;
  ConfirmationResult? _confirmationResult;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _start = const Duration(seconds: 30);
    _verifyPhone();
  }

  void _startTimer() {
    _start = const Duration(seconds: 30);
    if (_timer != null) {
      _timer?.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_start > const Duration(seconds: 0)) {
          _start -= const Duration(seconds: 1);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    context.loaderOverlay.show();
    //debugPrint('phone number: ${widget.phoneNumber}');

    if (kIsWeb) {
      _confirmationResult = await _auth.signInWithPhoneNumber(
          widget.phoneNumber,
          RecaptchaVerifier(
            container: null,
            size: RecaptchaVerifierSize.compact,
            theme: RecaptchaVerifierTheme.dark,
            onSuccess: () {
              SharedCode.showSnackBar(context, 'success', AppLocalizations.of(context).otpSent);
              context.loaderOverlay.hide();
            },
            onError: (FirebaseAuthException e) {
              //debugPrint(e.toString());
              SharedCode.showSnackBar(
                  context, 'error', e.message ?? AppLocalizations.of(context).error);
              context.loaderOverlay.hide();
            },
            onExpired: () {
              SharedCode.showSnackBar(
                  context, 'error', AppLocalizations.of(context).captchaExpired);
              context.loaderOverlay.hide();
            },
            auth: FirebaseAuthPlatform.instance,
          ));
      context.loaderOverlay.hide();
    } else {
      await _auth.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: resendTokenDevice,
        timeout: Duration(seconds: _otpDuration),
        verificationCompleted: (PhoneAuthCredential credential) {
          SharedCode.showSnackBar(context, 'success', AppLocalizations.of(context).otpSent);
          context.loaderOverlay.hide();
        },
        verificationFailed: (FirebaseAuthException e) {
          SharedCode.showSnackBar(
              context, 'error', e.message ?? AppLocalizations.of(context).error);
          context.loaderOverlay.hide();
        },
        codeSent: (String verificationId, int? resendToken) {
          resendTokenDevice = resendToken;
          verificationIdDevice = verificationId;
          SharedCode.showSnackBar(context, 'success', AppLocalizations.of(context).otpSent);
          _startTimer();
          context.loaderOverlay.hide();
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<void> _verifyOtp() async {
    if (verificationIdDevice != null || kIsWeb) {
      context.loaderOverlay.show();
      try {
        PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
            verificationId: kIsWeb ? _confirmationResult!.verificationId : verificationIdDevice!,
            smsCode: _otpController.text);

        // Link child with the credential
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.updatePhoneNumber(phoneAuthCredential);
          await DatabaseService().setUserPhone(user.uid, widget.phoneNumber);
          Future.delayed(Duration.zero, () {
            SharedCode.showSnackBar(context, 'success', AppLocalizations.of(context).phoneVerified);
            AutoRouter.of(context)
                .pushAndPopUntil(const HomeRoute(), predicate: (Route<dynamic> route) => false);
          });
        } else {
          Future.delayed(Duration.zero, () {
            SharedCode.showErrorDialog(context, AppLocalizations.of(context).error,
                AppLocalizations.of(context).notLoggedIn);
          });
        }
      } catch (e) {
        String error = e.toString();
        int index = error.indexOf(']');
        error = error.substring(index + 1, error.length - 1);
        SharedCode.showErrorDialog(context, AppLocalizations.of(context).error, error);
      }
      context.loaderOverlay.hide();
    } else {
      SharedCode.showSnackBar(context, 'error', AppLocalizations.of(context).notSentOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Padding(
        padding: const EdgeInsets.all(Styles.defaultPadding),
        child: Column(
          children: [
            Expanded(child: Container()),
            _buildBody(),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Text(AppLocalizations.of(context).phoneVerification,
            style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        SizedBox(height: 2.h),
        Text(AppLocalizations.of(context).enterOtpCode,
            style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center),
        SizedBox(height: 5.h),
        _buildPinCodeField(),
        SizedBox(height: 5.h),
        Text(AppLocalizations.of(context).notReceivedCode,
            style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center),
        _buildResendCode(),
        SizedBox(height: 5.h),
        ElevatedButton(
            onPressed: () {
              _verifyOtp();
            },
            child: Text(AppLocalizations.of(context).verify))
      ],
    );
  }

  Widget _buildResendCode() {
    final minutes = _start.inMinutes;
    final seconds = _start.inSeconds - minutes * Duration.secondsPerMinute;
    return CustomMousePointer(
      child: GestureDetector(
        onTap: () async {
          if (seconds == 0 || kIsWeb) {
            await _verifyPhone();
          }
        },
        child: Text(
            kIsWeb
                ? AppLocalizations.of(context).resendCode
                : (seconds == 0 ? AppLocalizations.of(context).resendCode : '$minutes:$seconds'),
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildPinCodeField() {
    return PinCodeTextField(
      appContext: context,
      controller: _otpController,
      length: 6,
      keyboardType: TextInputType.number,
      cursorColor: Theme.of(context).primaryColor,
      obscureText: false,
      textStyle: Theme.of(context).textTheme.titleMedium,
      hintStyle: Theme.of(context).textTheme.titleMedium,
      pastedTextStyle: Theme.of(context).textTheme.titleMedium,
      animationType: AnimationType.fade,
      animationDuration: const Duration(milliseconds: 300),
      onChanged: (value) {},
    );
  }
}
