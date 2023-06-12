import 'package:cobonno/app/common/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../common/color_values.dart';

class CustomInfoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String titleButton;

  const CustomInfoDialog(
      {Key? key,
      required this.title,
      required this.content,
      required this.titleButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20))),
      elevation: 3.0,
      backgroundColor: ColorValues.primaryRed,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Container(
      // height: 50.h,
      margin: const EdgeInsets.all(20),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context).firstOfAll,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              AppLocalizations.of(context).registerChildPopUp,
              style: TextStyle(
                  fontSize: 15.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 2.h,
            ),
            Image.asset('assets/register_child.png'),
            SizedBox(
              height: 4.h,
            ),
            SizedBox(
              width: 40.w,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: Text(
                  AppLocalizations.of(context).ok,
                  style: TextStyle(
                      fontSize: 15.sp,
                      color: ColorValues.primaryRed,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ]),
    );
  }
}
