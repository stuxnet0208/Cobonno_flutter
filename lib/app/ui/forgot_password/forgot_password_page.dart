import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../data/services/auth_service.dart';
import '../../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text(AppLocalizations.of(context).forgotPassword,
              style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          SizedBox(height: 2.h),
          Text(AppLocalizations.of(context).enterEmail,
              style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center),
          SizedBox(height: 3.h),
          CustomTextField(
              textInputType: TextInputType.emailAddress,
              label: AppLocalizations.of(context).email,
              controller: _emailController,
              validator: SharedCode(context).emailValidator),
          SizedBox(height: 6.h),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _forgotPassword();
                }
              },
              child: Text(AppLocalizations.of(context).submit))
        ],
      ),
    );
  }

  Future<void> _forgotPassword() async {
    context.loaderOverlay.show();
    try {
      await AuthService().sendResetPasswordEmail(context, _emailController.text);
      Future.delayed(Duration.zero, () {
        AutoRouter.of(context).pop();
        SharedCode.showSnackBar(context, 'success',
            AppLocalizations.of(context).forgotPasswordSent(_emailController.text),
            duration: const Duration(seconds: 3));
      });
    } catch (e) {
      SharedCode.showErrorDialog(context, AppLocalizations.of(context).error, e.toString());
    }
    context.loaderOverlay.hide();
  }
}
