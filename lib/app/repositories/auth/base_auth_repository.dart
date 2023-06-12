import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';

abstract class BaseAuthRepository {
  Stream<auth.User?> get user;
  Future<auth.User?> socialAuth(
      {bool isLogin = false, required auth.UserCredential userCredential});

  Future<auth.User> login({
    required BuildContext context,
    required String email,
    required String password,
  });

  Future<auth.User> register({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<void> signOut();

  Future<void> removeAccount(BuildContext context);

  Future<bool> isHasChildren();
}
