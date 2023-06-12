import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/blocs.dart';
import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../common/styles.dart';
import '../../data/models/child_model.dart';
import '../../data/models/moment_model.dart';
import '../../data/models/user_model.dart';
import '../../repositories/repositories.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_mouse_pointer.dart';

class SelectChildPage extends StatefulWidget {
  const SelectChildPage({Key? key, this.childId, required this.user, this.momentModel})
      : super(key: key);
  final String? childId;
  final UserModel user;
  final MomentModel? momentModel;

  @override
  State<SelectChildPage> createState() => _SelectChildPageState();
}

class _SelectChildPageState extends State<SelectChildPage> {
  final ValueNotifier<List<String>> _childId = ValueNotifier([]);
  final ValueNotifier<bool> _isParentSelected = ValueNotifier(false);
  List<ChildModel> _childrenList = [];

  @override
  void initState() {
    super.initState();

    if (widget.childId != null) {
      _childId.value.add(widget.childId!);
    }

    if (widget.momentModel != null) {
      _childId.value = widget.momentModel!.childIds;
      _isParentSelected.value = widget.momentModel!.forType == 'all';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.black,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: Colors.black,
        title: Text(AppLocalizations.of(context).selectChild,
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
              onPressed: () {
                if (_childrenList.isEmpty) {
                  SharedCode.showAlertDialog(context, AppLocalizations.of(context).information,
                      AppLocalizations.of(context).postMomentWithoutChildAlert, () {
                    AutoRouter.of(context).replace(ChildFormRoute());
                  });
                } else {
                  if (_childId.value.isEmpty) {
                    SharedCode.showSnackBar(
                        context, 'error', AppLocalizations.of(context).pickOneAlert);
                  } else {
                    MomentModel? momentModel = widget.momentModel;
                    if (widget.momentModel != null) {
                      momentModel = MomentModel(
                          id: widget.momentModel!.id,
                          caption: widget.momentModel!.caption,
                          title: widget.momentModel!.title,
                          childIds: _childId.value,
                          parentId: widget.momentModel!.parentId,
                          isPrivate: widget.momentModel!.isPrivate,
                          isReported: widget.momentModel!.isReported,
                          photos: widget.momentModel!.photos,
                          reaction: widget.momentModel!.reaction,
                          date: widget.momentModel!.date,
                          createdAt: widget.momentModel!.createdAt,
                          forType: _isParentSelected.value ? 'all' : 'child');
                    }
                    AutoRouter.of(context).navigate(GalleryListRoute(
                        childId: _childId.value,
                        isParentSelected: _isParentSelected.value,
                        momentModel: momentModel));
                  }
                }
              },
              child: Text(AppLocalizations.of(context).next,
                  style: const TextStyle(color: ColorValues.darkerBlue)))
        ],
      ),
      body: BlocProvider(
        create: (context) => ChildBloc(
          repository: context.read<ChildRepository>(),
        )..add(LoadChildByParentId(id: FirebaseAuth.instance.currentUser!.uid)),
        child: BlocBuilder<ChildBloc, ChildState>(
          builder: (context, state) {
            List<ChildModel> list = [];

            if (state is ChildLoading) {
              context.loaderOverlay.show();
              return const SizedBox.shrink();
            }

            if (state is ChildLoaded) {
              context.loaderOverlay.hide();
              list = state.children;
              _childrenList = list;
            }

            int count = 2;
            double width = MediaQuery.of(context).size.width;
            if (width <= 600) {
              count = 2;
            } else if (width > 600 && width < 1080) {
              count = 3;
            } else {
              count = 4;
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(Styles.defaultPadding),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count, crossAxisSpacing: 0, mainAxisSpacing: 3.h),
                  itemCount: list.length + 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    ChildModel? model = i == 0 ? null : list[i - 1];
                    return CustomMousePointer(
                      child: GestureDetector(
                        onTap: () {
                          // if model is null, it means the current index is for parent
                          if (model == null) {
                            if (_isParentSelected.value) {
                              _isParentSelected.value = false;
                              _childId.value.clear();
                            } else {
                              _isParentSelected.value = true;
                              _childId.value.clear();
                              _childId.value.addAll(list.map((e) => e.id!));
                            }
                            _isParentSelected.notifyListeners();
                          } else {
                            int index = _childId.value.indexWhere((element) => element == model.id);
                            if (index == -1) {
                              _childId.value.add(model.id!);
                            } else {
                              _childId.value.removeAt(index);
                            }

                            _isParentSelected.value = _childId.value.length == list.length;
                          }
                          _childId.notifyListeners();
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            model == null
                                ? ValueListenableBuilder(
                                    valueListenable: _isParentSelected,
                                    builder: (_, __, ___) {
                                      return Expanded(
                                        child: Opacity(
                                          opacity: _isParentSelected.value ? 1 : 0.5,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: CircleAvatar(
                                                  radius: 30.w,
                                                  backgroundColor: ColorValues.loadingGrey,
                                                  backgroundImage:
                                                      widget.user.avatarUrl?.display.isEmpty ?? true
                                                          ? null
                                                          : NetworkImage(
                                                              widget.user.avatarUrl!.display),
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(AppLocalizations.of(context).all,
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 14.sp))
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                : ValueListenableBuilder(
                                    valueListenable: _childId,
                                    builder: (_, __, ___) {
                                      return Expanded(
                                        child: Opacity(
                                          opacity: _childId.value.contains(model.id!) ? 1 : 0.5,
                                          child: Column(
                                            children: [
                                              Expanded(
                                                child: CircleAvatar(
                                                  radius: 30.w,
                                                  backgroundColor: ColorValues.loadingGrey,
                                                  backgroundImage: model.avatarUrl.display.isEmpty
                                                      ? null
                                                      : NetworkImage(model.avatarUrl.display),
                                                ),
                                              ),
                                              SizedBox(height: 1.h),
                                              Text(model.nickName ?? model.fullName,
                                                  style: TextStyle(
                                                      color: Colors.white, fontSize: 14.sp))
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
