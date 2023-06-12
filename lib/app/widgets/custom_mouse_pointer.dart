import 'package:flutter/material.dart';

class CustomMousePointer extends StatelessWidget {
  const CustomMousePointer({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: child,
    );
  }
}
