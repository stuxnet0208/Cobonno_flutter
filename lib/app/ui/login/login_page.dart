import 'package:auto_route/auto_route.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../cubits/login/login_cubit.dart';
import '../../repositories/auth/auth_repository.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_mouse_pointer.dart';
import '../../widgets/custom_password_field.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/social_login_buttons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isFacebookEnabled = false;
  bool isGoogleEnabled = false;
  bool isTwitterEnabled = false;

  @override
  void initState() {
    isFacebookEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_facebook');
    isGoogleEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_google');
    isTwitterEnabled = FirebaseRemoteConfig.instance.getBool('enable_sns_twitter');
    //debugPrint('facebook: $isFacebookEnabled, google $isGoogleEnabled, twitter $isTwitterEnabled');
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: BlocProvider(
              create: (context) => LoginCubit(context.read<AuthRepository>()),
              child: Column(
                children: [
                  const Spacer(),
                  _buildLoginForm(),
                  const Spacer(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
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
            key: _formKey,
            child: Column(
              children: [
                _buildEmailField(),
                SizedBox(height: 2.h),
                _buildPasswordField(),
                SizedBox(height: 5.h),
                BlocBuilder<LoginCubit, LoginState>(builder: (context, state) {
                  return Column(
                    children: [
                      _buildLoginButton(context),
                      SizedBox(height: 1.h),
                      if (isFacebookEnabled || isGoogleEnabled || isTwitterEnabled)
                        Text(AppLocalizations.of(context).or),
                      if (isFacebookEnabled || isGoogleEnabled || isTwitterEnabled)
                        SizedBox(height: 1.h),
                      if (isGoogleEnabled) _buildGoogleLogin(context),
                      if (isGoogleEnabled) SizedBox(height: 2.h),
                      if (isFacebookEnabled) _buildFacebookLogin(context),
                      if (isFacebookEnabled) SizedBox(height: 2.h),
                      if (isTwitterEnabled) _buildTwitterLogin(context),
                    ],
                  );
                }),
                SizedBox(height: 2.h),
                CustomMousePointer(
                  child: GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).navigate(const ForgotPasswordRoute());
                      },
                      child: Text(AppLocalizations.of(context).forgotPasswordQuestion,
                          style: Theme.of(context).textTheme.bodyText2)),
                ),
                SizedBox(height: 2.h),
                CustomMousePointer(
                  child: GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).replace(const RegisterRoute());
                      },
                      child: Text(AppLocalizations.of(context).noAccountQuestion,
                          style: Theme.of(context).textTheme.bodyText2)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGoogleLogin(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.google,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signInGoogle,
      onPressed: () {
        _socialLogin(context, type: 'google');
      },
    );
  }

  Widget _buildFacebookLogin(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.facebook,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signInFacebook,
      onPressed: () {
        _socialLogin(context, type: 'facebook');
      },
    );
  }

  Widget _buildTwitterLogin(BuildContext context) {
    return SocialLoginButton(
      buttonType: SocialLoginButtonType.twitter,
      borderRadius: 22.w,
      height: kIsWeb ? 55.0 : 45.0,
      text: AppLocalizations.of(context).signInTwitter,
      onPressed: () {
        _socialLogin(context, type: 'twitter');
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          _login(context);
        },
        child: Text(AppLocalizations.of(context).login));
  }

  Widget _buildPasswordField() {
    return CustomPasswordField(
      isWithIcon: true,
      label: AppLocalizations.of(context).password,
      controller: _passwordController,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      validator: SharedCode(context).emailValidator,
      textInputType: TextInputType.emailAddress,
      label: AppLocalizations.of(context).email,
      controller: _emailController,
    );
  }

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().emailChanged(_emailController.text);
      context.read<LoginCubit>().passwordChanged(_passwordController.text);
      context.loaderOverlay.show();
      try {
        await context.read<LoginCubit>().login(context);
        Future.delayed(const Duration(seconds: 2)).then((_) {
          SharedCode(context).handleAuthenticationRouting();
        });
      } catch (e) {
        SharedCode.showErrorDialog(context, 'Error', e.toString());
        context.loaderOverlay.hide();
      }
    }
  }

  Future<void> _socialLogin(BuildContext context, {required String type}) async {
    context.loaderOverlay.show();
    //debugPrint('clicking social login');
    try {
      await context.read<LoginCubit>().socialLogin(type: type, context: context);
      //debugPrint('logged in');
      Future.delayed(const Duration(seconds: 2)).then((_) {
        SharedCode(context).handleAuthenticationRouting();
      });
    } catch (e) {
      context.read<LoginCubit>().changeStatusToInitial();
      String error = e.toString();
      //debugPrint(error);
      if (error == 'not-registered') {
        error = AppLocalizations.of(context).userNotRegistered;
      } else if (error == 'cancelled-by-user') {
        error = AppLocalizations.of(context).operationCancelledByUser;
      }
      SharedCode.showErrorDialog(context, 'Error', error);
      context.loaderOverlay.hide();
    }
  }
}
