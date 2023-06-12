import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../data/models/photo_model.dart';
import 'custom_image.dart';

class CustomCarousel extends StatefulWidget {
  const CustomCarousel(
      {Key? key, required this.imgList, this.type = 'original', this.controller, this.current})
      : super(key: key);

  final List<PhotoModel> imgList;
  final ValueNotifier<int>? current;
  final CarouselController? controller;
  final String type;

  @override
  State<CustomCarousel> createState() => _CustomCarouselState();
}

class _CustomCarouselState extends State<CustomCarousel> {
  final List<String> _imgList = [];

  @override
  void initState() {
    for (var data in widget.imgList) {
      switch (widget.type) {
        case 'list':
          _imgList.add(data.photoUrlModel.listView);
          break;
        case 'grid':
          _imgList.add(data.photoUrlModel.tileview);
          break;
        default:
          _imgList.add(data.photoUrlModel.original);
          break;
      }
    }
    //debugPrint('init state custom carousel');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> imageSliders = _imgList
        .map((item) => widget.type == 'grid'
            ? CustomImage(imageUrl: item, width: double.infinity)
            : Stack(
                children: <Widget>[
                  CustomImage(imageUrl: item, width: double.infinity),
                ],
              ))
        .toList();

    return SizedBox(
      width: double.infinity,
      child: Stack(children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: widget.controller,
          options: CarouselOptions(
              initialPage: widget.current?.value ?? 0,
              autoPlay: false,
              enlargeCenterPage: false,
              height: double.infinity,
              scrollPhysics: widget.type == 'grid' ? const NeverScrollableScrollPhysics() : null,
              enableInfiniteScroll: false,
              viewportFraction: 1,
              onPageChanged: (index, reason) {
                widget.current!.value = index;
              }),
        ),
      ]),
    );
  }
}
