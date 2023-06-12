import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sizer/sizer.dart';

import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../data/models/moment_model.dart';
import '../../data/models/photo_model.dart';
import '../../data/models/photo_path_model.dart';
import '../../data/models/reaction_model.dart';
import '../../repositories/repositories.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/reconnecting_widget.dart';

class MomentFormPage extends StatefulWidget {
  const MomentFormPage(
      {Key? key,
      required this.bytes,
      this.isParentSelected,
      this.childId,
      this.momentModel,
      required this.usedEntities})
      : super(key: key);
  final List<List<int>> bytes;
  final bool? isParentSelected;
  final List<String>? childId;
  final List<String> usedEntities;
  final MomentModel? momentModel;

  @override
  State<MomentFormPage> createState() => _MomentFormPageState();
}

class _MomentFormPageState extends State<MomentFormPage> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ValueNotifier<bool> _isPublish = ValueNotifier(true);
  // final ValueNotifier<bool> _facebook = ValueNotifier(false);
  // final ValueNotifier<bool> _twitter = ValueNotifier(false);
  // final ValueNotifier<bool> _tumblr = ValueNotifier(false);
  final ValueNotifier<DateTime> _date = ValueNotifier(DateTime.now());
  String _formattedDate = '';
  final DateFormat _dateFormat = DateFormat('yyyy/M/d HH:mm');

  @override
  void initState() {
    super.initState();
    if (widget.momentModel != null) {
      _textController.text = widget.momentModel!.caption;
      _isPublish.value = !widget.momentModel!.isPrivate;
      _titleController.text = widget.momentModel!.title ?? '';
      _date.value = widget.momentModel!.date ?? (widget.momentModel!.createdAt ?? DateTime.now());
    }
    String formattedDate = _dateFormat.format(_date.value);
    _formattedDate = formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SharedCode.lightStatusBar());
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SharedCode.lightStatusBar(),
        backgroundColor: Colors.white,
        title: Text(widget.momentModel == null
            ? AppLocalizations.of(context).addMoment
            : AppLocalizations.of(context).editMoment),
        actions: [
          TextButton(
              onPressed: () async {
                context.loaderOverlay.show(widget: const ReconnectingWidget());
                await _uploadToFirebase();
                context.loaderOverlay.hide();
              },
              child: Text(
                  widget.momentModel == null
                      ? AppLocalizations.of(context).next
                      : AppLocalizations.of(context).edit,
                  style: const TextStyle(color: ColorValues.darkerBlue)))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Divider(height: 1.5),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: CustomTextField(
                    controller: _titleController,
                    hasPadding: false,
                    isFloatingLabel: false,
                    alwaysValidate: false,
                    isTitle: true,
                    hasBorder: false,
                    isUnderline: true,
                    textInputType: TextInputType.text,
                    label:
                        '${AppLocalizations.of(context).title} (${AppLocalizations.of(context).optional})',
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 5),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 20),
                Expanded(flex: 2, child: Image.memory(Uint8List.fromList(widget.bytes.first))),
                SizedBox(width: 2.w),
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    controller: _textController,
                    hasPadding: false,
                    isFloatingLabel: false,
                    alwaysValidate: false,
                    maxLines: null,
                    minLines: 5,
                    hasBorder: false,
                    isUnderline: true,
                    textInputType: TextInputType.multiline,
                    label: AppLocalizations.of(context).writeYourMoment,
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            SizedBox(height: 2.h),
            const Divider(),
            Stack(
              children: [
                ValueListenableBuilder(
                    valueListenable: _date,
                    builder: (_, __, ___) {
                      return Row(
                        children: [
                          const SizedBox(width: 15),
                          Expanded(child: Text(AppLocalizations.of(context).date)),
                          Text(_formattedDate),
                          const SizedBox(width: 15),
                        ],
                      );
                    }),
                _buildDateTimePicker(),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const SizedBox(width: 15),
                Expanded(child: Text(AppLocalizations.of(context).publish)),
                ValueListenableBuilder(
                    valueListenable: _isPublish,
                    builder: (_, __, ___) {
                      return Switch(
                          value: _isPublish.value,
                          onChanged: (value) {
                            _isPublish.value = value;
                          });
                    }),
                const SizedBox(width: 15),
              ],
            ),
            const Divider(),
            // TODO: correctly remove me.
            // see https://app.clickup.com/t/2wuqvxm
            //   ValueListenableBuilder(
            //       valueListenable: _isPublish,
            //       builder: (_, __, ___) {
            //         return !_isPublish.value
            //             ? const SizedBox.shrink()
            //             : Column(
            //                 children: [
            //                   Row(
            //                     children: [
            //                       const SizedBox(width: 20),
            //                       Expanded(
            //                           child: Text(AppLocalizations.of(context)!
            //                               .facebook)),
            //                       ValueListenableBuilder(
            //                           valueListenable: _facebook,
            //                           builder: (_, __, ___) {
            //                             return Switch(
            //                                 value: _facebook.value,
            //                                 onChanged: (value) {
            //                                   _facebook.value = value;
            //                                 });
            //                           }),
            //                       const SizedBox(width: 20),
            //                     ],
            //                   ),
            //                   Row(
            //                     children: [
            //                       const SizedBox(width: 20),
            //                       Expanded(
            //                           child: Text(
            //                               AppLocalizations.of(context)!.twitter)),
            //                       ValueListenableBuilder(
            //                           valueListenable: _twitter,
            //                           builder: (_, __, ___) {
            //                             return Switch(
            //                                 value: _twitter.value,
            //                                 onChanged: (value) {
            //                                   _twitter.value = value;
            //                                 });
            //                           }),
            //                       const SizedBox(width: 20),
            //                     ],
            //                   ),
            //                   Row(
            //                     children: [
            //                       const SizedBox(width: 20),
            //                       Expanded(
            //                           child: Text(
            //                               AppLocalizations.of(context)!.tumblr)),
            //                       ValueListenableBuilder(
            //                           valueListenable: _tumblr,
            //                           builder: (_, __, ___) {
            //                             return Switch(
            //                                 value: _tumblr.value,
            //                                 onChanged: (value) {
            //                                   _tumblr.value = value;
            //                                 });
            //                           }),
            //                       const SizedBox(width: 20),
            //                     ],
            //                   ),
            //                 ],
            //               );
            //       })
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    OutlineInputBorder border = const OutlineInputBorder(
        gapPadding: 0, borderRadius: BorderRadius.zero, borderSide: BorderSide.none);
    return Theme(
      data: SharedCode.datePickerTheme(context),
      child: DateTimePicker(
        style: const TextStyle(color: Colors.transparent),
        type: DateTimePickerType.dateTime,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 1.h),
          isCollapsed: true,
          errorBorder: border,
          focusedBorder: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedErrorBorder: border,
        ),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        dateMask: 'yyyy/M/d HH:mm',
        initialDate: _date.value,
        initialTime: TimeOfDay.fromDateTime(_date.value),
        firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
        lastDate: DateTime.now(),
        use24HourFormat: true,
        onChanged: (val) {
          _formattedDate = val;
          DateFormat format = DateFormat('yyyy-MM-dd HH:mm');
          DateTime time = format.parse(_formattedDate);
          _date.value = time;
          // _date.value = format.parse(_formattedDate);
        },
      ),
    );
  }

  Future<TaskSnapshot> _uploadImage(String id, List<int> bytes, int momentImageIndex) async {
    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('moments/$id/moment$momentImageIndex.png');
    late UploadTask uploadTask;
    uploadTask = firebaseStorageRef.putData(
        Uint8List.fromList(bytes), SettableMetadata(contentType: 'image/png'));
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot;
  }

  Future<void> _uploadToFirebase() async {
    try {
      // TODO: fix me, current keywords handled by cloud function
      // TODO: get from repository
      // TODO: regex with japanese char
      var childIds = widget.childId ?? widget.momentModel!.childIds;
      var parentId = FirebaseAuth.instance.currentUser!.uid;
      var parent = await FirebaseFirestore.instance.collection('users').doc(parentId).get();
      var children = await parent.reference
          .collection('children')
          .where(FieldPath.documentId, whereIn: childIds)
          .get();
      var childrenNames = children.docs.map((e) => e.get('nickName') ?? e.get('fullName')).toList();
      List<String> keywords = [];
      // Thanks to https://stackoverflow.com/q/65244827
      // RegExp exp = RegExp(r"\B#\w\w+");
      RegExp exp =
          RegExp(r"(?<![\p{L}0-9])([#＃][·・ー_0-9０-９a-zA-Zａ-ｚＡ-Ｚぁ-んァ-ン一-龠]{1,24})(?![\p{L}0-9])");
      exp.allMatches(_textController.text).forEach((match) {
        if (match.group(0) != null) {
          keywords.add(match.group(0)!.replaceAll('#', ''));
        }
      });
      keywords = [
        parent.get('username'),
        ...childrenNames,
        ...{...keywords},
      ];
      String momentId = widget.momentModel?.id ?? '';
      if (widget.momentModel == null) {
        MomentModel momentModel = MomentModel(
            id: '',
            caption: _textController.text,
            title: _titleController.text,
            childIds: childIds,
            parentId: parentId,
            isPrivate: !_isPublish.value,
            isReported: false,
            photos: const [],
            date: _date.value,
            keywords: keywords,
            reaction:
                const ReactionModel(clap: [], lol: [], love: [], spark: [], thumb: [], wow: []),
            forType: widget.isParentSelected == null
                ? widget.momentModel!.forType
                : widget.isParentSelected!
                    ? 'all'
                    : 'child');
        DocumentReference reference = await MomentRepository().addMoment(momentModel);
        momentId = reference.id;
      }

      //debugPrint('moment id in moment form page: $momentId');
      List<PhotoModel> photoModels = [];

      int i = 0;
      for (var data in widget.bytes) {
        TaskSnapshot snapshot = await _uploadImage(momentId, data, i);
        String url = await snapshot.ref.getDownloadURL();
        String path = snapshot.ref.fullPath;
        photoModels.add(PhotoModel(
            photoPathModel: PhotoPathModel(tileview: path, original: path, listView: path),
            photoUrlModel: PhotoPathModel(listView: url, original: url, tileview: url)));
        i++;
      }

      MomentModel momentModel = MomentModel(
          id: momentId,
          caption: _textController.text,
          title: _titleController.text,
          childIds: childIds,
          parentId: parentId,
          isPrivate: !_isPublish.value,
          isReported: widget.momentModel == null ? false : widget.momentModel?.isReported ?? false,
          photos: photoModels,
          keywords: keywords,
          date: _date.value,
          reaction: widget.momentModel == null
              ? const ReactionModel(clap: [], lol: [], love: [], spark: [], thumb: [], wow: [])
              : widget.momentModel!.reaction,
          forType: widget.isParentSelected == null
              ? widget.momentModel!.forType
              : (widget.isParentSelected! ? 'all' : 'child'));

      await MomentRepository().updateMoment(momentModel);

      if (widget.momentModel != null) {
        PhotoManager.editor.deleteWithIds(widget.usedEntities).then((_) {
          //debugPrint('photo manager editor: used entities deleted');
        });
      }

      Future.delayed(Duration.zero, () {
        SharedCode.showSnackBar(
            context,
            'success',
            widget.momentModel == null
                ? AppLocalizations.of(context).dataAdded
                : AppLocalizations.of(context).dataUpdated);
        AutoRouter.of(context)
            .pushAndPopUntil(const HomeRoute(), predicate: (Route<dynamic> route) => false);
      });
    } catch (e) {
      SharedCode.showErrorDialog(context, AppLocalizations.of(context).error, e.toString());
    }
  }
}
