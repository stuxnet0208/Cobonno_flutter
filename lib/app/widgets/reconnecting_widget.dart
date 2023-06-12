import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../common/color_values.dart';

class ReconnectingWidget extends StatelessWidget {
  const ReconnectingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: SpinKitChasingDots(
      color: ColorValues.primaryRed,
      size: 50.0,
    ));
  }
}
