import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sizer/sizer.dart';

import '../../app.dart';
import '../../common/shared_preferences_service.dart';
import '../../common/styles.dart';
import '../../widgets/custom_mouse_pointer.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({Key? key}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final List<String> _languages = ['日本語', 'English'];

  final List<String> _languageCode = ['ja', 'en'];

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
    //debugPrint('delegate ${Intl.getCurrentLocale()}');
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).language)),
      body: _language.isEmpty
          ? const SizedBox.shrink()
          : ListView.builder(
              itemBuilder: (_, i) {
                return Column(
                  children: [
                    CustomMousePointer(
                      child: GestureDetector(
                        onTap: () async {
                          await SharedPreferencesService().setLanguage(_languageCode[i]);
                          Future.delayed(Duration.zero, () {
                            MyApp.setLocale(context, _languageCode[i]);
                          });
                          setState(() {
                            _language = _languageCode[i];
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
                          child: Row(
                            children: [
                              Expanded(child: Text(_languages[i])),
                              if (_language == _languageCode[i]) const Icon(Icons.check)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: const Divider(thickness: 1)),
                  ],
                );
              },
              itemCount: _languages.length),
    );
  }
}
