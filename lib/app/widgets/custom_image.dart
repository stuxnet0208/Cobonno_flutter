import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../common/color_values.dart';

class CustomImage extends StatefulWidget {
  const CustomImage({Key? key, required this.imageUrl, this.width, this.height}) : super(key: key);
  final String imageUrl;
  final double? width, height;

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) {
    // return Container(
    //   color: ColorValues.loadingGrey,
    //   child: Image.network(
    //     widget.imageUrl,
    //     fit: BoxFit.cover,
    //     width: widget.width,
    //     height: widget.height,
    //   ),
    // );
    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      fit: BoxFit.cover,
      width: widget.width,
      height: widget.height,
      placeholder: (context, url) => Container(color: ColorValues.greyAlt),
      errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.red, size: 40),
    );
  }
}
