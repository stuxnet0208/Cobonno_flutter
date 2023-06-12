export '../widgets/social_login_buttons.dart'
    show SocialLoginButton, SocialLoginButtonType, SocialLoginButtonMode;

import 'package:cobonno/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../common/color_values.dart';

/// All Supported Button Types
enum SocialLoginButtonType {
  /// Facebook
  facebook,

  /// Google
  google,

  /// Apple
  apple,

  /// Twitter
  twitter,
}

/// All SSupported Button Modes
enum SocialLoginButtonMode { single, multi }

// ignore: must_be_immutable
class SocialLoginButton extends StatelessWidget {
  SocialLoginButton({
    Key? key,
    required this.buttonType,
    required this.onPressed,
    this.imageURL,
    this.imagePath,
    this.text,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.textColor,
    this.height = 55.0,
    this.borderRadius = 4.0,
    this.width,
    this.imageWidth = 45,
    this.mode = SocialLoginButtonMode.multi,
  }) : super(key: key);

  /// Button Type
  final SocialLoginButtonType buttonType;

  /// Action onPressed
  final VoidCallback? onPressed;

  /// Image URL (increase you want to use network image), an optional param can be
  /// used to override default image.
  String? imageURL;

  /// Image Path (increase you want to use local image), an optional param can be
  /// used to override default image.
  String? imagePath;

  /// Button text, an optional param can be used to override default text
  String? text;

  /// Background Color, an optional param can be used to override default
  /// background color.
  Color? backgroundColor;

  /// Text Color, an optional param can be used to override default text color.
  Color? textColor;

  /// Height, an optional param can be used to override default height of button,
  /// which is 55.0
  double? height;

  /// Border Radius text, an optional param can be used to override default
  /// border radius, which is 4.0.
  double? borderRadius;

  /// Font Size, an optional param can be used to override default font size,
  /// which is 15.0
  double? fontSize;

  /// Width, an optional param can be used to override default button Width.
  double? width;

  /// Image Width, an optional param can be used to override default button
  /// image width which is 45.0.
  double? imageWidth;

  /// Grey out color, an optional param can be used to override default
  /// background Color when button is in disabled state.
  Color? disabledBackgroundColor;

  /// Button Mode, an optional param, can be used to create single style button.
  SocialLoginButtonMode? mode;

  final _defaultImagePath = "assets/";

  @override
  Widget build(BuildContext context) {
    Color? color;
    String? imageName;
    String? text;
    Color? backgroundColor;

    switch (buttonType) {
      case SocialLoginButtonType.facebook:
        color = Colors.white;
        text = AppLocalizations.of(context).signInFacebook;
        imageName = "${_defaultImagePath}facebook.png";
        backgroundColor = const Color(0xFF3B579D);
        break;
      case SocialLoginButtonType.google:
        color = Colors.black87;
        text = AppLocalizations.of(context).signInGoogle;
        imageName = "${_defaultImagePath}google.png";
        backgroundColor = Colors.white;
        break;
      case SocialLoginButtonType.apple:
        color = Colors.black;
        text = AppLocalizations.of(context).signInApple;
        imageName = "${_defaultImagePath}apple.png";
        backgroundColor = Colors.white;
        break;
      case SocialLoginButtonType.twitter:
        color = Colors.white;
        text = AppLocalizations.of(context).signInTwitter;
        imageName = "${_defaultImagePath}twitter.png";
        backgroundColor = const Color(0xFF1DA1F2);
        break;
    }
    var signin = AppLocalizations.of(context).signIn;
    text = mode == null || mode == SocialLoginButtonMode.multi ? text : " $signin";
    return _LoginButton(
      imagePath: imagePath ?? imageURL ?? imageName,
      text: this.text ?? text,
      color: textColor ?? color,
      backgroundColor: this.backgroundColor ?? backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      onPressed: onPressed,
      height: height!,
      borderRadius: borderRadius!,
      mode: mode!,
      width: width,
      imageWidth: imageWidth,
      isNetworkImage: imagePath == null && imageURL != null,
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    Key? key,
    required this.imagePath,
    required this.isNetworkImage,
    required this.text,
    required this.color,
    this.backgroundColor = Colors.blueAccent,
    this.disabledBackgroundColor,
    required this.height,
    required this.borderRadius,
    required this.onPressed,
    required this.mode,
    this.width,
    this.imageWidth,
  }) : super(key: key);

  final String? imagePath;
  final bool isNetworkImage;
  final String text;
  final Color color;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double height;
  final double? width;
  final double? imageWidth;
  final double borderRadius;
  final VoidCallback? onPressed;
  final SocialLoginButtonMode mode;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: height,
        width: width,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: ColorValues.grey),
                borderRadius: BorderRadius.all(
                  Radius.circular(borderRadius),
                ),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return disabledBackgroundColor ?? backgroundColor!;
                }
                return backgroundColor!;
              },
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              createImageChildren(),
              Text(
                text,
                style: TextStyle(color: color, fontSize: 13.sp),
              ),
              Opacity(
                opacity: 0.0,
                child: createImageChildren(mode: mode),
              ),
            ],
          ),
        ),
      ),
    );
  }

  createImageChildren({SocialLoginButtonMode? mode}) {
    if (mode == null || mode == SocialLoginButtonMode.multi) {
      return imagePath == null
          ? Column()
          : isNetworkImage
              ? Image.network(
                  imagePath!,
                  width: imageWidth,
                  errorBuilder: (context, exception, stackTrace) => const Icon(Icons.error),
                )
              : Image(
                  image: AssetImage(
                    imagePath!,
                  ),
                  width: imageWidth,
                );
    }
    return Column();
  }
}
