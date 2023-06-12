import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../common/shared_code.dart';
import '../../data/models/user_model.dart';
import '../../data/services/auth_service.dart';
import '../../repositories/repositories.dart';
import '../../routes/router.gr.dart';
import '../../widgets/register_form_widget.dart';

class IdentityFormPage extends StatefulWidget {
  const IdentityFormPage({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  State<IdentityFormPage> createState() => _IdentityFormPageState();
}

class _IdentityFormPageState extends State<IdentityFormPage> {
  final TextEditingController _invitationController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = true;

  @override
  void initState() {
    FirebaseRemoteConfig.instance.fetchAndActivate().then((value) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      } else {
        _isLoading = false;
      }
    });
    _emailController.text = widget.user.email ?? '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar:
            AppBar(title: const Text(''), leading: SharedCode.buildBackButtonToRegister(context)),
        body: _isLoading
            ? const SizedBox.shrink()
            : RegisterFormWidget(
                invitationController: _invitationController,
                firstNameController: _userNameController,
                emailController: _emailController,
                formKey: _formKey,
                register: _register,
                isFromSNS: true));
  }

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        context.loaderOverlay.show();

        bool isUsernameValid =
            await ParentRepository().checkIfParentUsernameValid(_userNameController.text);
        if (!isUsernameValid) {
          Future.delayed(Duration.zero, () {
            SharedCode.showErrorDialog(context, AppLocalizations.of(context).error,
                AppLocalizations.of(context).usernameAlreadyUsed);
          });
          context.loaderOverlay.hide();
          return;
        }

        UserModel userModel = UserModel(
          id: widget.user.uid,
          email: _emailController.text,
          username: _userNameController.text,
          invitationCode:
              _invitationController.text.trim().isEmpty ? null : _invitationController.text,
          phoneNumber: widget.user.phoneNumber,
          favorites: const [],
          patronizeds: const [],
          momentsReported: const [],
        );

        final remoteConfig = FirebaseRemoteConfig.instance;
        await remoteConfig.fetchAndActivate();
        String invitationConfig = remoteConfig.getString('signup_invitation_code');

        //debugPrint('user model to json: ${userModel.toJson()}');

        if (userModel.invitationCode != null &&
            invitationConfig.toLowerCase() != userModel.invitationCode?.toLowerCase()) {
          throw 'invalid-invitation-code';
        }

        await ParentRepository().updateParent(userModel);
        Future.delayed(Duration.zero, () {
          AutoRouter.of(context)
              .pushAndPopUntil(const HomeRoute(), predicate: (Route<dynamic> route) => false);
        });
      } on FirebaseAuthException catch (e) {
        String error = AuthService.handleAuthErrorCodes(context, e.code);
        SharedCode.showErrorDialog(context, 'Error', error);
      } catch (e) {
        String error = e.toString();
        if (error == 'invalid-invitation-code') {
          error = AppLocalizations.of(context).invitationCodeInvalid;
        }
        SharedCode.showErrorDialog(context, 'Error', error);
      }
      context.loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _invitationController.dispose();
    super.dispose();
  }
}
