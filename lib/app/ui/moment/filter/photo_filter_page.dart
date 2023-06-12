import 'dart:io';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image/image.dart' as img;
import 'package:photofilters/photofilters.dart';

import '../../../common/color_values.dart';
import '../../../data/models/moment_model.dart';
import '../../../routes/router.gr.dart';
import '../widgets/filtered_image_list_widget.dart';
import '../widgets/filtered_image_widget.dart';
import 'util/filter_util.dart';

class PhotoFilterPage extends StatefulWidget {
  final List<AssetEntity> assets;
  final bool isParentSelected;
  final List<String> childId, usedEntities;
  final MomentModel? momentModel;

  const PhotoFilterPage(
      {Key? key,
      required this.assets,
      required this.isParentSelected,
      required this.childId,
      this.momentModel,
      required this.usedEntities})
      : super(key: key);

  @override
  State<PhotoFilterPage> createState() => _PhotoFilterPageState();
}

class _PhotoFilterPageState extends State<PhotoFilterPage> {
  final ValueNotifier<img.Image?> _image = ValueNotifier(null);
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);
  final ValueNotifier<List<Filter>> _filter = ValueNotifier([]);
  bool _isLoading = true;
  final List<Uint8List> _bytes = [];

  @override
  void initState() {
    super.initState();
    _initImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.black,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.black,
          title: const Icon(Icons.photo_filter_outlined, color: Colors.white),
          actions: [
            TextButton(
                onPressed: () async {
                  context.loaderOverlay.show();
                  int i = 0;
                  List<List<int>> listBytes = [];
                  for (var data in _bytes) {
                    List<int> bytes = data;
                    if (img.decodeImage(data) != null) {
                      bytes = await FilterUtils.applyFilter(
                          img.decodeImage(data)!, _filter.value[i], context);
                    }
                    listBytes.add(bytes);
                    i++;
                  }
                  context.loaderOverlay.hide();
                  Future.delayed(Duration.zero, () {
                    AutoRouter.of(context).navigate(MomentFormRoute(
                        momentModel: widget.momentModel,
                        bytes: listBytes,
                        childId: widget.childId,
                        isParentSelected: widget.isParentSelected,
                        usedEntities: widget.usedEntities));
                  });
                },
                child: Text(AppLocalizations.of(context).next,
                    style: const TextStyle(color: ColorValues.darkerBlue)))
          ]),
      body: _isLoading
          ? const SizedBox.shrink()
          : Column(
              children: [
                Expanded(flex: 2, child: _buildImageCarousel()),
                const SizedBox(height: 12),
                Expanded(child: _buildFilters()),
              ],
            ),
    );
  }

  Future _initImage() async {
    context.loaderOverlay.show();
    _bytes.clear();
    for (var data in widget.assets) {
      final bytes = await data.originBytes;
      _bytes.add(bytes!);
      _filter.value.add(presetFiltersList.first);
    }

    _image.value = img.decodeImage(_bytes.first);

    FilterUtils.clearCache();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _isLoading = false;
    }
    context.loaderOverlay.hide();
  }

  Widget _buildImage(img.Image image) {
    return ValueListenableBuilder(
        valueListenable: _filter,
        builder: (_, __, ___) {
          return FilteredImageWidget(
            filter: _filter.value[_currentIndex.value],
            image: image,
            successBuilder: (imageBytes) => Image.memory(Uint8List.fromList(imageBytes!),
                height: double.infinity, width: double.infinity),
            errorBuilder: () => const Center(child: Icon(Icons.error, color: Colors.red)),
            loadingBuilder: () => const Center(child: CircularProgressIndicator()),
          );
        });
  }

  Future<img.Image?> _convertHeicToJpg(int index, AssetEntity entity) async {
    //debugPrint('convert heic to jpg');
    img.Image? image = img.decodeImage(_bytes[index]);
    if (image == null) {
      context.loaderOverlay.show();
      File? file = await entity.file;
      if (file != null) {
        String? jpegPath = await HeicToJpg.convert(file.path);
        if (jpegPath != null) {
          //debugPrint('jpeg path $jpegPath');
          File file = File(jpegPath);
          image = img.decodeImage(file.readAsBytesSync());
          //debugPrint('bytes index before ${_bytes[index]}');
          _bytes[index] = file.readAsBytesSync();
          //debugPrint('bytes index ${_bytes[index]}');
          _image.value = image;
        }
      }
    }
    FilterUtils.clearCache();
    return image;
  }

  Widget _buildImageCarousel() {
    return CarouselSlider.builder(
        itemCount: widget.assets.length,
        itemBuilder: (_, index, realIndex) {
          return FutureBuilder<img.Image?>(
              future: _convertHeicToJpg(index, widget.assets[realIndex]),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const SizedBox.shrink();
                  default:
                    context.loaderOverlay.hide();
                    if (snapshot.hasError) {
                      //debugPrint('error in photo filter: ${snapshot.error}');
                      return const SizedBox.shrink();
                    } else {
                      return snapshot.data == null
                          ? const SizedBox.shrink()
                          : _buildImage(snapshot.data!);
                    }
                }
              });
        },
        options: CarouselOptions(
            onPageChanged: (i, __) {
              _currentIndex.value = i;
              final newImage = img.decodeImage(_bytes[i]);
              _image.value = newImage;
              _image.notifyListeners();
              _filter.notifyListeners();
            },
            autoPlay: false,
            viewportFraction: 1,
            height: double.infinity,
            enableInfiniteScroll: false));
  }

  Widget _buildFilters() {
    return ValueListenableBuilder(
        valueListenable: _image,
        builder: (_, __, ___) {
          //debugPrint('image in filters ${_image.value}');
          return _image.value == null
              ? const SizedBox.shrink()
              : FilteredImageListWidget(
                  filters: presetFiltersList,
                  image: _image.value!,
                  onChangedFilter: (filter) {
                    _filter.value[_currentIndex.value] = filter;
                    _filter.notifyListeners();
                  },
                );
        });
  }
}
