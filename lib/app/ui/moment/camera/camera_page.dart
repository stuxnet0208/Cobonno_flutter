import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:camera/camera.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../common/shared_code.dart';
import '../../../routes/router.gr.dart';

class CameraPage extends StatefulWidget {
  final BuildContext context;
  const CameraPage({required this.context, Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? controller;
  VideoPlayerController? videoController;

  File? _imageFile;
  File? _videoFile;

  // Initial values
  bool _isCameraInitialized = false;
  bool _isCameraPermissionGranted = false;
  bool _isCameraExists = false;
  bool _isRearCameraSelected = true;
  bool _isVideoCameraSelected = false;
  bool _isRecordingInProgress = false;
  double _minAvailableExposureOffset = 0.0;
  double _maxAvailableExposureOffset = 0.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;
  bool _showVideoButton = false;

  // Current values
  double _currentZoomLevel = 1.0;
  double _currentExposureOffset = 0.0;
  FlashMode? _currentFlashMode;

  List<File> allFileList = [];
  List<CameraDescription> cameras = [];

  final resolutionPresets = ResolutionPreset.values;

  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  bool _isLoading = true;

  Future<void> _initializeCamera(BuildContext context) async {
    context.loaderOverlay.show();
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    } else {
      _isLoading = true;
    }

    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await availableCameras();
    } on CameraException catch (e) {
      //debugPrint('Error in fetching the cameras: $e');
      SharedCode.showSnackBar(context, 'error', e.toString());
    }

    await getPermissionStatus();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    } else {
      _isLoading = false;
    }
    context.loaderOverlay.hide();
  }

  Future<void> getPermissionStatus() async {
    await Permission.camera.request();
    var status = await Permission.camera.status;

    if (status.isGranted) {
      //debugPrint('Camera Permission: GRANTED');
      if (cameras.isEmpty) {
        //debugPrint('Camera not found!');
      } else {
        // Set and initialize the new camera
        setState(() {
          _isCameraExists = true;
          _isCameraPermissionGranted = true;
        });
        onNewCameraSelected(cameras[0]);
        refreshAlreadyCapturedImages();
      }
    } else {
      //debugPrint('Camera Permission: DENIED');
    }
  }

  refreshAlreadyCapturedImages() async {
    final directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> fileList = await directory.list().toList();
    allFileList.clear();
    List<Map<int, dynamic>> fileNames = [];

    for (var file in fileList) {
      if (file.path.contains('.jpg') || file.path.contains('.mp4')) {
        allFileList.add(File(file.path));

        String name = file.path.split('/').last.split('.').first;
        fileNames.add({0: int.parse(name), 1: file.path.split('/').last});
      }
    }

    if (fileNames.isNotEmpty) {
      final recentFile =
          fileNames.reduce((curr, next) => curr[0] > next[0] ? curr : next);
      String recentFileName = recentFile[1];
      if (recentFileName.contains('.mp4')) {
        _videoFile = File('${directory.path}/$recentFileName');
        _imageFile = null;
        _startVideoPlayer();
      } else {
        _imageFile = File('${directory.path}/$recentFileName');
        _videoFile = null;
      }

      setState(() {});
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;

    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      //debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      videoController = VideoPlayerController.file(_videoFile!);
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;

    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }

    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        //debugPrint(_isRecordingInProgress.toString());
      });
    } on CameraException catch (e) {
      //debugPrint('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }

    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
      });
      return file;
    } on CameraException catch (e) {
      //debugPrint('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }

    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      //debugPrint('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }

    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      //debugPrint('Error resuming video recording: $e');
    }
  }

  void resetCameraValues() async {
    _currentZoomLevel = 1.0;
    _currentExposureOffset = 0.0;
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    final CameraController cameraController = CameraController(
      cameraDescription,
      currentResolutionPreset,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await previousCameraController?.dispose();

    resetCameraValues();

    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    try {
      await cameraController.initialize();
      await Future.wait([
        cameraController
            .getMinExposureOffset()
            .then((value) => _minAvailableExposureOffset = value),
        cameraController
            .getMaxExposureOffset()
            .then((value) => _maxAvailableExposureOffset = value),
        cameraController
            .getMaxZoomLevel()
            .then((value) => _maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((value) => _minAvailableZoom = value),
      ]);

      _currentFlashMode = controller!.value.flashMode;
    } on CameraException catch (e) {
      //debugPrint('Error initializing camera: $e');
    }

    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller!.setExposurePoint(offset);
    controller!.setFocusPoint(offset);
  }

  @override
  void initState() {
    super.initState();
    // Hide the status bar in Android
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    _initializeCamera(widget.context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _initializeCamera(widget.context);
    }
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      await cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return const SizedBox.shrink();
    } else {
      return CameraPreview(
        controller!,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            title: const Text(''),
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white)),
        backgroundColor: Colors.black,
        body: _isLoading
            ? _buildLoading()
            : _isCameraPermissionGranted
                ? _isCameraInitialized
                    ? Stack(
                        children: [
                          Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: _cameraPreviewWidget(),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16.0,
                              8.0,
                              16.0,
                              8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    physics: const BouncingScrollPhysics(),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16.0, 8.0, 16.0, 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    _currentFlashMode =
                                                        FlashMode.off;
                                                  });
                                                  await controller!
                                                      .setFlashMode(
                                                    FlashMode.off,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.flash_off,
                                                  color: _currentFlashMode ==
                                                          FlashMode.off
                                                      ? Colors.amber
                                                      : Colors.white,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    _currentFlashMode =
                                                        FlashMode.auto;
                                                  });
                                                  await controller!
                                                      .setFlashMode(
                                                    FlashMode.auto,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.flash_auto,
                                                  color: _currentFlashMode ==
                                                          FlashMode.auto
                                                      ? Colors.amber
                                                      : Colors.white,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    _currentFlashMode =
                                                        FlashMode.always;
                                                  });
                                                  await controller!
                                                      .setFlashMode(
                                                    FlashMode.always,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.flash_on,
                                                  color: _currentFlashMode ==
                                                          FlashMode.always
                                                      ? Colors.amber
                                                      : Colors.white,
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  setState(() {
                                                    _currentFlashMode =
                                                        FlashMode.torch;
                                                  });
                                                  await controller!
                                                      .setFlashMode(
                                                    FlashMode.torch,
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.highlight,
                                                  color: _currentFlashMode ==
                                                          FlashMode.torch
                                                      ? Colors.amber
                                                      : Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                // Align(
                                //   alignment: Alignment.topRight,
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       color: Colors.black87,
                                //       borderRadius:
                                //       BorderRadius.circular(10.0),
                                //     ),
                                //     child: Padding(
                                //       padding: const EdgeInsets.only(
                                //         left: 8.0,
                                //         right: 8.0,
                                //       ),
                                //       child: DropdownButton<ResolutionPreset>(
                                //         dropdownColor: Colors.black87,
                                //         underline: Container(),
                                //         value: currentResolutionPreset,
                                //         items: [
                                //           for (ResolutionPreset preset
                                //           in resolutionPresets)
                                //             DropdownMenuItem(
                                //               value: preset,
                                //               child: Text(
                                //                 preset
                                //                     .toString()
                                //                     .split('.')[1]
                                //                     .toUpperCase(),
                                //                 style: const TextStyle(
                                //                     color: Colors.white),
                                //               ),
                                //             )
                                //         ],
                                //         onChanged: (value) {
                                //           setState(() {
                                //             currentResolutionPreset = value!;
                                //             _isCameraInitialized = false;
                                //           });
                                //           onNewCameraSelected(
                                //               controller!.description);
                                //         },
                                //         hint: const Text("Select item"),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                const Spacer(),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       right: 8.0, top: 16.0),
                                //   child: Container(
                                //     decoration: BoxDecoration(
                                //       color: Colors.white,
                                //       borderRadius:
                                //       BorderRadius.circular(10.0),
                                //     ),
                                //     child: Padding(
                                //       padding: const EdgeInsets.all(8.0),
                                //       child: Text(
                                //         '${_currentExposureOffset
                                //             .toStringAsFixed(1)}x',
                                //         style: const TextStyle(color: Colors.black),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // Expanded(
                                //   child: RotatedBox(
                                //     quarterTurns: 3,
                                //     child: SizedBox(
                                //       height: 30,
                                //       child: Slider(
                                //         value: _currentExposureOffset,
                                //         min: _minAvailableExposureOffset,
                                //         max: _maxAvailableExposureOffset,
                                //         activeColor: Colors.white,
                                //         inactiveColor: Colors.white30,
                                //         onChanged: (value) async {
                                //           setState(() {
                                //             _currentExposureOffset = value;
                                //           });
                                //           await controller!
                                //               .setExposureOffset(value);
                                //         },
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // Row(
                                //   children: [
                                //     Expanded(
                                //       child: Slider(
                                //         value: _currentZoomLevel,
                                //         min: _minAvailableZoom,
                                //         max: _maxAvailableZoom,
                                //         activeColor: Colors.white,
                                //         inactiveColor: Colors.white30,
                                //         onChanged: (value) async {
                                //           setState(() {
                                //             _currentZoomLevel = value;
                                //           });
                                //           await controller!
                                //               .setZoomLevel(value);
                                //         },
                                //       ),
                                //     ),
                                //     Padding(
                                //       padding:
                                //       const EdgeInsets.only(right: 8.0),
                                //       child: Container(
                                //         decoration: BoxDecoration(
                                //           color: Colors.black87,
                                //           borderRadius:
                                //           BorderRadius.circular(10.0),
                                //         ),
                                //         child: Padding(
                                //           padding: const EdgeInsets.all(8.0),
                                //           child: Text(
                                //             '${_currentZoomLevel
                                //                 .toStringAsFixed(1)}x',
                                //             style: const TextStyle(
                                //                 color: Colors.white),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8.0,
                                            right: 4.0,
                                          ),
                                          child: TextButton(
                                            onPressed: _isRecordingInProgress
                                                ? null
                                                : () {
                                                    if (_isVideoCameraSelected) {
                                                      setState(() {
                                                        _isVideoCameraSelected =
                                                            false;
                                                      });
                                                    }
                                                  },
                                            style: TextButton.styleFrom(
                                              primary: _isVideoCameraSelected
                                                  ? Colors.black54
                                                  : Colors.black,
                                              backgroundColor:
                                                  _isVideoCameraSelected
                                                      ? Colors.white30
                                                      : Colors.white,
                                            ),
                                            child: Column(children: [
                                              const Icon(Icons.photo_library,
                                                  size: 32),
                                              Text(AppLocalizations.of(context)
                                                  .image),
                                            ]),
                                          ),
                                        ),
                                      ),
                                      if (_showVideoButton)
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 4.0, right: 8.0),
                                            child: TextButton(
                                              onPressed: () {
                                                SharedCode.showSnackBar(
                                                    context,
                                                    'error',
                                                    AppLocalizations.of(context)
                                                        .notSupportedYet);
                                                // if (!_isVideoCameraSelected) {
                                                //   setState(() {
                                                //     _isVideoCameraSelected = true;
                                                //   });
                                                // }
                                              },
                                              style: TextButton.styleFrom(
                                                primary: _isVideoCameraSelected
                                                    ? Colors.black
                                                    : Colors.black54,
                                                backgroundColor:
                                                    _isVideoCameraSelected
                                                        ? Colors.white
                                                        : Colors.white30,
                                              ),
                                              child: Column(children: [
                                                const Icon(Icons.videocam,
                                                    size: 32),
                                                Text(
                                                    AppLocalizations.of(context)
                                                        .video),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 8.0),
                                          child: TextButton(
                                            onPressed: () async {
                                              // String? imagePath;
                                              // Platform messages may fail, so we use a try/catch PlatformException.
                                              // We also handle the message potentially returning null.
                                              String imagePath = join(
                                                  (await getApplicationSupportDirectory())
                                                      .path,
                                                  "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
                                              bool? success;
                                              try {
                                                //Make sure to await the call to detectEdge.
                                                 success =
                                                    await EdgeDetection
                                                        .detectEdge(
                                                  imagePath,
                                                  canUseGallery: true,
                                                  androidScanTitle:
                                                      'Scanning', // use custom localizations for android
                                                  androidCropTitle: 'Crop',
                                                  androidCropBlackWhiteTitle:
                                                      'Black White',
                                                  androidCropReset: 'Reset',
                                                );
                                              } catch (e) {
                                                print(e);
                                              }

                                              if (success == true) {
                                                File imageFile =
                                                    File(imagePath);

                                                Future.delayed(Duration.zero,
                                                    () {
                                                  AutoRouter.of(context)
                                                      .pop(imageFile);
                                                });
                                              } else {
                                                Future.delayed(Duration.zero,
                                                    () {
                                                  AutoRouter.of(context).pop();
                                                });
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              primary: Colors.black54,
                                              backgroundColor: Colors.white30,
                                            ),
                                            child: Column(children: [
                                              const Icon(Icons.crop_free,
                                                  size: 32),
                                              Text(AppLocalizations.of(context)
                                                  .crop),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: _imageFile != null ||
                                              _videoFile != null
                                          ? () async {
                                              dynamic file =
                                                  await AutoRouter.of(context)
                                                      .push(PreviewRoute(
                                                          fileList:
                                                              allFileList));
                                              Future.delayed(Duration.zero, () {
                                                AutoRouter.of(context)
                                                    .pop(file);
                                              });
                                            }
                                          : null,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          image: _imageFile != null
                                              ? DecorationImage(
                                                  image: FileImage(_imageFile!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: videoController != null &&
                                                videoController!
                                                    .value.isInitialized
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                child: AspectRatio(
                                                  aspectRatio: videoController!
                                                      .value.aspectRatio,
                                                  child: VideoPlayer(
                                                      videoController!),
                                                ),
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _isVideoCameraSelected
                                          ? () async {
                                              if (_isRecordingInProgress) {
                                                XFile? rawVideo =
                                                    await stopVideoRecording();
                                                File videoFile =
                                                    File(rawVideo!.path);

                                                int currentUnix = DateTime.now()
                                                    .millisecondsSinceEpoch;

                                                final directory =
                                                    await getApplicationDocumentsDirectory();

                                                String fileFormat = videoFile
                                                    .path
                                                    .split('.')
                                                    .last;

                                                _videoFile =
                                                    await videoFile.copy(
                                                  '${directory.path}/$currentUnix.$fileFormat',
                                                );

                                                _startVideoPlayer();
                                              } else {
                                                await startVideoRecording();
                                              }
                                            }
                                          : () async {
                                              try {
                                                XFile? rawImage =
                                                    await takePicture();
                                                File imageFile =
                                                    File(rawImage!.path);

                                                int currentUnix = DateTime.now()
                                                    .millisecondsSinceEpoch;

                                                final directory =
                                                    await getApplicationDocumentsDirectory();

                                                String fileFormat = imageFile
                                                    .path
                                                    .split('.')
                                                    .last;

                                                //debugPrint(fileFormat);

                                                await imageFile.copy(
                                                  '${directory.path}/$currentUnix.$fileFormat',
                                                );

                                                Future.delayed(Duration.zero,
                                                    () {
                                                  AutoRouter.of(context)
                                                      .pop(imageFile);
                                                });
                                              } catch (e) {
                                                //debugPrint(e.toString());
                                              }
                                            },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: _isVideoCameraSelected
                                                ? Colors.white
                                                : Colors.white38,
                                            size: 80,
                                          ),
                                          Icon(
                                            Icons.circle,
                                            color: _isVideoCameraSelected
                                                ? Colors.red
                                                : Colors.white,
                                            size: 65,
                                          ),
                                          _isVideoCameraSelected &&
                                                  _isRecordingInProgress
                                              ? const Icon(
                                                  Icons.stop_rounded,
                                                  color: Colors.white,
                                                  size: 32,
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: _isRecordingInProgress
                                          ? () async {
                                              if (controller!
                                                  .value.isRecordingPaused) {
                                                await resumeVideoRecording();
                                              } else {
                                                await pauseVideoRecording();
                                              }
                                            }
                                          : () {
                                              setState(() {
                                                _isCameraInitialized = false;
                                              });
                                              onNewCameraSelected(cameras[
                                                  _isRearCameraSelected
                                                      ? 1
                                                      : 0]);
                                              setState(() {
                                                _isRearCameraSelected =
                                                    !_isRearCameraSelected;
                                              });
                                            },
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          const Icon(
                                            Icons.circle,
                                            color: Colors.black38,
                                            size: 60,
                                          ),
                                          _isRecordingInProgress
                                              ? controller!
                                                      .value.isRecordingPaused
                                                  ? const Icon(
                                                      Icons.play_arrow,
                                                      color: Colors.white,
                                                      size: 30,
                                                    )
                                                  : const Icon(
                                                      Icons.pause,
                                                      color: Colors.white,
                                                      size: 30,
                                                    )
                                              : Icon(
                                                  _isRearCameraSelected
                                                      ? Icons.camera_front
                                                      : Icons.camera_rear,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _buildLoading()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(),
                      _isCameraExists
                          ? Text(AppLocalizations.of(context).pleaseAllowCamera,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24))
                          : Text(AppLocalizations.of(context).noCameraFound,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24)),
                      const SizedBox(height: 24),
                      _isCameraExists
                          ? ElevatedButton(
                              onPressed: () {
                                getPermissionStatus();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .giveCameraPermission,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox.shrink();
  }
}
