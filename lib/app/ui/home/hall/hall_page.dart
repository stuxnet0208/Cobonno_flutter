import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../../l10n/l10n.dart';
import '../../../common/color_values.dart';
import '../../../common/shared_code.dart';
import '../../../repositories/moment/moment_repository.dart';
import '../../../widgets/custom_mouse_pointer.dart';
import '../../../widgets/profile_ui.dart';
import '../../../widgets/reconnecting_widget.dart';

class HallPage extends StatefulWidget {
  const HallPage({Key? key}) : super(key: key);

  @override
  State<HallPage> createState() => _HallPageState();

  static void showPanel(BuildContext context, bool isShowed, String? momentId,
      {bool isDelete = false}) async {
    _HallPageState? state = context.findAncestorStateOfType<_HallPageState>();
    if (state != null) {
      state._showPanel(isShowed, momentId, isDelete: isDelete);
      //debugPrint('show panel $isShowed');
    }
  }
}

class _HallPageState extends State<HallPage> {
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
    SystemChrome.setSystemUIOverlayStyle(SharedCode.lightStatusBar());
    return Stack(
      children: [
        ProfileUi(
            parentId: FirebaseAuth.instance.currentUser!.uid, type: 'hall'),
        _buildPanel()
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
