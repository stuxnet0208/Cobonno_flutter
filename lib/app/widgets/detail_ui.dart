import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../blocs/blocs.dart';
import '../common/color_values.dart';
import '../common/shared_code.dart';
import '../data/models/child_model.dart';
import '../data/models/moment_model.dart';
import '../data/models/reaction_model.dart';
import '../data/models/user_model.dart';
import '../repositories/repositories.dart';
import '../routes/router.gr.dart';
import '../ui/screens.dart';
import 'custom_carousel.dart';
import 'custom_mouse_pointer.dart';
import 'readmore.dart';
import 'dart:ui' as ui;

class DetailUi extends StatefulWidget {
  DetailUi(
      {Key? key,
      required this.list,
      required this.index,
      required this.userModel,
      this.paddingTop = 0,
      this.context})
      : super(key: key);

  final ValueNotifier<List<MomentModel>> list;
  final int index;
  final UserModel userModel;
  final double paddingTop;
  BuildContext? context;

  @override
  State<DetailUi> createState() => _DetailUiState();
}

class _DetailUiState extends State<DetailUi> {
  final _emojiParser = EmojiParser();
  final CarouselController _controller = CarouselController();
  final ValueNotifier<int> _current = ValueNotifier(0);
  List<ChildModel> _childList = [];

  @override
  Widget build(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    MomentModel model = widget.list.value[widget.index];

    List<Widget> kidActions = [];
    kidActions.add(CustomMousePointer(
      child: GestureDetector(
        onTap: () {
          widget.list.value[widget.index].isShowReaction =
              !widget.list.value[widget.index].isShowReaction;
          widget.list.notifyListeners();
        },
        child: Icon(Icons.thumb_up_outlined,
            color: model.isShowReaction ? Colors.grey[350] : Colors.black),
      ),
    ));
    kidActions.add(SizedBox(width: 3.w));
    // Icon Love
    // kidActions.add(CustomMousePointer(
    //   child: LikeButton(
    //       likeBuilder: (isLiked) {
    //         return isLiked
    //             ? const Icon(Icons.favorite, color: Colors.red)
    //             : const Icon(Icons.favorite_border);
    //       },
    //       isLiked:
    //           widget.userModel.favorites.indexWhere((e) => e == model.id) != -1,
    //       onTap: (isLiked) async {
    //         if (widget.userModel.favorites.indexWhere((e) => e == model.id) !=
    //             -1) {
    //           ParentRepository()
    //               .removeMomentFromFavorite(widget.userModel.id, model.id);
    //         } else {
    //           ParentRepository()
    //               .addMomentToFavorite(widget.userModel.id, model.id);
    //         }
    //         return !isLiked;
    //       }),
    // ));

    String date = DateFormat('yyyy/M/d').format(model.date ?? DateTime.now());

    List<Widget> parentActions = [];
    bool isUser = model.parentId == FirebaseAuth.instance.currentUser?.uid;
    bool isSuperAdmin = widget.userModel.role == 'superadmin';
    if (isUser || isSuperAdmin) {
      parentActions.add(CustomMousePointer(
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 2.0 * 56.0,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          itemBuilder: (context) => [
            if (isUser)
              PopupMenuItem(
                  onTap: () {
                    if (_childList.isNotEmpty) {
                      if (_childList.length == 1) {
                        AutoRouter.of(context).navigate(GalleryListRoute(
                            childId: [_childList.first.id!],
                            isParentSelected: true,
                            momentModel: model));
                      } else {
                        AutoRouter.of(context).navigate(SelectChildRoute(
                            momentModel: model, user: widget.userModel));
                      }
                    }
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined),
                      SizedBox(width: 3.w),
                      Text(AppLocalizations.of(context).editMomentPopUp,
                          style: TextStyle(fontSize: 11.sp)),
                    ],
                  )),
            PopupMenuItem(
                onTap: () {
                  SharedCode.showAlertDialog(
                    context,
                    AppLocalizations.of(context).deleteMoment,
                    AppLocalizations.of(context).deleteMomentConfirmation,
                    () async {
                      context.loaderOverlay.show();
                      try {
                        isSuperAdmin
                            ? await MomentRepository().deleteMomentAdmin(
                                context, model.id, 'Deleted by Admin')
                            : await MomentRepository()
                                .deleteMoment(context, model.id);
                        Future.delayed(Duration.zero, () {
                          SharedCode.showSnackBar(context, 'success',
                              AppLocalizations.of(context).deleteMomentSuccess);
                          AutoRouter.of(context).pushAndPopUntil(
                              const HomeRoute(),
                              predicate: (Route<dynamic> route) => false);
                        });
                      } catch (e) {
                        SharedCode.showErrorDialog(context,
                            AppLocalizations.of(context).error, e.toString());
                      }
                      context.loaderOverlay.hide();
                    },
                    AppLocalizations.of(context).no,
                    AppLocalizations.of(context).yes,
                  );
                },
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline),
                    SizedBox(width: 3.w),
                    Text(AppLocalizations.of(context).deleteMomentPopUp,
                        style: TextStyle(fontSize: 11.sp)),
                  ],
                )),
            if (!isUser) _buildReportMenuItem(context, model)
          ],
        ),
      ));
    } else {
      parentActions.add(CustomMousePointer(
        child: PopupMenuButton<String>(
          padding: EdgeInsets.zero,
          itemBuilder: (context) => [
            if (!isUser) _buildReportMenuItem(context, model),
          ],
        ),
      ));
    }

    Image image = Image.network(model.photos.first.photoUrlModel.listView);
    Completer<ui.Image> completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      completer.complete(info.image);
    }));

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: widget.paddingTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocProvider(
            create: (context) =>
                ParentBloc(repository: context.read<ParentRepository>())
                  ..add(LoadParentById(id: model.parentId, context: context)),
            child: BlocBuilder<ParentBloc, ParentState>(
              builder: (context, state) {
                String parentUrl = '';
                String parentName = '';

                if (state is ParentLoaded) {
                  if (state.parent.id == model.parentId) {
                    parentName = state.parent.username;
                    parentUrl = state.parent.avatarUrl?.display ?? '';
                  } else {
                    context.read<ParentBloc>().add(
                        LoadParentById(id: model.parentId, context: context));
                  }
                }

                return _buildDefaultContainer(parentUrl, parentName,
                    parentActions, null, false, null, null,
                    parentId: model.parentId);
              },
            ),
          ),
          FutureBuilder(
              future: completer.future,
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.hasData) {
                  return ValueListenableBuilder(
                      valueListenable: widget.list,
                      builder: (_, __, ___) {
                        for (var element in model.photos) {
                          // debugPrint('model ${model.caption}, ${element.photoUrlModel.listView}');
                        }
                        return AspectRatio(
                          aspectRatio:
                              snapshot.data!.width / snapshot.data!.height,
                          child: Stack(
                            children: [
                              Container(color: ColorValues.loadingGrey),
                              CustomCarousel(
                                  key: UniqueKey(),
                                  imgList: model.photos,
                                  controller: _controller,
                                  current: _current),
                              model.isPrivate
                                  ? const Positioned.fill(
                                      child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.all(12),
                                            child: Icon(Icons.lock_outlined,
                                                color: Colors.white),
                                          )))
                                  : const SizedBox.shrink(),
                              widget.list.value[widget.index].isShowReaction
                                  ? Positioned.fill(
                                      child: Align(
                                          child: _buildCircularEmoji(
                                              widget.index)))
                                  : const SizedBox.shrink()
                            ],
                          ),
                        );
                      });
                } else {
                  return Container(
                    width: double.infinity,
                    height: 30.h,
                    color: ColorValues.loadingGrey,
                  );
                }
              }),
          _buildDefaultContainer(
              '', '', kidActions, model, true, _controller, _current,
              parentId: model.parentId),
          if (model.title != null && (model.title?.trim().isNotEmpty ?? false))
            _defaultPadding(
                child: Text(model.title ?? '',
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold))),
          _defaultPadding(
              child: Text(date,
                  style: TextStyle(
                      fontSize: 9.sp, color: ColorValues.darkGreyAlt))),
          _defaultPadding(
              child: ReadMoreText(
            model.caption,
            trimLines: 3,
            colorClickableText: Colors.grey,
            trimMode: TrimMode.line,
            style: Theme.of(context).textTheme.bodyText2,
            trimCollapsedText: AppLocalizations.of(context).readMore,
            trimExpandedText: AppLocalizations.of(context).readLess,
            moreStyle: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25),
            lessStyle: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
                fontWeight: FontWeight.w400,
                letterSpacing: 0.25),
          )),
          kIsWeb ? SizedBox(height: 1.h) : const SizedBox.shrink(),
          ValueListenableBuilder(
              valueListenable: widget.list,
              builder: (_, __, ___) {
                return _buildEmojiChips(model.reaction);
              }),
          SizedBox(height: kIsWeb ? 2.h : 1.h),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildReportMenuItem(
      BuildContext context, MomentModel model) {
    return PopupMenuItem(
        onTap: () {
          ExplorePage.showPanel(context, true, model.id);
          FavoritePage.showPanel(context, true, model.id);
          PatronizePage.showPanel(context, true, model.id);
          HallPage.showPanel(context, true, model.id);
          ProfilePage.showPanel(context, true, model.id);
        },
        child: Row(
          children: [
            const Icon(Icons.report_outlined, color: Colors.red),
            SizedBox(width: 3.w),
            Text(AppLocalizations.of(context).report,
                style: TextStyle(fontSize: 11.sp)),
          ],
        ));
  }

  Widget _buildEmojiChips(ReactionModel reaction) {
    return _defaultPadding(
      child: Wrap(
        spacing: 5,
        children: [
          if (reaction.thumb.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(_emojiParser
                    .emojify(':thumbsup: ${reaction.thumb.length}'))),
          if (reaction.spark.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(_emojiParser
                    .emojify(':sparkles: ${reaction.spark.length}'))),
          if (reaction.love.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(_emojiParser
                    .emojify(':heart_eyes: ${reaction.love.length}'))),
          if (reaction.lol.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(_emojiParser.emojify(
                    ':rolling_on_the_floor_laughing: ${reaction.lol.length}'))),
          if (reaction.wow.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(
                    _emojiParser.emojify(':hushed: ${reaction.wow.length}'))),
          if (reaction.clap.isNotEmpty)
            Chip(
                backgroundColor: Colors.grey[100],
                label: Text(
                    _emojiParser.emojify(':clap: ${reaction.clap.length}'))),
        ],
      ),
    );
  }

  Widget _buildCircularEmoji(int index) {
    return _defaultPadding(
      vertical: 1.h,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(child: _buildCircularEmojiItem('thumbsup', index, context)),
          SizedBox(width: 2.w),
          Flexible(child: _buildCircularEmojiItem('sparkles', index, context)),
          SizedBox(width: 2.w),
          Flexible(
              child: _buildCircularEmojiItem('heart_eyes', index, context)),
          SizedBox(width: 2.w),
          Flexible(
              child: _buildCircularEmojiItem(
                  'rolling_on_the_floor_laughing', index, context)),
          SizedBox(width: 2.w),
          Flexible(child: _buildCircularEmojiItem('hushed', index, context)),
          SizedBox(width: 2.w),
          Flexible(child: _buildCircularEmojiItem('clap', index, context)),
        ],
      ),
    );
  }

  Widget _buildCircularEmojiItem(String text, int index, BuildContext context) {
    String emoji = 'thumb';
    switch (text) {
      case 'thumbsup':
        emoji = 'thumb';
        break;
      case 'heart_eyes':
        emoji = 'love';
        break;
      case 'rolling_on_the_floor_laughing':
        emoji = 'lol';
        break;
      case 'clap':
        emoji = 'clap';
        break;
      case 'hushed':
        emoji = 'wow';
        break;
      case 'sparkles':
        emoji = 'spark';
        break;
    }

    Map<String, Object?> map = widget.list.value[index].reaction.toJson();
    List<String> emojiIds = map[emoji] as List<String>;
    bool isDisabled = emojiIds.contains(widget.userModel.id);

    return Stack(
      children: [
        Positioned(
          bottom: 1.h,
          child: LikeButton(
            size: 13.w,
            padding: EdgeInsets.zero,
            animationDuration: const Duration(milliseconds: 1000),
            isLiked: isDisabled,
            onTap: (isLiked) async {
              Future.delayed(Duration(milliseconds: isLiked ? 0 : 900),
                  () async {
                if (isDisabled) {
                  await MomentRepository().removeUserReaction(
                      widget.list.value[index].id, emoji, widget.userModel.id);
                } else {
                  await MomentRepository().addUserReaction(
                      widget.list.value[index].id, emoji, widget.userModel.id);
                }
                widget.list.value[index].isShowReaction = false;
                widget.list.notifyListeners();
                context.read<MomentBloc>().add(
                    LoadMomentByDocId(id: widget.list.value[index].id));
              });
              return !isLiked;
            },
            likeBuilder: (isLiked) {
              return Container(
                decoration: BoxDecoration(
                    color: isLiked ? Colors.grey[400] : Colors.white,
                    shape: BoxShape.circle),
                child: Center(
                    child: Text(
                  _emojiParser.emojify(':$text:'),
                  style: TextStyle(fontSize: 20.sp),
                  textAlign: TextAlign.center,
                )),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _defaultPadding(
      {required Widget child, double? horizontal, double? vertical}) {
    return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontal ?? 3.w, vertical: vertical ?? 0),
        child: child);
  }

  Widget _buildDefaultContainer(
      String? imageUrl,
      String name,
      List<Widget> actions,
      MomentModel? model,
      bool isChild,
      CarouselController? controller,
      ValueNotifier? current,
      {required String parentId}) {
    //debugPrint('model $model');
    return _defaultPadding(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        child: Column(
          children: [
            if (controller != null)
              ValueListenableBuilder(
                  valueListenable: current!,
                  builder: (_, __, ___) {
                    return model!.photos.length > 1
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: model.photos.asMap().entries.map((entry) {
                              return GestureDetector(
                                onTap: () =>
                                    controller.animateToPage(entry.key),
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 4.0),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(
                                              current.value == entry.key
                                                  ? 0.9
                                                  : 0.4)),
                                ),
                              );
                            }).toList(),
                          )
                        : const SizedBox.shrink();
                  }),
            if (controller != null) SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: imageUrl == null
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                isChild
                    ? Expanded(
                        child: BlocProvider(
                          create: (context) => ChildBloc(
                            repository: context.read<ChildRepository>(),
                          )..add(LoadChildByParentId(id: model!.parentId)),
                          child: BlocBuilder<ChildBloc, ChildState>(
                            builder: (context, state) {
                              List<ChildModel> children = [];
                              List<ChildModel> finalChildren = [];

                              if (state is ChildLoaded) {
                                bool isChildExist = false;
                                _childList = state.children;
                                finalChildren.addAll(state.children);
                                if (model != null) {
                                  for (var data in state.children) {
                                    if (model.childIds.contains(data.id)) {
                                      isChildExist = true;
                                    } else {
                                      finalChildren.removeWhere(
                                          (element) => element.id == data.id);
                                    }
                                  }
                                }
                                if (isChildExist) {
                                  context.read<ChildBloc>().add(
                                      LoadChildByParentId(id: model!.parentId));
                                }
                                finalChildren.sort(
                                    (a, b) => a.birthday.compareTo(b.birthday));
                                children.addAll(finalChildren);
                              }

                              return children.isEmpty
                                  ? const SizedBox.shrink()
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: List.generate(children.length,
                                            (index) {
                                          ChildModel child = children[index];
                                          return GestureDetector(
                                            onTap: () {
                                              AutoRouter.of(context).navigate(
                                                  ProfileRoute(
                                                      parentId: parentId,
                                                      childId: child.id));
                                            },
                                            child: Row(
                                              children: [
                                                CustomMousePointer(
                                                  child: CircleAvatar(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                      backgroundImage: child
                                                              .avatarUrl
                                                              .display
                                                              .isEmpty
                                                          ? null
                                                          : NetworkImage(child
                                                              .avatarUrl
                                                              .display),
                                                      radius: 5.w),
                                                ),
                                                SizedBox(width: 2.w),
                                                CustomMousePointer(
                                                  child: Text(
                                                      child.nickName ??
                                                          child.fullName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyText2),
                                                ),
                                                SizedBox(width: 3.w),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                    );
                            },
                          ),
                        ),
                      )
                    : Flexible(
                        child: GestureDetector(
                          onTap: () {
                            AutoRouter.of(context)
                                .navigate(ProfileRoute(parentId: parentId));
                          },
                          child: Row(
                            children: [
                              CustomMousePointer(
                                child: CircleAvatar(
                                    backgroundColor: imageUrl == null
                                        ? Colors.transparent
                                        : ColorValues.loadingGrey,
                                    backgroundImage: imageUrl?.isEmpty ?? true
                                        ? null
                                        : NetworkImage(imageUrl!),
                                    radius: 5.w),
                              ),
                              imageUrl == null
                                  ? const SizedBox.shrink()
                                  : SizedBox(width: 3.w),
                              imageUrl == null
                                  ? const SizedBox.shrink()
                                  : isChild
                                      ? CustomMousePointer(
                                          child: Text(name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )
                                      : Expanded(
                                          child: CustomMousePointer(
                                          child: Text(name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText2),
                                        )),
                            ],
                          ),
                        ),
                      ),
                Row(children: actions),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
