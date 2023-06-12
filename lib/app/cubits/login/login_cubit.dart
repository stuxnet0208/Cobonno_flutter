import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/shared_code.dart';
import '../../repositories/auth/auth_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;
  LoginCubit(this._authRepository) : super(LoginState.initial());

  void emailChanged(String value) {
    emit(state.copyWith(email: value, status: LoginStatus.initial));
  }

  void passwordChanged(String value) {
    emit(state.copyWith(password: value, status: LoginStatus.initial));
  }

  void changeStatusToInitial() {
    emit(state.copyWith(status: LoginStatus.initial));
  }

  Future<void> login(BuildContext context) async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));
    await _authRepository.login(email: state.email, password: state.password, context: context);
    emit(state.copyWith(status: LoginStatus.success));
  }

  Future<void> socialLogin({required String type, required BuildContext context}) async {
    if (state.status == LoginStatus.submitting) return;
    emit(state.copyWith(status: LoginStatus.submitting));

    await SharedCode.logoutSocial();

    late UserCredential userCredential;
    switch (type) {
      case 'google':
        userCredential = await AuthRepository.fetchGoogleUserCredential();
        break;
      case 'facebook':
        userCredential = await AuthRepository.fetchFacebookUserCredential(context);
        break;
      case 'twitter':
        userCredential = await AuthRepository.fetchTwitterUserCredential();
        break;
    }

    try {
      User? user = await _authRepository.socialAuth(isLogin: true, userCredential: userCredential);
      if (user == null) {
        emit(state.copyWith(status: LoginStatus.initial));
      } else {
        emit(state.copyWith(status: LoginStatus.success));
      }
    } catch (_) {
      emit(state.copyWith(status: LoginStatus.initial));
      rethrow;
    }
  }
}
