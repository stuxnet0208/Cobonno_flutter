import 'dart:developer';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cobonno/app/widgets/image_cropper/custom_multi_image_cropper.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../data/models/avatar_model.dart';
import '../../data/models/child_model.dart';
import '../../repositories/repositories.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/reconnecting_widget.dart';

class ChildFormPage extends StatefulWidget {
  const ChildFormPage({Key? key, this.childModel}) : super(key: key);
  final ChildModel? childModel;

  @override
  State<ChildFormPage> createState() => _ChildFormPageState();
}

class _ChildFormPageState extends State<ChildFormPage> {
  final TextEditingController _trueNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  DateTime? _birthdayDate;
  String _imageUrl = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.childModel != null) {
      ChildModel model = widget.childModel!;
      _trueNameController.text = model.fullName;
      _nickNameController.text = model.nickName ?? '';
      String formattedDate = DateFormat('yyyy/M/d').format(model.birthday);
      _birthdayController.text = formattedDate;
      _birthdayDate = model.birthday;
      _imageUrl = model.avatarUrl.display;
      return;
    }
    _checkChildren();
  }

  Future<void> _checkChildren() async {
    bool ifHasChildren = await AuthRepository().isHasChildren();
    if (!ifHasChildren) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
        SharedCode.showInfoDialog(
          context,
          AppLocalizations.of(context).warning,
          AppLocalizations.of(context).registerChildPopUp,
          AppLocalizations.of(context).yes,
        );
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SharedCode.lightStatusBar(),
          title: Text(AppLocalizations.of(context).childForm)),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 5.h),
                  Center(
                      child: _image != null
                          ? _displaySelectedImage()
                          : _imageUrl.isEmpty
                              ? const SizedBox.shrink()
                              : _buildAvatar(NetworkImage(_imageUrl),
                                  isImageUrl: true)),
                  SizedBox(height: 1.5.h),
                  Center(
                    child: OutlinedButton(
                        onPressed: () {
                          _pickImage();
                        },
                        child: Text(AppLocalizations.of(context).editImage)),
                  ),
                  SizedBox(height: 5.h),
                  CustomTextField(
                      label: AppLocalizations.of(context).trueName,
                      controller: _trueNameController,
                      isUnderline: true,
                      validator: SharedCode(context).emptyValidator),
                  SizedBox(height: 3.h),
                  CustomTextField(
                      label: AppLocalizations.of(context).nickName,
                      controller: _nickNameController,
                      validator: (s) => null,
                      isUnderline: true,
                      required: false),
                  SizedBox(height: 1.h),
                  Text(AppLocalizations.of(context).nickNameText,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          color: ColorValues.darkRed, fontSize: 9.sp)),
                  SizedBox(height: 3.h),
                  GestureDetector(
                      onTap: () {
                        _showDatePicker();
                      },
                      child: AbsorbPointer(
                          child: CustomTextField(
                              label: AppLocalizations.of(context).birthday,
                              controller: _birthdayController,
                              isUnderline: true,
                              validator: SharedCode(context).emptyValidator))),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                      onPressed: () {
                        _submitChild();
                      },
                      child: Text(widget.childModel == null
                          ? AppLocalizations.of(context).add
                          : AppLocalizations.of(context).edit)),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    DateTime? date = await showDatePicker(
      builder: (context, child) {
        return Theme(
            data: SharedCode.datePickerTheme(context),
            child: child ?? const SizedBox.shrink());
      },
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      context: context,
      initialDate: _birthdayDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      _birthdayDate = date;
      String formattedDate = DateFormat('yyyy/M/d').format(date);
      setState(() {
        _birthdayController.text = formattedDate;
      });
    }
  }

  Widget _displaySelectedImage() {
    return kIsWeb
        ? _buildAvatar(NetworkImage(_image!.path))
        : _buildAvatar(FileImage(File(_image!.path)));
  }

  Widget _buildAvatar(ImageProvider provider, {bool isImageUrl = false}) {
    return CircleAvatar(
      backgroundColor: ColorValues.loadingGrey,
      backgroundImage:
          isImageUrl ? (_imageUrl.isEmpty ? null : provider) : provider,
      radius: 40,
    );
  }

  Future<void> _pickImage() async {
    Color primaryColor = Theme.of(context).primaryColor;
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      CustomMultiImageCrop.startCropping(
          context: context,
          activeColor: primaryColor,
          files: [File(image.path)],
          callBack: (List<File> images) {
            if (images.isNotEmpty) {
              setState(() {
                _image = XFile(images.first.path);
              });
            }
          });
    }
  }

  Future<void> _submitChild() async {
    if (widget.childModel == null && _image == null) {
      SharedCode.showErrorDialog(context, AppLocalizations.of(context).warning,
          AppLocalizations.of(context).emptyImage);
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show(widget: const ReconnectingWidget());
      await _uploadToFirebase();
      context.loaderOverlay.hide();
    }
  }

  Future<TaskSnapshot> _uploadImage(String childId) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(
        'users/${FirebaseAuth.instance.currentUser!.uid}/children/$childId/avatar.png');
    late UploadTask uploadTask;
    if (kIsWeb) {
      var bytes = await _image!.readAsBytes();
      uploadTask = firebaseStorageRef.putData(
          bytes, SettableMetadata(contentType: 'image/png'));
    } else {
      uploadTask = firebaseStorageRef.putFile(File(_image!.path));
    }
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot;
  }

  Future<void> _uploadToFirebase() async {
    try {
      AvatarModel avatarModel = const AvatarModel(
          display: '', original: '', thumb128: '', thumb256: '');
      String parentId = FirebaseAuth.instance.currentUser!.uid;
      ChildModel model = ChildModel(
          fullName: _trueNameController.text,
          nickName: _nickNameController.text.trim().isEmpty
              ? null
              : _nickNameController.text,
          birthday: _birthdayDate!,
          avatarUrl: avatarModel,
          avatarPath: avatarModel);

      if (widget.childModel == null) {
        DocumentReference reference =
            await ChildRepository().addChild(parentId, model);
        model = ChildModel(
            fullName: model.fullName,
            avatarPath: model.avatarPath,
            avatarUrl: model.avatarUrl,
            birthday: model.birthday,
            nickName: model.nickName,
            id: reference.id);
      } else {
        model = ChildModel(
            fullName: model.fullName,
            avatarPath: widget.childModel!.avatarPath,
            avatarUrl: widget.childModel!.avatarUrl,
            birthday: model.birthday,
            nickName: model.nickName,
            id: widget.childModel!.id);

        await ChildRepository()
            .updateChild(parentId, widget.childModel!, model);
      }

      if (_image != null) {
        TaskSnapshot snapshot = await _uploadImage(model.id!);
        String avatarUrl = await snapshot.ref.getDownloadURL();
        String avatarPath = snapshot.ref.fullPath;

        AvatarModel avatarUrlModel = AvatarModel(
            display: avatarUrl,
            original: avatarUrl,
            thumb128: avatarUrl,
            thumb256: avatarUrl);
        AvatarModel avatarPathModel = AvatarModel(
            display: avatarPath,
            original: avatarPath,
            thumb128: avatarPath,
            thumb256: avatarPath);

        model = ChildModel(
            fullName: model.fullName,
            avatarPath: avatarPathModel,
            avatarUrl: avatarUrlModel,
            birthday: model.birthday,
            nickName: model.nickName,
            id: model.id);

        await ChildRepository().updateChild(parentId, model, model);
      }

      Future.delayed(Duration.zero, () {
        SharedCode.showSnackBar(
            context,
            'success',
            widget.childModel == null
                ? AppLocalizations.of(context).dataAdded
                : AppLocalizations.of(context).dataUpdated);
        AutoRouter.of(context).pop();
      });
    } catch (e) {
      SharedCode.showErrorDialog(
          context, AppLocalizations.of(context).error, e.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _trueNameController.dispose();
    _nickNameController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }
}
