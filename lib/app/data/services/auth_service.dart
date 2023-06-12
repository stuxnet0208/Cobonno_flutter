import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> sendResetPasswordEmail(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw handleAuthErrorCodes(context, e.code);
    }
  }

  static String handleAuthErrorCodes(BuildContext context, String code) {
    switch (code) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return AppLocalizations.of(context).emailAlreadyUsed;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return AppLocalizations.of(context).wrongPassword;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return AppLocalizations.of(context).userNotFound;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return AppLocalizations.of(context).userDisabled;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return AppLocalizations.of(context).tooManyRequests;
      case "ERROR_OPERATION_NOT_ALLOWED":
        return AppLocalizations.of(context).serverError;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return AppLocalizations.of(context).invalidEmail;
      default:
        return AppLocalizations.of(context).failedError;
    }
  }
}
