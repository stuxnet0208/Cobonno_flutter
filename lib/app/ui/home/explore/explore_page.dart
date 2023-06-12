import 'package:cobonno/app/common/shared_code.dart';
import 'package:cobonno/app/widgets/custom_mouse_pointer.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../blocs/blocs.dart';
import '../../../common/color_values.dart';
import '../../../data/models/child_model.dart';
import '../../../data/models/moment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../repositories/repositories.dart';
import '../../../widgets/hall_ui.dart';
import '../../../widgets/reconnecting_widget.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key, this.initialSearch}) : super(key: key);
  final String? initialSearch;

  @override
  State<ExplorePage> createState() => _ExplorePageState();

  static void showPanel(BuildContext context, bool isShowed, String? momentId,
      {bool isDelete = false}) async {
    _ExplorePageState? state =
        context.findAncestorStateOfType<_ExplorePageState>();
    if (state != null) {
      state._showPanel(isShowed, momentId, isDelete: isDelete);
      //debugPrint('show panel $isShowed');
    }
  }
}

class _ExplorePageState extends State<ExplorePage> {
  final ValueNotifier<List<MomentModel>> _list = ValueNotifier([]);
  final ValueNotifier<List<MomentModel>> _grid = ValueNotifier([]);
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
        SafeArea(
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => MomentBloc(
                        momentRepository: context.read<MomentRepository>(),
                      )..add(const FetchFirstListMoments(limit: 8))),
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
                  _model = state.parent;
                  if (context.loaderOverlay.overlayWidgetType !=
                      ReconnectingWidget) {
                    context.loaderOverlay.hide();
                  }
                }

                return BlocBuilder<MomentBloc, MomentState>(
                  builder: (context, state) {
                    if (state is MomentLoading) {
                      context.loaderOverlay.show();
                    }
                    if (state is MomentListLoaded) {
                      _list.value = state.moments;
                      if (_grid.value.isEmpty) {
                        BlocProvider.of<MomentBloc>(context)
                            .add(const FetchFirstTileMoments(limit: 32));
                      }
                      // if (context.loaderOverlay.overlayWidgetType !=
                      //     ReconnectingWidget) {
                      //   context.loaderOverlay.hide();
                      // }
                    }
                    if (state is MomentTileLoaded) {
                      _grid.value = state.moments;
                      if (context.loaderOverlay.overlayWidgetType !=
                          ReconnectingWidget) {
                        context.loaderOverlay.hide();
                      }
                    }
                    return ValueListenableBuilder(
                        valueListenable: _grid,
                        builder: (_, __, ___) {
                          return ValueListenableBuilder(
                            valueListenable: _list,
                            builder: ((context, __, ___) {
                              return Stack(
                                children: [
                                  HallUi(
                                    userModel: _model,
                                    childList:
                                        ValueNotifier<List<ChildModel>>([]),
                                    type: 'explore',
                                    childId: ValueNotifier<String?>(null),
                                    grid: _grid,
                                    list: _list,
                                    initialSearch: widget.initialSearch,
                                    context: context,
                                    searchFieldOnChanged: (String? s) {
                                      //debugPrint('on field change $s');
                                      if (s == null) {
                                        context
                                            .read<MomentBloc>()
                                            .add(LoadAllMoments());
                                      } else {
                                        s = s.replaceAll('#', '');
                                        if (s.isEmpty) {
                                          context
                                              .read<MomentBloc>()
                                              .add(LoadAllMoments());
                                        } else {
                                          context
                                              .read<MomentBloc>()
                                              .add(LoadMomentsByTag(tag: s));
                                        }
                                      }
                                      return null;
                                    },
                                    selectedKid: ValueNotifier<int>(0),
                                  ),
                                  if (state is MomentFetchLoading)
                                    const Align(
                                        alignment: Alignment.bottomCenter,
                                        child: CircularProgressIndicator()),
                                ],
                              );
                            }),
                          );
                        });
                  },
                );
              },
            ),
          ),
        ),
        _buildPanel(),
      ],
    );
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
                                            //             reports[i]), () async {
                                            //   context.loaderOverlay.show();
                                            //   try {
                                            //     debugPrint('is delete admin, $_isDelete, $_momentId');
                                            //     if (_momentId != null) {
                                            //       await MomentRepository()
                                            //           .deleteMomentAdmin(
                                            //               context,
                                            //               _momentId!,
                                            //               reports[i]);
                                            //       _isDelete = false;
                                            //       Future.delayed(Duration.zero,
                                            //           () {
                                            //         SharedCode.showSnackBar(
                                            //             context,
                                            //             'success',
                                            //             AppLocalizations.of(
                                            //                     context)
                                            //                 .deleteMomentSuccess);
                                            //       });
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
