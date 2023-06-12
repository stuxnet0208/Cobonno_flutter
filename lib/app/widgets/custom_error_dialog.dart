import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../l10n/l10n.dart';

class CustomErrorDialog extends StatelessWidget {
  final String title;
  final String content;
  static const Color red = Color(0xFFFF4F4F);

  const CustomErrorDialog({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.only(top: 40.0),
          margin: const EdgeInsets.only(top: 35.0),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              boxShadow: const [
                BoxShadow(color: Colors.black, offset: Offset(0, 5), blurRadius: 10),
              ]),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontSize: 20.0.sp, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    content,
                    style: TextStyle(fontSize: 12.0.sp),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 25.0),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(const Size(double.infinity, 48.0)),
                      backgroundColor: MaterialStateProperty.all(red),
                      elevation: MaterialStateProperty.all(0.0),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(0.0))),
                    ),
                    child: Text(
                      AppLocalizations.of(context).close,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
        ),
        const Positioned(
          left: 5.0,
          right: 5.0,
          child: CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35.0,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                child: Icon(
                  Icons.warning_rounded,
                  color: red,
                  size: 50.0,
                )),
          ),
        ),
      ],
    );
  }
}
