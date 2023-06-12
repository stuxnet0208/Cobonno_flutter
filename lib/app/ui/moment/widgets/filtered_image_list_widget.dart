import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:photofilters/filters/filters.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_mouse_pointer.dart';
import 'filtered_image_widget.dart';

class FilteredImageListWidget extends StatelessWidget {
  final List<Filter> filters;
  final img.Image image;
  final ValueChanged<Filter> onChangedFilter;

  const FilteredImageListWidget({
    Key? key,
    required this.filters,
    required this.image,
    required this.onChangedFilter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: filters.length,
      itemBuilder: (context, index) {
        final filter = filters[index];

        return _buildFilter(filter);
      },
    );
  }

  CustomMousePointer _buildFilter(Filter filter) {
    bool isHorizontal = image.width > image.height;
    double defaultWidth = 30.w;
    if (!isHorizontal) {
      defaultWidth = 15.w;
    }
    double width =
        image.width.toDouble() / 7 > defaultWidth ? defaultWidth : image.width.toDouble() / 7;
    return CustomMousePointer(
      child: GestureDetector(
        onTap: () => onChangedFilter(filter),
        child: Container(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Text(
                filter.name.replaceAll('Addictive', ''),
                style: const TextStyle(color: Colors.white),
              ),
              Flexible(
                child: SizedBox(
                  height: 10.h,
                  width: width,
                  child: FilteredImageWidget(
                    filter: filter,
                    image: image,
                    successBuilder: (imageBytes) => imageBytes == null
                        ? const SizedBox.shrink()
                        : Image.memory(
                            Uint8List.fromList(imageBytes),
                            fit: BoxFit.cover,
                          ),
                    errorBuilder: () =>
                        const SizedBox(child: Icon(Icons.report, color: Colors.red)),
                    loadingBuilder: () =>
                        const SizedBox(child: Center(child: CircularProgressIndicator())),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
