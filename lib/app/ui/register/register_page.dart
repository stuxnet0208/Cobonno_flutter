import 'package:auto_route/auto_route.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../common/shared_code.dart';
import '../../cubits/register/register_cubit.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../routes/router.gr.dart';
import '../../widgets/register_form_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _invitationController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.white, // Color for Android
        statusBarBrightness: Brightness.dark // Dark == white status bar -- for IOS.
        ));

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        systemOverlayStyle: SharedCode.lightStatusBar(),
      ),
      body: _isLoading
          ? const SizedBox.shrink()
          : BlocProvider(
              create: (context) => RegisterCubit(context.read<AuthRepository>()),
              child: RegisterFormWidget(
                  isRegister: true,
                  invitationController: _invitationController,
                  firstNameController: _firstNameController,
                  emailController: _emailController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  formKey: _formKey,
                  register: _register,
                  socialRegister: _socialRegister),
            ),
    );
  }

  Future<void> _socialRegister(BuildContext context, {required String type}) async {
    context.loaderOverlay.show();
    try {
      await context.read<RegisterCubit>().socialRegister(type: type, context: context);
      Future.delayed(const Duration(seconds: 2)).then((_) {
        SharedCode(context).handleAuthenticationRouting();
      });
    } catch (e) {
      String error = e.toString();
      //debugPrint(error);
      if (error == 'registered') {
        error = AppLocalizations.of(context).userRegistered;
      }
      SharedCode.showErrorDialog(context, 'Error', error);
      context.loaderOverlay.hide();
    }
  }

  Future<void> _register(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        context.read<RegisterCubit>().fieldChanged(
            _emailController.text,
            _passwordController.text,
            _firstNameController.text,
            null,
            _invitationController.text.trim().isEmpty ? null : _invitationController.text);
        context.loaderOverlay.show();
        await context.read<RegisterCubit>().register(context);
        Future.delayed(Duration.zero, () {
          // AutoRouter.of(context).replace(const VerifyPhoneRoute());
          AutoRouter.of(context).replace(const EmailVerificationRoute());
        });
      } catch (e) {
        context.read<RegisterCubit>().changeStatusToInitial();
        String error = e.toString();
        if (error == 'invalid-invitation-code') {
          error = AppLocalizations.of(context).invitationCodeInvalid;
        } else if (error == 'cancelled-by-user') {
          error = AppLocalizations.of(context).operationCancelledByUser;
        } else if (error == 'username-used') {
          error = AppLocalizations.of(context).usernameAlreadyUsed;
        }
        SharedCode.showErrorDialog(context, AppLocalizations.of(context).error, error);
      }
      context.loaderOverlay.hide();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _invitationController.dispose();
    super.dispose();
  }
}
