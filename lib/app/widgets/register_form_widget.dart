import 'package:auto_route/auto_route.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../common/shared_code.dart';
import '../common/styles.dart';
import '../cubits/register/register_cubit.dart';
import '../repositories/parent/parent_repository.dart';
import '../routes/router.gr.dart';
import 'custom_mouse_pointer.dart';
import 'custom_password_field.dart';
import 'custom_text_field.dart';
import 'social_login_buttons.dart';

class RegisterFormWidget extends StatefulWidget {
  final TextEditingController invitationController;
  final TextEditingController firstNameController;
  final TextEditingController emailController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPasswordController;
  final GlobalKey formKey;
  final bool isFromSNS, isRegister;
  final Future<void> Function(BuildContext context) register;
  final Future<void> Function(BuildContext context, {required String type})? socialRegister;

  const RegisterFormWidget(
      {Key? key,
      required this.invitationController,
      required this.firstNameController,
      required this.emailController,
      this.passwordController,
      this.confirmPasswordController,
      required this.formKey,
      this.isFromSNS = false,
      this.isRegister = false,
      required this.register,
      this.socialRegister})
      : super(key: key);

  @override
  State<RegisterFormWidget> createState() => _RegisterFormWidgetState();
}

class _RegisterFormWidgetState extends State<RegisterFormWidget> {
  bool isFacebookEnabled = false;
  bool isGoogleEnabled = false;
  bool isTwitterEnabled = false;
  final ValueNotifier<String?> _errorMessage = ValueNotifier(null);
  final ValueNotifier<String?> _errorMessageUsername = ValueNotifier(null);

  @override
  void initState() {
    isFacebookEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_facebook');
    isGoogleEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_google');
    isTwitterEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_twitter');
    //debugPrint('facebook: $isFacebookEnabled, google $isGoogleEnabled, twitter $isTwitterEnabled');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            children: [
              const Spacer(),
              _buildBody(),
              const Spacer(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(Styles.defaultPadding),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
            child: Image.asset('assets/cobonno.png'),
          ),
          SizedBox(height: 11.h),
          Form(
            key: widget.formKey,
            child: Column(
              children: [
                ValueListenableBuilder(
                    valueListenable: _errorMessageUsername,
                    builder: (_, __, ___) {
                      return CustomTextField(
                        label: AppLocalizations.of(context).name,
                        controller: widget.firstNameController,
                        onChanged: (s) {
                          if (s != null) {
                            _errorMessageUsername.value = SharedCode(context).usernameValidator(s);
                            if (_errorMessageUsername.value == null) {
                              ParentRepository().checkIfParentUsernameValid(s).then((value) {
                                //debugPrint('is email valid $value');
                                if (!value) {
                                  _errorMessageUsername.value =
                                      AppLocalizations.of(context).usernameAlreadyUsed;
                                }
                              });
                            }
                          }
                          return null;
                        },
                        validator: (_) => _errorMessageUsername.value,
                      );
                    }),
                SizedBox(height: 2.h),
                ValueListenableBuilder(
                  valueListenable: _errorMessage,
                  builder: (_, __, ___) {
                    //debugPrint('rebuild text form field email');
                    return CustomTextField(
                      label: AppLocalizations.of(context).email,
                      controller: widget.emailController,
                      enabled: widget.isRegister,
                      textInputType: TextInputType.emailAddress,
                      onChanged: (s) {
                        if (s != null) {
                          _errorMessage.value = SharedCode(context).emailValidator(s);
                          if (_errorMessage.value == null) {
                            ParentRepository().checkIfEmailRegistered(s).then((value) {
                              //debugPrint('is email valid $value');
                              if (value) {
                                _errorMessage.value = AppLocalizations.of(context).emailAlreadyUsed;
                              }
                            });
                          }
                        }
                        return null;
                      },
                      validator: (_) => _errorMessage.value,
                    );
                  },
                ),
                SizedBox(height: 2.h),
                if (!widget.isFromSNS)
                  CustomPasswordField(
                    isWithIcon: true,
                    label: AppLocalizations.of(context).password,
                    controller: widget.passwordController!,
                  ),
                if (!widget.isFromSNS) SizedBox(height: 2.h),
                if (!widget.isFromSNS)
                  CustomPasswordField(
                    isWithIcon: true,
                    label: AppLocalizations.of(context).reenterPassword,
                    controller: widget.confirmPasswordController!,
                    validator: (s) {
                      return SharedCode(context).passwordConfirmValidator(
                          widget.confirmPasswordController!.text, widget.passwordController!.text);
                    },
                  ),
                if (FirebaseRemoteConfig.instance.getBool('signup_with_invitation'))
                  SizedBox(height: 2.h),
                if (FirebaseRemoteConfig.instance.getBool('signup_with_invitation'))
                  CustomTextField(
                    label: AppLocalizations.of(context).invitationCode,
                    controller: widget.invitationController,
                    textInputType: TextInputType.text,
                  ),
                SizedBox(height: 5.h),
                widget.isFromSNS
                    ? Column(
                        children: [
                          _buildRegisterButton(context),
                        ],
                      )
                    : BlocBuilder<RegisterCubit, RegisterState>(builder: (context, state) {
                        return Column(
                          children: [
                            _buildRegisterButton(context),
                            SizedBox(height: 1.h),
                            if (isFacebookEnabled || isGoogleEnabled || isTwitterEnabled)
                              Text(AppLocalizations.of(context).or),
                            if (isFacebookEnabled || isGoogleEnabled || isTwitterEnabled)
                              SizedBox(height: 1.h),
                            if (isGoogleEnabled) _buildGoogleRegister(context),
                            if (isGoogleEnabled) SizedBox(height: 2.h),
                            if (isFacebookEnabled) _buildFacebookRegister(context),
                            if (isFacebookEnabled) SizedBox(height: 2.h),
                            if (isTwitterEnabled) _buildTwitterRegister(context),
                          ],
                        );
                      }),
                if (!widget.isFromSNS) SizedBox(height: 2.h),
                if (!widget.isFromSNS)
                  CustomMousePointer(
                    child: GestureDetector(
                        onTap: () {
                          AutoRouter.of(context).replace(const LoginRoute());
                        },
                        child: Text(AppLocalizations.of(context).haveAccountQuestion,
                            style: Theme.of(context).textTheme.bodyText2)),
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoogleRegister(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.google,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signUpGoogle,
      onPressed: () {
        if (widget.socialRegister != null) {
          widget.socialRegister!(context, type: 'google');
        }
      },
    );
  }

  Widget _buildFacebookRegister(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.facebook,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signUpFacebook,
      onPressed: () {
        if (widget.socialRegister != null) {
          widget.socialRegister!(context, type: 'facebook');
        }
      },
    );
  }

  Widget _buildTwitterRegister(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.twitter,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signUpTwitter,
      onPressed: () {
        if (widget.socialRegister != null) {
          widget.socialRegister!(context, type: 'twitter');
        }
      },
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          widget.register(context);
        },
        child: Text(widget.isFromSNS
            ? AppLocalizations.of(context).submit
            : AppLocalizations.of(context).create));
  }
}
