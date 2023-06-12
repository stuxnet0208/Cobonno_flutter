import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;

import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../data/models/moment_model.dart';
import '../../provider/photo_provider.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_mouse_pointer.dart';
import '../../widgets/image_cropper/custom_multi_image_cropper.dart';
import 'image_list_page.dart';
import 'package:media_store_plus/media_store_plus.dart';

class GalleryListPage extends StatefulWidget {
  const GalleryListPage(
      {Key? key,
      required this.isParentSelected,
      required this.childId,
      this.momentModel})
      : super(key: key);
  final bool isParentSelected;
  final List<String> childId;
  final MomentModel? momentModel;

  @override
  State<GalleryListPage> createState() => _GalleryListPageState();
}

class _GalleryListPageState extends State<GalleryListPage> {
  PhotoProvider get readProvider => context.read<PhotoProvider>();
  final ValueNotifier<AssetPathEntity?> _selectedEntity = ValueNotifier(null);
  AssetPathEntity? _previousEntity;
  UniqueKey _key = UniqueKey();
  final ValueNotifier<List<AssetEntity>> _entityList = ValueNotifier([]);
  File? _fileFromCamera;
  final List<String> _tempUnusedEntities = [];
  final List<File> _existingMediaFilesFromEdit = [];
  final ValueNotifier<List<int>> _checkboxes = ValueNotifier([]);
  final List<String> _usedEntities = [];
  final mediaStorePlugin = MediaStore();
  int _platformSDKVersion = 0;

  Future<void> _disposeInBackButton() async {
    debugPrint('dispose in back');
    if (widget.momentModel == null) {
      if (_tempUnusedEntities.isNotEmpty) {
        PhotoManager.editor.deleteWithIds(_tempUnusedEntities).then((_) {
          debugPrint('photo manager editor: deleted');
        });
      }
    } else {
      PhotoManager.editor.deleteWithIds(_usedEntities).then((_) {
        debugPrint('photo manager editor: deleted');
      });
    }
    PhotoProvider().dispose();
  }

  Future<void> _disposeInNextButton() async {
    debugPrint('dispose in next');
    // delete temp unused entities
    if (widget.momentModel == null) {
      _usedEntities.clear();
      for (var data in _entityList.value) {
        _usedEntities.add(data.id);
      }
      List<String> temps = [];
      temps.addAll(_tempUnusedEntities);
      for (var data in _tempUnusedEntities) {
        if (_usedEntities.contains(data)) {
          temps.remove(data);
        }
      }
      debugPrint('temp unused entities $temps');
      if (temps.isNotEmpty) {
        PhotoManager.editor.deleteWithIds(temps).then((_) {
          debugPrint('photo manager editor: deleted');
        });
      }
    }
  }

  @override
  void dispose() {
    _disposeInNextButton();
    super.dispose();
  }

  Future<void> _setFileFromCamera(File file) async {
    context.loaderOverlay.show();
    _fileFromCamera = file;

    debugPrint('file from camera $_fileFromCamera');
    AssetEntity? entity = await PhotoManager.editor
        .saveImageWithPath(file.path, title: '${UniqueKey()}.png');
    debugPrint('entity $entity');
    if (entity != null) {
      _tempUnusedEntities.add(entity.id);
      if (!Provider.of<PhotoProvider>(context, listen: false)
          .isSelectMultiple) {
        _entityList.value.clear();
      }
      _entityList.value.add(entity);
      _entityList.notifyListeners();
    }
    context.loaderOverlay.hide();
  }

  Future<void> _checkInitMoment() async {
    if (widget.momentModel != null) {
      context.loaderOverlay.show();
      Provider.of<PhotoProvider>(context, listen: false).isSelectMultiple =
          true;
      _existingMediaFilesFromEdit.clear();
      int i = 0;
      for (var data in widget.momentModel!.photos) {
        File file = await _urlToFile(data.photoUrlModel.original);
        AssetEntity? entity = await PhotoManager.editor
            .saveImageWithPath(file.path, title: '${UniqueKey()}.png');
        if (entity != null) {
          _tempUnusedEntities.add(entity.id);
          _usedEntities.add(entity.id);
          _entityList.value.add(entity);
        }
        _existingMediaFilesFromEdit.add(file);
        _checkboxes.value.add(i);
        i++;
      }

      await readProvider.refreshGalleryList();
      debugPrint(readProvider.list.length.toString());
      if (readProvider.list.isNotEmpty) {
        _selectedEntity.value = readProvider.list.first;
        _previousEntity = _selectedEntity.value;
      }

      _selectedEntity.notifyListeners();
      _entityList.notifyListeners();
      readProvider.notifyListeners();

      context.loaderOverlay.hide();
    }
  }

  void _setEntities(List<AssetEntity> entities) {
    _entityList.value = entities;
    _entityList.notifyListeners();
  }

  Future<File> _urlToFile(String imageUrl) async {
    var rng = Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = File('$tempPath${rng.nextInt(100)}.png');
    http.Response response = await http.get(Uri.parse(imageUrl));
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  @override
  void initState() {
    initPlatformState();
    _initPermission();
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    int platformSDKVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformSDKVersion = await mediaStorePlugin.getPlatformSDKInt();
    } on PlatformException {
      platformSDKVersion = -1;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformSDKVersion = platformSDKVersion;
    });
  }

  Future<void> _initPermission() async {
    try {
      context.loaderOverlay.show();

      List<Permission> permissions = [
        Permission.storage,
      ];

      if (Platform.isAndroid) {
        if ((await mediaStorePlugin.getPlatformSDKInt()) >= 33) {
          permissions.add(Permission.photos);
          permissions.add(Permission.audio);
          permissions.add(Permission.videos);
        }
        await permissions.request();
      }

      // You have set this otherwise it throws AppFolderNotSetException
      MediaStore.appFolder = "MediaStorePlugin";

      PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();
      // await PhotoManager.setIgnorePermissionCheck(true);
      if (!permissionState.hasAccess) {
        await _buildErrorPermission();
      } else {
        await Future.delayed(Duration.zero, () {
          if (widget.momentModel == null) {
            Provider.of<PhotoProvider>(context, listen: false)
                .isSelectMultiple = false;
            readProvider.refreshGalleryList().then((value) {
              debugPrint(readProvider.list.length.toString());
              if (readProvider.list.isNotEmpty) {
                _selectedEntity.value = readProvider.list.first;
                _previousEntity = _selectedEntity.value;
                _selectedEntity.notifyListeners();
              }
              readProvider.notifyListeners();
              context.loaderOverlay.hide();
            });
          } else {
            _checkInitMoment();
          }
        });
      }
    } catch (e) {
      debugPrint('error in gallery list page: ${e.toString()}');
      context.loaderOverlay.hide();
    }
  }

  Future<void> _buildErrorPermission() async {
    context.loaderOverlay.hide();
    await Future.delayed(Duration.zero, () {
      SharedCode.showErrorDialog(
          context, 'Error', AppLocalizations.of(context).grantPermissionAlert);
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SharedCode.darkStatusBar());

    return WillPopScope(
      onWillPop: () {
        _disposeInBackButton();
        return Future.value(true);
      },
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            systemOverlayStyle: SharedCode.darkStatusBar(),
            backgroundColor: Colors.black,
            title: Text(AppLocalizations.of(context).selectMedia,
                style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (_entityList.value.isEmpty) {
                      SharedCode.showSnackBar(context, 'error',
                          AppLocalizations.of(context).pickOneAlert);
                    } else {
                      context.loaderOverlay.show();
                      await _disposeInNextButton();
                      // AutoRouter.of(context).navigate(MomentFormRoute(assets: _entityList.value));

                      await _goToCrop();
                      // Future.delayed(Duration.zero, () {
                      // AutoRouter.of(context).navigate(MomentFormRoute(momentModel: widget.momentModel, bytes: bytes, childId: widget.childId, isParentSelected: widget.isParentSelected, usedEntities: _usedEntities));

                      // AutoRouter.of(context).navigate(PhotoFilterRoute(
                      //     assets: _entityList.value,
                      //     momentModel: widget.momentModel,
                      //     isParentSelected: widget.isParentSelected,
                      //     childId: widget.childId,
                      //     usedEntities: _usedEntities));
                      // });
                      context.loaderOverlay.hide();
                    }
                  },
                  child: Text(AppLocalizations.of(context).next,
                      style: const TextStyle(color: ColorValues.darkerBlue)))
            ],
          ),
          body: ValueListenableBuilder(
              valueListenable: _selectedEntity,
              builder: (_, __, ___) {
                return _buildCustomScrollView();
              })),
    );
  }

  Future<void> _goToCrop() async {
    final List<File> files = [];
    for (var data in _entityList.value) {
      final file = await data.file;
      files.add(file!);
    }
    CustomMultiImageCrop.startCropping(
        context: context,
        activeColor: Theme.of(context).primaryColor,
        files: files,
        callBack: (List<File> images) {
          if (images.isNotEmpty) {
            final List<Uint8List> newBytes = [];
            for (var data in images) {
              newBytes.add(data.readAsBytesSync());
            }
            AutoRouter.of(context).navigate(MomentFormRoute(
                momentModel: widget.momentModel,
                bytes: newBytes,
                childId: widget.childId,
                isParentSelected: widget.isParentSelected,
                usedEntities: _usedEntities));
          }
        });
  }

  Widget _buildCustomScrollView() {
    return CustomScrollView(
      slivers: [
        _buildSelectedImages(),
        _buildMiddleWidgets(),
        SliverToBoxAdapter(
          child: SizedBox(height: 2.h),
        ),
        _buildListView()
      ],
    );
  }

  Widget _buildMiddleWidgets() {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder(
          valueListenable: _selectedEntity,
          builder: (_, __, ___) {
            return Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Row(
                  children: [
                    Flexible(
                        child: _selectedEntity.value == null
                            ? Container()
                            : DropdownButton<AssetPathEntity>(
                                isExpanded: true,
                                iconEnabledColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                dropdownColor: Colors.black,
                                items: readProvider.list
                                    .map((AssetPathEntity value) {
                                  return DropdownMenuItem<AssetPathEntity>(
                                    value: value,
                                    child: Text(value.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp),
                                        overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                value: _selectedEntity.value,
                                onChanged: (val) {
                                  _previousEntity = _selectedEntity.value;
                                  _selectedEntity.value = val;
                                  _selectedEntity.notifyListeners();
                                  debugPrint('hello');
                                  debugPrint(_selectedEntity.value.toString());
                                })),
                    SizedBox(width: 2.w),
                    CustomMousePointer(
                      child: GestureDetector(
                        onTap: () {
                          _previousEntity = _selectedEntity.value;
                          Provider.of<PhotoProvider>(context, listen: false)
                              .isSelectMultiple = !Provider.of<PhotoProvider>(
                                  context,
                                  listen: false)
                              .isSelectMultiple;
                          if (!Provider.of<PhotoProvider>(context,
                                      listen: false)
                                  .isSelectMultiple &&
                              _entityList.value.length > 1) {
                            AssetEntity entity = _entityList.value.first;
                            _entityList.value.clear();
                            _entityList.value.add(entity);
                            _entityList.notifyListeners();
                            _selectedEntity.notifyListeners();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                              color: Provider.of<PhotoProvider>(context,
                                          listen: true)
                                      .isSelectMultiple
                                  ? ColorValues.darkerBlue
                                  : ColorValues.darkerGrey,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                  color: ColorValues.darkerGreyAlt, width: 1)),
                          child: Row(
                            children: [
                              SizedBox(width: 1.w),
                              const Icon(Icons.select_all, color: Colors.white),
                              SizedBox(width: 1.w),
                              Text(AppLocalizations.of(context).selectImage,
                                  style: const TextStyle(color: Colors.white)),
                              SizedBox(width: 1.w),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    CustomMousePointer(
                      child: GestureDetector(
                        onTap: () async {
                          print('ini ke-print');
                          dynamic file = await AutoRouter.of(context)
                              .push(CameraRoute(context: context));
                          if (file is File) {
                            context.loaderOverlay.show();
                            await _setFileFromCamera(file);
                            debugPrint('set file from camera done');
                            await _goToCrop();
                            context.loaderOverlay.hide();
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ColorValues.darkerGrey,
                              border: Border.all(
                                  color: ColorValues.darkerGreyAlt, width: 1)),
                          child: const Icon(Icons.camera_alt_outlined,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ));
          }),
    );
  }

  // Widget _buildListView() {
  //   return SliverToBoxAdapter(
  //     child: ValueListenableBuilder(
  //         valueListenable: _selectedEntity,
  //         builder: (_, __, ___) {
  //           debugPrint('selected entity in list view ${_selectedEntity.value}');
  //           return _selectedEntity.value == null
  //               ? const SizedBox.shrink()
  //               : ChangeNotifierProvider<AssetPathProvider>(
  //               create: (_) => AssetPathProvider(_selectedEntity.value!),
  //               builder: (BuildContext context, _) => Consumer<AssetPathProvider>(
  //                   builder: (BuildContext c, AssetPathProvider p, _) => ImageListPage(
  //                       path: _selectedEntity.value!, p: p)
  //               ));
  //         }),
  //   );
  // }

  Widget _buildListView() {
    debugPrint('prev $_previousEntity');
    debugPrint('now ${_selectedEntity.value}');
    if (_previousEntity != _selectedEntity.value) {
      _key = UniqueKey();
    }
    return _selectedEntity.value == null
        ? SliverToBoxAdapter(
            child: Center(
                child: Text(
            AppLocalizations.of(context).noImageAvailable,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          )))
        : ImageListPage(
            path: _selectedEntity.value!,
            key: _key,
            setEntities: _setEntities,
            checkboxes: _checkboxes,
            entities: _entityList.value,
          );
  }

  Widget _buildSelectedImages() {
    return SliverToBoxAdapter(
      child: ValueListenableBuilder(
          valueListenable: _entityList,
          builder: (_, __, ___) {
            double width = MediaQuery.of(context).size.width;
            final bool useMobileLayout = width < 600;
            return SizedBox(
                height: useMobileLayout
                    ? 60.h
                    : MediaQuery.of(context).size.height * 0.5,
                width: double.infinity,
                child: _entityList.value.isEmpty
                    ? const SizedBox.shrink()
                    : CarouselSlider.builder(
                        itemCount: _entityList.value.length,
                        itemBuilder: (_, index, realIndex) => AssetEntityImage(
                            _entityList.value[realIndex],
                            width: double.infinity),
                        options: CarouselOptions(
                            autoPlay: false,
                            viewportFraction: 1,
                            enableInfiniteScroll: false)));
          }),
    );
  }
}
