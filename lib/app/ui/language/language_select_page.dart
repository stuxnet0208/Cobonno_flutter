import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/common/color_values.dart';
import 'package:cobonno/app/routes/router.gr.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../app.dart';
import '../../common/shared_preferences_service.dart';
import 'package:loader_overlay/loader_overlay.dart';

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage> {
  final List<String> _languages = ['日本語', 'English'];
  final List<String> _languageCode = ['ja', 'en'];
  final List<String> _languageSelect = ['言語を選んでください', 'Select your language'];

  String _language = '';

  @override
  void initState() {
    SharedPreferencesService().getLanguage().then((value) {
      if (mounted) {
        setState(() {
          _language = value;
        });
      } else {
        _language = value;
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.primaryRed,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Spacer(),
                    for (var i in _languageSelect)
                      Text(i,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 13.sp)),
                    SizedBox(height: 6.h),
                    for (int i = 0; i < _languages.length; i++)
                      Column(
                        children: [
                          SizedBox(height: 5.h),
                          _buildLanguageButton(context, _languages[i], i),
                        ],
                      ),
                  ],
                ),
              ),
              const Expanded(flex: 2, child: SizedBox.shrink())
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageButton(BuildContext context, String title, int index) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.white),
        onPressed: () {
          context.loaderOverlay.show();
          changeLanguage(context, index);
        },
        child: Text(
          title,
          style: TextStyle(color: ColorValues.primaryRed, fontSize: 13.sp),
        ));
  }

  Future<void> changeLanguage(BuildContext context, int index) async {
    await SharedPreferencesService().setLanguage(_languageCode[index]);
    Future.delayed(Duration.zero, () {
      context.loaderOverlay.hide();
      MyApp.setLocale(context, _languageCode[index]);
      AutoRouter.of(context).pushAndPopUntil(const OnBoardingRoute(),
          predicate: (Route<dynamic> route) => false);
    });
  }
}
