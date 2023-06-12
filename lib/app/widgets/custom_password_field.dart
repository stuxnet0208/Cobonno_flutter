import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../common/shared_code.dart';

class CustomPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator, onChanged;
  final bool isWithIcon;

  const CustomPasswordField(
      {Key? key,
      required this.label,
      required this.controller,
      this.validator,
      this.isWithIcon = false,
      this.onChanged})
      : super(key: key);

  @override
  State<CustomPasswordField> createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _isShowPassword = false;

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
        style: TextStyle(fontSize: 14.sp),
        controller: widget.controller,
        obscureText: !_isShowPassword,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        enableSuggestions: false,
        autocorrect: false,
        onChanged: widget.onChanged,
        validator: widget.validator ?? SharedCode(context).passwordValidator,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: widget.isWithIcon
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _isShowPassword = !_isShowPassword;
                      });
                    },
                    child: Icon(
                      _isShowPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,
            alignLabelWithHint: true));

    return textField;
  }
}
