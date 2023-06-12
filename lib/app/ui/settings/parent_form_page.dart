import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/widgets/image_cropper/custom_multi_image_cropper.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/blocs.dart';
import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../data/models/avatar_model.dart';
import '../../data/models/user_model.dart';
import '../../repositories/repositories.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/reconnecting_widget.dart';

class ParentFormPage extends StatefulWidget {
  const ParentFormPage({Key? key, required this.parentModel}) : super(key: key);
  final UserModel parentModel;

  @override
  State<ParentFormPage> createState() => _ParentFormPageState();
}

class _ParentFormPageState extends State<ParentFormPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;

  String _imageUrl = '';
  late UserModel parentModel;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parentModel = widget.parentModel;
    _nameController.text = parentModel.username;
    _descriptionController.text = parentModel.description ?? '';
    _imageUrl = parentModel.avatarUrl?.display ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SharedCode.lightStatusBar(),
          title: Text(AppLocalizations.of(context).profile)),
      body: BlocProvider(
        create: (context) => ParentBloc(repository: context.read<ParentRepository>()),
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
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
                                : _buildAvatar(NetworkImage(_imageUrl), isImageUrl: true)),
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
                        label: AppLocalizations.of(context).name,
                        controller: _nameController,
                        isUnderline: true,
                        validator: SharedCode(context).usernameValidator),
                    SizedBox(height: 3.h),
                    CustomTextField(
                        label: AppLocalizations.of(context).description,
                        controller: _descriptionController,
                        isUnderline: true,
                        minLines: 7,
                        validator: (s) => null,
                        textInputType: TextInputType.multiline,
                        maxLines: null,
                        required: false),
                    SizedBox(height: 12.h),
                    ElevatedButton(
                        onPressed: () {
                          _submitForm();
                        },
                        child: Text(AppLocalizations.of(context).edit)),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _displaySelectedImage() {
    return kIsWeb
        ? _buildAvatar(NetworkImage(_image!.path))
        : _buildAvatar(FileImage(File(_image!.path)));
  }

  Widget _buildAvatar(ImageProvider provider, {bool isImageUrl = false}) {
    return CircleAvatar(
      backgroundColor: ColorValues.loadingGrey,
      backgroundImage: isImageUrl ? (_imageUrl.isEmpty ? null : provider) : provider,
      radius: 12.w,
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

  Future<void> _submitForm() async {
    if (parentModel.avatarUrl == null && _image == null) {
      SharedCode.showErrorDialog(
          context, AppLocalizations.of(context).warning, AppLocalizations.of(context).emptyImage);
      return;
    }

    if (_formKey.currentState!.validate()) {
      context.loaderOverlay.show(widget: const ReconnectingWidget());
      bool isUsernameValid =
          await ParentRepository().checkIfParentUsernameValid(_nameController.text);
      if (isUsernameValid) {
        await _uploadToFirebase();
      } else {
        Future.delayed(Duration.zero, () {
          SharedCode.showErrorDialog(context, AppLocalizations.of(context).error,
              AppLocalizations.of(context).usernameAlreadyUsed);
        });
      }
      context.loaderOverlay.hide();
    }
  }

  Future<TaskSnapshot> _uploadImage(String id) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('users/$id/avatar.png');
    late UploadTask uploadTask;
    if (kIsWeb) {
      var bytes = await _image!.readAsBytes();
      uploadTask = firebaseStorageRef.putData(bytes, SettableMetadata(contentType: 'image/png'));
    } else {
      uploadTask = firebaseStorageRef.putFile(File(_image!.path));
    }
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot;
  }

  Future<void> _uploadToFirebase() async {
    try {
      parentModel = UserModel(
          id: parentModel.id,
          username: _nameController.text,
          description: _descriptionController.text,
          email: parentModel.email,
          favorites: parentModel.favorites,
          patronizeds: parentModel.patronizeds,
          momentsReported: parentModel.momentsReported,
          avatarUrl: parentModel.avatarUrl,
          avatarPath: parentModel.avatarPath,
          phoneNumber: parentModel.phoneNumber);

      await ParentRepository().updateParent(parentModel);

      if (_image != null) {
        TaskSnapshot snapshot = await _uploadImage(parentModel.id);
        String avatarUrl = await snapshot.ref.getDownloadURL();
        String avatarPath = snapshot.ref.fullPath;

        AvatarModel avatarUrlModel = AvatarModel(
            display: avatarUrl, original: avatarUrl, thumb128: avatarUrl, thumb256: avatarUrl);
        AvatarModel avatarPathModel = AvatarModel(
            display: avatarPath, original: avatarPath, thumb128: avatarPath, thumb256: avatarPath);

        parentModel = UserModel(
            id: parentModel.id,
            username: parentModel.username,
            description: parentModel.description,
            email: parentModel.email,
            favorites: parentModel.favorites,
            patronizeds: parentModel.patronizeds,
            momentsReported: parentModel.momentsReported,
            avatarUrl: avatarUrlModel,
            avatarPath: avatarPathModel,
            phoneNumber: parentModel.phoneNumber);

        await ParentRepository().updateParent(parentModel);
      }

      Future.delayed(Duration.zero, () {
        SharedCode.showSnackBar(context, 'success', AppLocalizations.of(context).dataUpdated);
        AutoRouter.of(context).pop();
      });
    } catch (e) {
      SharedCode.showErrorDialog(context, AppLocalizations.of(context).error, e.toString());
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
