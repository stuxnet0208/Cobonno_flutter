import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../common/styles.dart';

class StudioPage extends StatefulWidget {
  const StudioPage({Key? key}) : super(key: key);

  @override
  State<StudioPage> createState() => _StudioPageState();
}

class _StudioPageState extends State<StudioPage> {
  Map<IconData, String> _map = {};

  @override
  Widget build(BuildContext context) {
    _map = {
      FontAwesomeIcons.shirt: AppLocalizations.of(context).studioTShirt,
      FontAwesomeIcons.mugHot: AppLocalizations.of(context).studioMug,
      FontAwesomeIcons.flag: AppLocalizations.of(context).studioTowel,
    };

    return Padding(
      padding: const EdgeInsets.all(Styles.defaultPadding),
      child: ListView.separated(
          itemBuilder: (_, i) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
              decoration:
                  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  FaIcon(_map.keys.elementAt(i), size: 28),
                  SizedBox(width: 8.w),
                  Expanded(
                      child: Text(_map.values.elementAt(i),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp))),
                ],
              ),
            );
          },
          separatorBuilder: (_, i) {
            return _map.length - 1 == i ? const SizedBox.shrink() : SizedBox(height: 3.h);
          },
          itemCount: _map.length,
          shrinkWrap: true),
    );
  }
}
