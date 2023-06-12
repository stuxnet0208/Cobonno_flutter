import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../l10n/l10n.dart';
import '../../../blocs/blocs.dart';
import '../../../common/color_values.dart';
import '../../../common/shared_code.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/moment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../repositories/repositories.dart';
import '../../../widgets/custom_mouse_pointer.dart';
import '../../../widgets/hall_ui.dart';
import '../../../widgets/reconnecting_widget.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({Key? key}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();

  static void showPanel(BuildContext context, bool isShowed, String? momentId,
      {bool isDelete = false}) async {
    _FavoritePageState? state =
        context.findAncestorStateOfType<_FavoritePageState>();
    if (state != null) {
      state._showPanel(isShowed, momentId, isDelete: isDelete);
      //debugPrint('show panel $isShowed');
    }
  }
}

class _FavoritePageState extends State<FavoritePage> {
  final ValueNotifier<List<MomentModel>> _list = ValueNotifier([]);
  final ValueNotifier<List<MomentModel>> _grid = ValueNotifier([]);
  List<MomentModel> _myFavorite = [];
  List<MomentModel> _tempList = [];
  late UserModel _model;
  final ValueNotifier<bool> _isPanelShowed = ValueNotifier(false);
  String? _momentId;
  bool _isDelete = false;

  void _showPanel(bool isShowed, String? momentId, {bool isDelete = false}) {
    _isPanelShowed.value = isShowed;
    _momentId = momentId;
    _isDelete = isDelete;
    //debugPrint('is delete show panel $_isDelete $isDelete');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MultiBlocProvider(
          providers: [
            BlocProvider(
                create: (context) => MomentBloc(
                      momentRepository: context.read<MomentRepository>(),
                    )),
            BlocProvider(
                create: (context) => ParentBloc(
                      repository: context.read<ParentRepository>(),
                    )..add(LoadParentById(
                        id: FirebaseAuth.instance.currentUser!.uid,
                        context: context))),
          ],
          child: BlocBuilder<ParentBloc, ParentState>(
            builder: (context, state) {
              if (state is ParentLoading) {
                context.loaderOverlay.show();
                return const SizedBox.shrink();
              }
              if (state is ParentLoaded) {
                if (context.loaderOverlay.overlayWidgetType !=
                    ReconnectingWidget) {
                  context.loaderOverlay.hide();
                }
                _model = state.parent;
                if (_model.favorites.isNotEmpty) {
                  // BlocProvider.of<MomentBloc>(context)
                  //     .add(LoadFavoriteMoments(favorites: _model.favorites));
                  BlocProvider.of<MomentBloc>(context).add(
                      FirstFavoriteListMoments(
                          favorites: _model.favorites, limit: 8));
                } else {
                  _list.value.clear();
                  _grid.value.clear();
                  return _buildHallUi();
                }
              }

              return BlocBuilder<MomentBloc, MomentState>(
                builder: (context, state) {
                  if (state is MomentLoading) {
                    context.loaderOverlay.show();
                    return const SizedBox.shrink();
                  }

                  if (state is MomentListLoaded) {
                    _list.value = state.moments;
                    print("list favorite " + _list.value.length.toString());
                    // if (_grid.value.isEmpty) {
                    BlocProvider.of<MomentBloc>(context).add(
                        FirstFavoriteTileMoments(
                            favorites: _model.favorites, limit: 32));
                    // }
                  }

                  if (state is MomentTileLoaded) {
                    _grid.value = state.moments;
                    print(
                        "grid value favorite" + _grid.value.length.toString());
                    if (context.loaderOverlay.overlayWidgetType !=
                        ReconnectingWidget) {
                      context.loaderOverlay.hide();
                    }
                    return _buildHallUi();
                  }

                  // if (state is MomentLoaded) {
                  //   _tempList = state.moments;
                  //   BlocProvider.of<MomentBloc>(context).add(
                  //       LoadFavoriteMomentsByParentId(
                  //           favorites: _model.favorites,
                  //           parentId: FirebaseAuth.instance.currentUser!.uid));
                  //   if (context.loaderOverlay.overlayWidgetType !=
                  //       ReconnectingWidget) {
                  //     context.loaderOverlay.hide();
                  //   }
                  // }

                  // if (state is MyMomentLoaded) {
                  //   _myFavorite = state.moments;
                  //   _list.value.clear();
                  //   _grid.value.clear();
                  //   _list.value.addAll(_tempList);
                  //   _list.value.addAll(_myFavorite);
                  //   _grid.value.addAll(_tempList);
                  //   _grid.value.addAll(_myFavorite);
                  //   if (context.loaderOverlay.overlayWidgetType !=
                  //       ReconnectingWidget) {
                  //     context.loaderOverlay.hide();
                  //   }
                  // }

                  return _buildHallUi();
                },
              );
            },
          ),
        ),
        _buildPanel()
      ],
    );
  }

  Widget _buildHallUi() {
    return ValueListenableBuilder(
        valueListenable: _grid,
        builder: (_, __, ___) {
          return ValueListenableBuilder(
              valueListenable: _list,
              builder: ((context, __, ___) {
                return HallUi(
                  userModel: _model,
                  childList: ValueNotifier<List<ChildModel>>([]),
                  type: 'favorite',
                  childId: ValueNotifier<String?>(null),
                  list: _list,
                  grid: _grid,
                  context: context,
                  selectedKid: ValueNotifier<int>(0),
                );
              }));
        });
  }

  Widget _buildPanel() {
    return ValueListenableBuilder(
        valueListenable: _isPanelShowed,
        builder: (_, __, ___) {
          List<String> reports =
              AppLocalizations.of(context).reportList.split(':');
          return _isPanelShowed.value
              ? SlidingUpPanel(
                  backdropEnabled: true,
                  backdropOpacity: 0,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0)),
                  parallaxEnabled: true,
                  parallaxOffset: 0.5,
                  isDraggable: false,
                  defaultPanelState: PanelState.OPEN,
                  onPanelClosed: () {
                    if (_isPanelShowed.value) _isPanelShowed.value = false;
                  },
                  panel: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 2.h),
                              Center(
                                  child: Container(
                                decoration: BoxDecoration(
                                    color: ColorValues.grey,
                                    borderRadius: BorderRadius.circular(10)),
                                width: 15.w,
                                height: 3,
                              )),
                              SizedBox(height: 2.h),
                              Center(
                                  child: Text(
                                      _isDelete
                                          ? AppLocalizations.of(context)
                                              .deleteMoment
                                          : AppLocalizations.of(context)
                                              .reportText,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp))),
                              ListView.separated(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (_, i) {
                                    return InkWell(
                                        onTap: () {
                                          if (_isDelete) {
                                            // SharedCode.showAlertDialog(
                                            //     context,
                                            //     AppLocalizations.of(context)
                                            //         .confirmation,
                                            //     AppLocalizations.of(context)
                                            //         .deleteAdminConfirmation(
                                            //         reports[i]), () async {
                                            //   context.loaderOverlay.show();
                                            //   try {
                                            //     debugPrint('is delete admin, $_isDelete, $_momentId');
                                            //     if (_momentId != null) {
                                            //       await MomentRepository()
                                            //           .deleteMomentAdmin(
                                            //           context,
                                            //           _momentId!,
                                            //           reports[i]);
                                            //       _isDelete = false;
                                            //       Future.delayed(Duration.zero,
                                            //               () {
                                            //             SharedCode.showSnackBar(
                                            //                 context,
                                            //                 'success',
                                            //                 AppLocalizations.of(
                                            //                     context)
                                            //                     .deleteMomentSuccess);
                                            //           });
                                            //     }
                                            //   } catch (e) {
                                            //     SharedCode.showErrorDialog(
                                            //         context,
                                            //         AppLocalizations.of(context)
                                            //             .error,
                                            //         e.toString());
                                            //   }
                                            //   _showPanel(false, null);
                                            //   context.loaderOverlay.hide();
                                            // });
                                          } else {
                                            SharedCode.showAlertDialog(
                                              context,
                                              AppLocalizations.of(context)
                                                  .confirmation,
                                              AppLocalizations.of(context)
                                                  .reportConfirmation(
                                                      reports[i]),
                                              () async {
                                                context.loaderOverlay.show(
                                                    widget:
                                                        const ReconnectingWidget());
                                                try {
                                                  if (_momentId != null) {
                                                    await MomentRepository()
                                                        .reportMoment(
                                                            context,
                                                            _momentId!,
                                                            reports[i]);
                                                    Future.delayed(
                                                        Duration.zero, () {
                                                      SharedCode.showSnackBar(
                                                          context,
                                                          'success',
                                                          AppLocalizations.of(
                                                                  context)
                                                              .momentReported);
                                                    });
                                                  }
                                                } catch (e) {
                                                  SharedCode.showErrorDialog(
                                                      context,
                                                      AppLocalizations.of(
                                                              context)
                                                          .error,
                                                      e.toString());
                                                }
                                                _showPanel(false, null);
                                                context.loaderOverlay.hide();
                                              },
                                              AppLocalizations.of(context).no,
                                              AppLocalizations.of(context).yes,
                                            );
                                          }
                                        },
                                        child: Text(reports[i]));
                                  },
                                  separatorBuilder: (_, __) {
                                    return const Divider();
                                  },
                                  itemCount: reports.length),
                            ],
                          ),
                          Align(
                              alignment: Alignment.topRight,
                              child: CustomMousePointer(
                                  child: GestureDetector(
                                      onTap: () {
                                        _showPanel(false, null);
                                      },
                                      child: const Icon(Icons.close))))
                        ],
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink();
        });
  }
}
