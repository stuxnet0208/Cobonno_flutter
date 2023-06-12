import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/shared_code.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType textInputType;
  final String? Function(String?)? validator, onChanged;
  final Widget? icon;
  final bool enabled,
      isUnderline,
      required,
      isFloatingLabel,
      alwaysValidate,
      hasBorder,
      isTitle,
      hasPadding;
  final int minLines;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.validator,
    this.alwaysValidate = true,
    this.isFloatingLabel = true,
    this.isTitle = false,
    this.onChanged,
    this.icon,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.isUnderline = false,
    this.hasPadding = true,
    this.hasBorder = true,
    this.required = true,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    UnderlineInputBorder? border = widget.isUnderline
        ? UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1))
        : null;

    if (widget.isUnderline && !widget.hasBorder) {
      border =
          const UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent, width: 0));
    }
    dynamic validator = widget.validator;
    validator ??= SharedCode(context).emptyValidator;
    Widget textField = TextFormField(
        style: TextStyle(
            fontSize: widget.isTitle ? 16.sp : 14.sp,
            fontWeight: widget.isTitle ? FontWeight.bold : FontWeight.normal,
            height: widget.maxLines == null ? 0.2.h : null),
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        validator: validator,
        autovalidateMode:
            widget.alwaysValidate ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
        onChanged: widget.onChanged,
        inputFormatters: widget.textInputType == TextInputType.phone
            ? [
                FilteringTextInputFormatter.digitsOnly,
              ]
            : [],
        decoration: InputDecoration(
            errorMaxLines: 10,
            border: border,
            floatingLabelBehavior:
                widget.isFloatingLabel ? FloatingLabelBehavior.auto : FloatingLabelBehavior.never,
            contentPadding: widget.isUnderline
                ? (widget.hasPadding
                    ? const EdgeInsets.symmetric(horizontal: 0, vertical: 2)
                    : EdgeInsets.symmetric(horizontal: 0, vertical: -1.5.h))
                : null,
            label: Text(
              widget.required
                  ? widget.label
                  : '${widget.label} (${AppLocalizations.of(context).optional})',
              style: TextStyle(fontSize: widget.isTitle ? 15.sp : 13.sp),
            ),
            errorBorder: border,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedErrorBorder: border,
            icon: widget.icon,
            alignLabelWithHint: true));
    return widget.enabled ? textField : AbsorbPointer(child: textField);
  }
}
