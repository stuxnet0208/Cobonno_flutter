import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../provider/photo_provider.dart';
import '../../widgets/custom_mouse_pointer.dart';
import 'widgets/image_item_widget.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({
    Key? key,
    required this.path,
    required this.setEntities,
    required this.entities,
    required this.checkboxes,
  }) : super(key: key);

  final AssetPathEntity path;
  final Function(List<AssetEntity>) setEntities;
  final List<AssetEntity> entities;
  final ValueNotifier<List<int>> checkboxes;

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  late final PhotoProvider photoProvider = Provider.of<PhotoProvider>(context);

  PhotoProvider get watchProvider => context.watch<PhotoProvider>();

  AssetPathProvider readPathProvider(BuildContext c) => c.read<AssetPathProvider>();

  AssetPathProvider watchPathProvider(BuildContext c) => c.watch<AssetPathProvider>();

  List<AssetEntity> _entityList = [];

  ValueNotifier<List<int>> _checkboxes = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _checkboxes = widget.checkboxes;
    //debugPrint('hello there ${widget.key}');
    widget.path.getAssetListRange(start: 0, end: 1).then((List<AssetEntity> value) {
      if (value.isEmpty) {
        return;
      }
      if (mounted) {
        return;
      }
      PhotoCachingManager().requestCacheAssets(
        assets: value,
        option: thumbOption,
      );
    });
  }

  @override
  void dispose() {
    PhotoCachingManager().cancelCacheRequest();
    super.dispose();
  }

  ThumbnailOption get thumbOption => ThumbnailOption(
        size: const ThumbnailSize.square(200),
        format: photoProvider.thumbFormat,
      );

  @override
  Widget build(BuildContext context) {
    _entityList = widget.entities;
    return ChangeNotifierProvider<AssetPathProvider>(
      create: (_) => AssetPathProvider(widget.path),
      builder: (BuildContext context, _) => _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<AssetPathProvider>(
      builder: (BuildContext c, AssetPathProvider p, _) => SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (_, int index) {
            return Builder(
              builder: (BuildContext c) => _buildItem(context, index),
            );
          },
          childCount: p.showItemCount,
          findChildIndexCallback: (Key? key) {
            if (key is ValueKey<String>) {
              return findChildIndexBuilder(
                id: key.value,
                assets: p.list,
              );
            }
            return null;
          },
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 0.5.h,
          crossAxisCount: 4,
          crossAxisSpacing: 0.5.w,
        ),
      ),
    );
  }

  final Center loadWidget = Center(
    child: SizedBox.fromSize(
      size: const Size.square(30),
      child: (Platform.isIOS || Platform.isMacOS)
          ? const CupertinoActivityIndicator()
          : const CircularProgressIndicator(),
    ),
  );

  Widget _buildItem(BuildContext context, int index) {
    final List<AssetEntity> list = watchPathProvider(context).list;
    if (list.length == index) {
      onLoadMore(context);
      return loadWidget;
    }

    if (index > list.length) {
      return Container();
    }

    final AssetEntity entity = list[index];

    return ValueListenableBuilder(
        valueListenable: _checkboxes,
        builder: (context, _, __) {
          return CustomMousePointer(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    _setSelectedImages(index, entity);
                  },
                  child: Opacity(
                    opacity: _entityList.contains(entity) ? 1 : 0.5,
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: ImageItemWidget(
                        key: ValueKey<String>(entity.id),
                        entity: entity,
                        option: thumbOption,
                      ),
                    ),
                  ),
                ),
                !watchProvider.isSelectMultiple
                    ? const SizedBox.shrink()
                    : Positioned.fill(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              unselectedWidgetColor: Colors.white,
                            ),
                            child: Checkbox(
                              activeColor: ColorValues.darkerBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              value: _checkboxes.value.contains(index),
                              onChanged: (v) {
                                _setSelectedImages(index, entity);
                              },
                            ),
                          ),
                        ),
                      )
              ],
            ),
          );
        });
  }

  void _setSelectedImages(int index, AssetEntity entity) {
    if (!Provider.of<PhotoProvider>(context, listen: false).isSelectMultiple) {
      _checkboxes.value.clear();
      _entityList.clear();
    }

    int indexWhere = _checkboxes.value.indexWhere((element) => element == index);
    //debugPrint('index where $indexWhere');
    if (indexWhere == -1) {
      if (_entityList.length < 5) {
        _checkboxes.value.add(index);
        _entityList.add(entity);
      } else {
        SharedCode.showSnackBar(context, 'error', AppLocalizations.of(context).maximumImagesAlert);
      }
    } else {
      _checkboxes.value.removeAt(indexWhere);
      _entityList.remove(entity);
    }

    widget.setEntities(_entityList);
    _checkboxes.notifyListeners();
  }

  int findChildIndexBuilder({
    required String id,
    required List<AssetEntity> assets,
  }) {
    return assets.indexWhere((AssetEntity e) => e.id == id);
  }

  Future<void> onLoadMore(BuildContext context) async {
    if (!mounted) {
      return;
    }
    await readPathProvider(context).onLoadMore(context);
  }
}
