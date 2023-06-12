import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../blocs/blocs.dart';
import '../common/color_values.dart';
import '../common/shared_code.dart';
import '../data/models/child_model.dart';
import '../data/models/moment_model.dart';
import '../data/models/user_model.dart';
import '../repositories/repositories.dart';
import '../routes/router.gr.dart';
import 'custom_mouse_pointer.dart';
import 'hall_ui.dart';
import 'reconnecting_widget.dart';

class ProfileUi extends StatefulWidget {
  const ProfileUi(
      {Key? key, required this.parentId, this.childId, required this.type})
      : super(key: key);
  final String parentId, type;
  final String? childId;

  @override
  State<ProfileUi> createState() => _ProfileUiState();
}

class _ProfileUiState extends State<ProfileUi> {
  UserModel? _model;
  final ValueNotifier<List<MomentModel>> _list =
      ValueNotifier<List<MomentModel>>([]);
  final ValueNotifier<List<MomentModel>> _grid =
      ValueNotifier<List<MomentModel>>([]);
  final ValueNotifier<List<ChildModel>> _childList =
      ValueNotifier<List<ChildModel>>([]);
  final ValueNotifier<int> _selectedKid = ValueNotifier<int>(0);
  final ValueNotifier<String?> _childId = ValueNotifier<String?>(null);
  final ValueNotifier<Key> _uniqueKey = ValueNotifier(const Key('1'));

  @override
  void initState() {
    _childId.value = widget.childId;
    super.initState();
  }

  void _setUniqueKey(String key) {
    _uniqueKey.value = Key(key);
    _uniqueKey.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => MomentBloc(
                  momentRepository: context.read<MomentRepository>(),
                )),
        BlocProvider(
            create: (context) => ChildBloc(
                  repository: context.read<ChildRepository>(),
                )),
        BlocProvider(
            create: (context) => ParentBloc(
                  repository: context.read<ParentRepository>(),
                )..add(LoadParentById(id: widget.parentId, context: context))),
      ],
      child: Scaffold(
        appBar: _buildAppBar(),
        body: BlocBuilder<ParentBloc, ParentState>(
          builder: (context, state) {
            if (state is ParentLoading) {
              context.loaderOverlay.show();
              return const SizedBox.shrink();
            }
            if (state is ParentLoaded) {
              _model = state.parent;
              BlocProvider.of<ChildBloc>(context)
                  .add(LoadChildByParentId(id: _model!.id));
              if (context.loaderOverlay.overlayWidgetType !=
                  ReconnectingWidget) {
                context.loaderOverlay.hide();
              }
            }

            return _model == null ? const SizedBox.shrink() : _buildHallUi();
          },
        ),
      ),
    );
  }

  Widget _buildHallUi() {
    return BlocBuilder<MomentBloc, MomentState>(
      builder: (context, state) {
        if (state is MomentLoading) {
          context.loaderOverlay.show();
          const SizedBox.shrink();
        }

        if (state is MomentListLoaded) {
          _list.value = state.moments;
          if (_childId.value == null || _childId.value!.isEmpty) {
            context.read<MomentBloc>().add(
                FirstTileMomentsByParentId(parentId: _model!.id, limit: 32));
          } else {
            context.read<MomentBloc>().add(FirstTileMomentsByChildId(
                childId: _childId.value!, parentId: _model!.id, limit: 32));
          }

          // BlocProvider.of<MomentBloc>(context)
          //     .add(UpdateTileMoments(moments: state.moments));
        }

        if (state is MomentTileLoaded) {
          _grid.value = state.moments;
          if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
            context.loaderOverlay.hide();
          }
        }
        context.loaderOverlay.hide();

        // if (state is MomentLoaded) {
        //   _grid.value = state.moments;
        //   _list.value = state.moments;
        //   print(_list.value.length);
        //   print(_grid.value.length);
        //   if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
        //     context.loaderOverlay.hide();
        //   }
        // }

        //debugPrint('unique key $_uniqueKey');
        return ValueListenableBuilder(
            valueListenable: _uniqueKey,
            builder: (_, __, ___) {
              return ValueListenableBuilder(
                  valueListenable: _grid,
                  builder: (_, __, ___) {
                    return ValueListenableBuilder(
                        valueListenable: _list,
                        builder: ((context, __, ___) {
                          return HallUi(
                            key: _uniqueKey.value,
                            userModel: _model!,
                            childList: _childList,
                            childId: _childId,
                            list: _list,
                            grid: _grid,
                            type: widget.type,
                            selectedKid: _selectedKid,
                            setUniqueKey: _setUniqueKey,
                            context: context,
                          );
                        }));
                  });
            });
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    double width = MediaQuery.of(context).size.width;

    final bool useMobileLayout = width < 600;

    bool isOtherHall = widget.type == 'otherHall';
    return AppBar(
      toolbarHeight: useMobileLayout ? kToolbarHeight : kToolbarHeight + 4.h,
      elevation: 5,
      systemOverlayStyle: SharedCode.lightStatusBar(),
      actions: [
        CustomMousePointer(
          child: GestureDetector(
            onTap: () => AutoRouter.of(context).navigate(const SettingsRoute()),
            child: !isOtherHall
                ? Icon(Icons.settings_outlined, size: 8.w)
                : const SizedBox(width: 56),
          ),
        ),
        SizedBox(width: 3.w)
      ],
      title: BlocBuilder<ChildBloc, ChildState>(
        builder: (context, state) {
          if (state is ChildLoading) {
            context.loaderOverlay.show();
          }

          if (state is ChildLoaded) {
            Future.delayed(const Duration(milliseconds: 1), () {
              _childList.value = state.children;

              // check if state children consists of childId value, if not, then it must have been deleted
              // so we have to set selectedKid value (app bar selected kid) to 0
              int index = state.children
                  .indexWhere((element) => element.id == _childId.value);
              if (index == -1) {
                _selectedKid.value = 0;
                _childId.value = null;
              } else {
                _selectedKid.value = index + 1;
              }

              if (_childId.value == null && _model != null) {
                context
                    .read<MomentBloc>()
                    // .add(LoadMomentByParentId(parentId: _model!.id));
                    .add(FirstListMomentsByParentId(
                        parentId: _model!.id, limit: 8));
              } else {
                context
                    .read<MomentBloc>()
                    // .add(LoadMomentByChildId(
                    //     childId: _childId.value!, parentId: _model!.id));
                    .add(FirstListMomentsByChildId(
                        childId: _childId.value!,
                        parentId: _model!.id,
                        limit: 8));
              }

              if (context.loaderOverlay.overlayWidgetType !=
                  ReconnectingWidget) {
                context.loaderOverlay.hide();
              }
            });
          }

          return _model == null
              ? const SizedBox.shrink()
              : ValueListenableBuilder(
                  valueListenable: _childList,
                  builder: (_, __, ___) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children:
                          List.generate(_childList.value.length + 1, (index) {
                        ChildModel? model =
                            index == 0 ? null : _childList.value[index - 1];
                        return Row(
                          children: [
                            ValueListenableBuilder(
                                valueListenable: _selectedKid,
                                builder: (_, __, ___) {
                                  return CustomMousePointer(
                                    child: GestureDetector(
                                        onTap: () async {
                                          _uniqueKey.value = const Key('2');
                                          _selectedKid.value = index;
                                          if (index != 0) {
                                            _childId.value = model!.id;
                                            context.read<MomentBloc>().add(
                                                FirstListMomentsByChildId(
                                                    childId: _childId.value!,
                                                    parentId: _model!.id,
                                                    limit: 8));
                                          } else {
                                            _childId.value = '';
                                            if (_model != null) {
                                              context.read<MomentBloc>().add(
                                                  FirstListMomentsByParentId(
                                                      parentId: _model!.id,
                                                      limit: 8));
                                            }
                                          }
                                          _uniqueKey.notifyListeners();
                                        },
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(context).primaryColor,
                                          radius: index == _selectedKid.value
                                              ? 6.2.w
                                              : 4.5.w,
                                          child: BlocBuilder<ParentBloc,
                                              ParentState>(
                                            builder: (context, state) {
                                              String? parentImage =
                                                  _model?.avatarUrl?.display;
                                              String? childImage =
                                                  model?.avatarUrl.display;
                                              return CircleAvatar(
                                                backgroundColor:
                                                    ColorValues.loadingGrey,
                                                backgroundImage: index == 0
                                                    ? (parentImage == null ||
                                                            parentImage.isEmpty
                                                        ? null
                                                        : NetworkImage(
                                                            parentImage))
                                                    : (childImage == null ||
                                                            childImage.isEmpty
                                                        ? null
                                                        : NetworkImage(
                                                            childImage)),
                                                radius:
                                                    index == _selectedKid.value
                                                        ? 5.w
                                                        : 4.5.w,
                                              );
                                            },
                                          ),
                                        )),
                                  );
                                }),
                            index == _childList.value.length
                                ? const SizedBox.shrink()
                                : SizedBox(width: 4.w)
                          ],
                        );
                      }),
                    );
                  });
        },
      ),
    );
  }
}
