import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:sizer/sizer.dart';

import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../routes/router.gr.dart';

class VerifyPhonePage extends StatefulWidget {
  const VerifyPhonePage({Key? key}) : super(key: key);

  @override
  State<VerifyPhonePage> createState() => _VerifyPhonePageState();
}

class _VerifyPhonePageState extends State<VerifyPhonePage> {
  String _phoneNumber = '';
  bool _isValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(''), leading: SharedCode.buildBackButtonToRegister(context)),
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
        Text(AppLocalizations.of(context).verifyPhoneTitle,
            style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
        SizedBox(height: 2.h),
        Text(AppLocalizations.of(context).verifyPhoneDescription,
            style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center),
        SizedBox(height: 3.h),
        _buildPhoneField(),
        SizedBox(height: 3.h),
        ElevatedButton(
            onPressed: () {
              if (_isValid) {
                AutoRouter.of(context).navigate(OtpVerificationRoute(phoneNumber: _phoneNumber));
              } else {
                SharedCode.showSnackBar(
                    context, 'error', AppLocalizations.of(context).invalidPhoneNumber);
              }
            },
            child: Text(AppLocalizations.of(context).next))
      ],
    );
  }

  Widget _buildPhoneField() {
    return IntlPhoneField(
      invalidNumberMessage: AppLocalizations.of(context).invalidPhoneNumber,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context).phoneNumber,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: Colors.black, width: 1.0),
        ),
      ),
      showCountryFlag: false,
      initialCountryCode: 'JP',
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      dropdownTextStyle: Theme.of(context).textTheme.subtitle2,
      disableLengthCheck: true,
      style: Theme.of(context).textTheme.subtitle2,
      pickerDialogStyle: PickerDialogStyle(
          countryCodeStyle: Theme.of(context).textTheme.subtitle2,
          countryNameStyle: Theme.of(context).textTheme.subtitle2,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          searchFieldInputDecoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
            hintText: AppLocalizations.of(context).searchCountry,
            hintStyle: TextStyle(color: ColorValues.darkGrey, fontSize: 14.sp),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: Colors.black, width: 1.0),
            ),
          )),
      onChanged: (phone) {
        if (phone.number.trim().isEmpty) {
          _isValid = false;
        } else {
          _isValid = true;
        }
        _phoneNumber = phone.completeNumber;
      },
    );
  }
}
