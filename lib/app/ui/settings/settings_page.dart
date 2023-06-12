import 'package:age_calculator/age_calculator.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

import '../../blocs/blocs.dart';
import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../data/models/child_model.dart';
import '../../data/models/user_model.dart';
import '../../repositories/repositories.dart';
import '../../routes/router.gr.dart';
import '../../widgets/custom_mouse_pointer.dart';
import '../../widgets/reconnecting_widget.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _menuItems = [];
  bool _isShowingPopUp = false;
  late UserModel _parentModel;
  List<ChildModel> _childrenList = [];

  void _initItems() {
    _menuItems.clear();
    _menuItems.add(AppLocalizations.of(context).editProfile);
    _menuItems.add(AppLocalizations.of(context).language);
    _menuItems.add(AppLocalizations.of(context).logout);
    _menuItems.add(AppLocalizations.of(context).termsAndCondition);
    _menuItems.add(AppLocalizations.of(context).privacyPolicy);
    _menuItems.add(AppLocalizations.of(context).removeAccount);
  }

  @override
  Widget build(BuildContext context) {
    _initItems();
    return Scaffold(
      backgroundColor: ColorValues.blueGrey,
      appBar: AppBar(
        systemOverlayStyle: SharedCode.lightStatusBar(),
        title: Text(AppLocalizations.of(context).settings),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  _isShowingPopUp = !_isShowingPopUp;
                });
              },
              icon: const Icon(Icons.more_vert))
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _isShowingPopUp = false;
                });
              },
              child: Column(
                children: [
                  _buildParentContainer(),
                  SizedBox(height: 2.h),
                  _buildChildrenContainer(),
                  SizedBox(height: 6.h),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.w),
                    child: ElevatedButton(
                      onPressed: () {
                        AutoRouter.of(context).navigate(ChildFormRoute());
                      },
                      child: Text(AppLocalizations.of(context).addMyChild),
                    ),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
          _isShowingPopUp ? _buildPopMenu() : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPopMenu() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          children: [
            Material(
              elevation: 5,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.separated(
                    itemBuilder: (c, i) {
                      String item = _menuItems[i];
                      return InkWell(
                        onTap: () async {
                          if (item == AppLocalizations.of(context).logout) {
                            SharedCode.showAlertDialog(
                              context,
                              AppLocalizations.of(context).confirmation,
                              AppLocalizations.of(context).logoutConfirmation,
                              () async {
                                context.loaderOverlay
                                    .show(widget: const ReconnectingWidget());
                                Future.delayed(Duration.zero, () {
                                  SharedCode(context)
                                      .handleAuthenticationRouting(
                                          isLogout: true,
                                          logoutContext: context)
                                      .then((_) {
                                    context.loaderOverlay.hide();
                                  });
                                });
                              },
                              AppLocalizations.of(context).no,
                              AppLocalizations.of(context).yes,
                            );
                          } else if (item ==
                              AppLocalizations.of(context).termsAndCondition) {
                            AutoRouter.of(context)
                                .navigate(const TermsAndConditionRoute());
                          } else if (item ==
                              AppLocalizations.of(context).privacyPolicy) {
                            AutoRouter.of(context)
                                .navigate(const PrivacyPolicyRoute());
                          } else if (item ==
                              AppLocalizations.of(context).removeAccount) {
                            SharedCode.showAlertDialog(
                              context,
                              AppLocalizations.of(context).confirmation,
                              AppLocalizations.of(context)
                                  .removeAccountConfirmation,
                              () async {
                                try {
                                  context.loaderOverlay.show();
                                  await AuthRepository().removeAccount(context);
                                  Future.delayed(Duration.zero, () {
                                    FirebaseAuth.instance.signOut().then((_) {
                                      context.loaderOverlay.hide();
                                      SharedCode.showSnackBar(
                                          context,
                                          'success',
                                          AppLocalizations.of(context)
                                              .removeAccountSuccess);
                                    });
                                  });
                                } catch (e) {
                                  context.loaderOverlay.hide();
                                  SharedCode.showErrorDialog(
                                      context,
                                      AppLocalizations.of(context).error,
                                      e.toString());
                                }
                              },
                              AppLocalizations.of(context).no,
                              AppLocalizations.of(context).yes,
                            );
                          } else if (item ==
                              AppLocalizations.of(context).language) {
                            AutoRouter.of(context)
                                .navigate(const LanguageRoute());
                          } else if (item ==
                              AppLocalizations.of(context).editProfile) {
                            AutoRouter.of(context).navigate(
                                ParentFormRoute(parentModel: _parentModel));
                          }

                          setState(() {
                            _isShowingPopUp = false;
                          });
                        },
                        child: Text(
                          item,
                          style: TextStyle(
                              color: i == _menuItems.length - 1
                                  ? Colors.red
                                  : Colors.grey[800]),
                        ),
                      );
                    },
                    separatorBuilder: (c, i) {
                      return i == _menuItems.length - 1
                          ? const SizedBox.shrink()
                          : const Divider();
                    },
                    itemCount: _menuItems.length,
                    shrinkWrap: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainerCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
      child: child,
    );
  }

  Widget _buildParentContainer() {
    return BlocProvider(
      create: (context) {
        return ParentBloc(
          repository: context.read<ParentRepository>(),
        )..add(LoadParentById(
            id: FirebaseAuth.instance.currentUser!.uid, context: context));
      },
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10)),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 10.w),
        child: BlocBuilder<ParentBloc, ParentState>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, state) {
            if (state is ParentLoading) {
              if (!context.loaderOverlay.visible) {
                context.loaderOverlay.show();
              }
              return const SizedBox.shrink();
            }

            if (state is ParentLoaded) {
              _parentModel = state.parent;
              if (context.loaderOverlay.visible) {
                if (context.loaderOverlay.overlayWidgetType !=
                    ReconnectingWidget) {
                  context.loaderOverlay.hide();
                }
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileInfo(_parentModel.avatarUrl?.display ?? '',
                    _parentModel.username),
                _parentModel.description == null ||
                        _parentModel.description!.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(height: 4.h),
                _parentModel.description == null ||
                        _parentModel.description!.isEmpty
                    ? const SizedBox.shrink()
                    : Text(_parentModel.description!,
                        style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[700],
                            height: 1),
                        textAlign: TextAlign.start)
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildChildrenContainer() {
    return BlocProvider(
      create: (context) {
        return ChildBloc(
          repository: context.read<ChildRepository>(),
        )..add(LoadChildByParentId(id: FirebaseAuth.instance.currentUser!.uid));
      },
      child: BlocBuilder<ChildBloc, ChildState>(
        builder: (context, state) {
          if (state is ChildLoading) {
            context.loaderOverlay.show();
            return const SizedBox.shrink();
          }
          if (state is ChildLoaded) {
            _childrenList = state.children;
            if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
              context.loaderOverlay.hide();
            }
          }

          return _childrenList.isEmpty
              ? Text(AppLocalizations.of(context).noChildren)
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    ChildModel model = _childrenList[i];
                    DateDuration ageDuration =
                        AgeCalculator.age(model.birthday);
                    return _buildContainerCard(
                        child: _buildProfileInfo(
                            model.avatarUrl.display, model.fullName,
                            nickname: model.nickName,
                            age: ageDuration.years,
                            childModel: model));
                  },
                  itemCount: _childrenList.length);
        },
      ),
    );
  }

  Widget _buildProfileInfo(String imageUrl, String name,
      {String? nickname, int? age, ChildModel? childModel}) {
    return Row(
      crossAxisAlignment:
          age == null ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: ColorValues.loadingGrey,
          backgroundImage: imageUrl.isEmpty ? null : NetworkImage(imageUrl),
          radius: 7.w,
        ),
        SizedBox(width: 4.w),
        Expanded(
            child: Row(
          children: [
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                        color: Colors.grey[800])),
                nickname == null
                    ? const SizedBox.shrink()
                    : Text(nickname,
                        style: TextStyle(
                            height: 1.3,
                            fontSize: 12.sp,
                            color: Colors.grey[800])),
                age == null
                    ? const SizedBox.shrink()
                    : Text(AppLocalizations.of(context).age(age),
                        style: TextStyle(
                            fontSize: 12.sp, color: Colors.grey[800])),
              ],
            )),
            CustomMousePointer(
              child: GestureDetector(
                  onTap: () async {
                    if (childModel == null) {
                      AutoRouter.of(context)
                          .navigate(ParentFormRoute(parentModel: _parentModel));
                    } else {
                      AutoRouter.of(context)
                          .navigate(ChildFormRoute(childModel: childModel));
                    }
                  },
                  child: Icon(Icons.edit_outlined, size: 7.w)),
            ),
            if (childModel != null) SizedBox(width: 1.w),
            if (childModel != null)
              CustomMousePointer(
                child: GestureDetector(
                    onTap: () async {
                      SharedCode.showAlertDialog(
                        context,
                        AppLocalizations.of(context).confirmation,
                        AppLocalizations.of(context).removeChildConfirmation,
                        () async {
                          try {
                            context.loaderOverlay.show();
                            await ChildRepository()
                                .removeChild(childModel.id!, context);
                            context.loaderOverlay.hide();
                            Future.delayed(Duration.zero, () {
                              SharedCode.showSnackBar(
                                  context,
                                  'success',
                                  AppLocalizations.of(context)
                                      .removeChildSuccess);
                            });
                          } catch (e) {
                            //debugPrint('error in settings ${e.toString()}');
                            SharedCode.showErrorDialog(
                                context,
                                AppLocalizations.of(context).error,
                                e.toString());
                          }
                        },
                        AppLocalizations.of(context).no,
                        AppLocalizations.of(context).yes,
                      );
                    },
                    child: Icon(
                      Icons.delete_outlined,
                      size: 7.w,
                    )),
              ),
          ],
        )),
      ],
    );
  }
}
