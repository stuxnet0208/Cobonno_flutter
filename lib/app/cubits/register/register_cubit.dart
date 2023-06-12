import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../repositories/repositories.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit(this._authRepository) : super(RegisterState.initial());

  void fieldChanged(String email, String password, String name,
      String? phoneNumber, String? invitationCode) {
    emit(state.copyWith(
        phoneNumber: phoneNumber,
        email: email,
        invitationCode: invitationCode,
        name: name,
        password: password,
        status: RegisterStatus.initial));
  }

  Future<void> register(BuildContext context) async {
    if (state.status == RegisterStatus.submitting) return;
    emit(state.copyWith(status: RegisterStatus.submitting));

    bool isUsernameValid =
        await ParentRepository().checkIfParentUsernameValid(state.name);
    if (!isUsernameValid) {
      throw 'username-used';
    }

    try {
      await _authRepository.register(
          email: state.email,
          password: state.password,
          name: state.name,
          invitationCode: state.invitationCode,
          phoneNumber: state.phoneNumber,
          context: context);
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      throw e.toString();
    }
  }

  void changeStatusToInitial() {
    emit(state.copyWith(status: RegisterStatus.initial));
  }

  Future<void> socialRegister(
      {required String type, required BuildContext context}) async {
    if (state.status == RegisterStatus.submitting) return;
    emit(state.copyWith(status: RegisterStatus.submitting));

    late UserCredential userCredential;
    switch (type) {
      case 'google':
        userCredential = await AuthRepository.fetchGoogleUserCredential();
        break;
      case 'facebook':
        userCredential =
            await AuthRepository.fetchFacebookUserCredential(context);
        break;
      case 'twitter':
        userCredential = await AuthRepository.fetchTwitterUserCredential();
        break;
    }

    try {
      User? user =
          await _authRepository.socialAuth(userCredential: userCredential);
      if (user == null) {
        emit(state.copyWith(status: RegisterStatus.initial));
      } else {
        await user.updateDisplayName(null);
        emit(state.copyWith(status: RegisterStatus.success));
      }
    } catch (_) {
      emit(state.copyWith(status: RegisterStatus.initial));
      rethrow;
    }
  }
}
