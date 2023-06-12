import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomSearchWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType textInputType;
  final String? Function(String?)? onChanged;
  final bool enabled, required;
  final int minLines;
  final int? maxLines;

  const CustomSearchWidget({
    Key? key,
    required this.label,
    required this.controller,
    this.textInputType = TextInputType.text,
    this.onChanged,
    this.enabled = true,
    this.minLines = 1,
    this.maxLines = 1,
    this.required = true,
  }) : super(key: key);

  @override
  State<CustomSearchWidget> createState() => _CustomSearchWidgetState();
}

class _CustomSearchWidgetState extends State<CustomSearchWidget> {
  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(width: 0, color: Colors.transparent));
    Widget textField = TextFormField(
        style: TextStyle(fontSize: 14.sp),
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        onChanged: widget.onChanged,
        inputFormatters: widget.textInputType == TextInputType.phone
            ? [
                FilteringTextInputFormatter.digitsOnly,
              ]
            : [],
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 2.h),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.white,
            border: border,
            label: Text(
              widget.required
                  ? widget.label
                  : '${widget.label} (${AppLocalizations.of(context).optional})',
              style: TextStyle(fontSize: 13.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            errorBorder: border,
            focusedBorder: border,
            enabledBorder: border,
            disabledBorder: border,
            focusedErrorBorder: border,
            prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
            suffixIcon: Icon(Icons.mic_outlined, color: Colors.grey[600]),
            alignLabelWithHint: true));
    return widget.enabled
        ? Material(elevation: 4, borderRadius: BorderRadius.circular(2), child: textField)
        : AbsorbPointer(child: textField);
  }
}
