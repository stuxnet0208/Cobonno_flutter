import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/blocs/blocs.dart';
import 'package:cobonno/app/common/shared_code.dart';
import 'package:cobonno/app/repositories/moment/moment_repository.dart';
import 'package:cobonno/app/repositories/parent/parent_repository.dart';
import 'package:cobonno/app/widgets/reconnecting_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../common/color_values.dart';
import '../common/styles.dart';
import '../data/models/child_model.dart';
import '../data/models/moment_model.dart';
import '../data/models/user_model.dart';
import '../routes/router.gr.dart';
import 'custom_carousel.dart';
import 'custom_search_widget.dart';
import 'detail_ui.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:delayed_display/delayed_display.dart';

class HallUi extends StatefulWidget {
  final String type;
  final ValueNotifier<List<MomentModel>> list;
  final ValueNotifier<List<MomentModel>> grid;
  final ValueNotifier<List<ChildModel>> childList;
  final ValueNotifier<int> selectedKid;
  final ValueNotifier<String?> childId;
  final UserModel userModel;
  final String? Function(String?)? searchFieldOnChanged;
  final Function(String)? setUniqueKey;
  final String? initialSearch;
  final BuildContext? context;

  const HallUi({
    Key? key,
    this.type = 'hall',
    required this.list,
    required this.grid,
    required this.userModel,
    required this.childList,
    required this.selectedKid,
    required this.childId,
    this.searchFieldOnChanged,
    this.setUniqueKey,
    this.initialSearch,
    this.context,
  }) : super(key: key);

  @override
  State<HallUi> createState() => _HallUiState();
}

class _HallUiState extends State<HallUi> {
  final ValueNotifier<bool> _showFab = ValueNotifier(true);
  final ValueNotifier<int> _selectedTab = ValueNotifier(0);
  final ValueNotifier<List<MomentModel>> listReact = ValueNotifier([]);
  final ValueNotifier<List<MomentModel>> gridReact = ValueNotifier([]);
  final _duration = const Duration(milliseconds: 300);
  final TextEditingController _searchController = TextEditingController();

  final ScrollController _controllerHallParent = ScrollController();
  final ScrollController _controllerHallChild = ScrollController();
  final ScrollController _controllerExplore = ScrollController();
  final ScrollController _controllerProfileParent = ScrollController();
  final ScrollController _controllerProfileChild = ScrollController();
  final ScrollController _controllerPatronized = ScrollController();
  final ScrollController _controllerFavorite = ScrollController();

  final DateFormat _dateFormat = DateFormat('yyyy');
  bool newYear = true;
  int gridList = 0;
  int indexPlus = 0;
  bool isStart = true;
  List<int> year = [];

  UserModel? myUser;

  bool isPatronized = false;
  bool isLoading = false;

  @override
  void initState() {
    print(widget.type);
    if (widget.initialSearch != null && widget.type == 'explore') {
      debugPrint('init state hall ui');
      _searchController.text = widget.initialSearch ?? '';
      widget.searchFieldOnChanged!(widget.initialSearch);
    }
    if (widget.type == 'hall') {
      _controllerHallParent.addListener(_scrollControllerHallParent);
      _controllerHallChild.addListener(_scrollControllerHallChild);
    }
    if (widget.type == 'explore') {
      _controllerExplore.addListener(_scrollControllerExplore);
    }
    if (widget.type == 'otherHall') {
      _controllerProfileParent.addListener(_scrollControllerProfileParent);
      _controllerProfileChild.addListener(_scrollControllerProfileChild);
    }
    if (widget.type == 'patronize') {
      _controllerPatronized.addListener(_scrollControllerPatronize);
    }
    if (widget.type == 'favorite') {
      _controllerFavorite.addListener(_scrollControllerFavorite);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.setUniqueKey != null && widget.key != const Key('1')) {
      widget.setUniqueKey!('1');
      //debugPrint('set unique key to 1');
      //debugPrint('current key ${widget.key}');
    }
    widget.grid.value.removeWhere((element) => element.photos.isEmpty);
    return Container(
      color: widget.grid.value.isNotEmpty ? Colors.white : ColorValues.blueGrey,
      child: Stack(
        children: [
          NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              final ScrollDirection direction = notification.direction;
              if (direction == ScrollDirection.reverse) {
                _showFab.value = false;
              } else if (direction == ScrollDirection.forward) {
                _showFab.value = true;
              }
              return true;
            },
            child: ValueListenableBuilder(
                valueListenable: widget.selectedKid,
                builder: (_, __, ___) {
                  return SingleChildScrollView(
                    controller:
                        widget.type == "hall" && (widget.selectedKid.value != 0)
                            ? _controllerHallChild
                            : widget.type == "hall"
                                ? _controllerHallParent
                                : widget.type == "explore"
                                    ? _controllerExplore
                                    : widget.type == "otherHall" &&
                                            (widget.selectedKid.value != 0)
                                        ? _controllerProfileChild
                                        : widget.type == "otherHall"
                                            ? _controllerProfileParent
                                            : widget.type == "patronize"
                                                ? _controllerPatronized
                                                : _controllerFavorite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.type == 'otherHall')
                          _buildUserInformation(context),
                        if (widget.type == 'otherHall')
                          ValueListenableBuilder(
                              valueListenable: _selectedTab,
                              builder: (_, __, ___) {
                                return SizedBox(
                                    height:
                                        _selectedTab.value == 0 ? 1.h : 2.h);
                              }),
                        _buildSelectedView()
                      ],
                    ),
                  );
                }),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                _buildTopFloatingWidgets(),
                ValueListenableBuilder(
                    valueListenable: widget.list,
                    builder: (_, __, ___) {
                      //debugPrint('widget type ${widget.type}, ${widget.userModel.id != FirebaseAuth.instance.currentUser?.uid}');
                      return widget.list.value.isNotEmpty
                          ? const SizedBox.shrink()
                          : Center(
                              child: Text(AppLocalizations.of(context).noData));
                    }),
                (widget.type == 'hall' ||
                        (widget.type == 'otherHall' &&
                            widget.userModel.id ==
                                FirebaseAuth.instance.currentUser!.uid))
                    ? _buildCameraButton()
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInformation(BuildContext context) {
    String description = widget.userModel.description ?? '';
    return BlocProvider(
      create: (context) => ParentBloc(
        repository: context.read<ParentRepository>(),
      )..add(LoadParentById(
          id: FirebaseAuth.instance.currentUser!.uid, context: context)),
      child: BlocBuilder<ParentBloc, ParentState>(
        builder: (context, state) {
          if (state is ParentLoading) {
            context.loaderOverlay.show();
            return const SizedBox.shrink();
          }
          if (state is ParentLoaded) {
            myUser = state.parent;
            if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
              context.loaderOverlay.hide();
            }
            isPatronized = myUser?.patronizeds
                    .indexWhere((e) => e == widget.userModel.id) !=
                -1;
            print("length patronized: ${myUser!.patronizeds.length}");
          }
          return Container(
            color: Colors.white,
            width: double.infinity,
            padding: EdgeInsets.only(
                left: Styles.defaultPadding,
                right: Styles.defaultPadding,
                bottom: Styles.defaultPadding,
                top: 12.5.h),
            child: Row(
              crossAxisAlignment: description.trim().isEmpty
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CircleAvatar(
                    radius: 10.w,
                    backgroundColor: ColorValues.loadingGrey,
                    backgroundImage: widget.userModel.avatarUrl == null
                        ? null
                        : NetworkImage(widget.userModel.avatarUrl!.display),
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (FirebaseAuth.instance.currentUser?.uid !=
                          widget.userModel.id)
                        Container(
                          decoration: BoxDecoration(
                              color: isPatronized
                                  ? ColorValues.greyAlt
                                  : ColorValues.blue,
                              borderRadius: BorderRadius.circular(5.5.w)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5.5.w),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  if (myUser?.patronizeds.indexWhere(
                                          (e) => e == widget.userModel.id) !=
                                      -1) {
                                    ParentRepository().removeUserToPatronize(
                                        myUser!.id, widget.userModel.id);
                                    context.read<ParentBloc>().add(
                                        LoadParentById(
                                            id: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            context: context));
                                    setState(() {
                                      isPatronized = false;
                                    });
                                  } else {
                                    if (myUser!.patronizeds.length == 10) {
                                      SharedCode.showAlertDialog(
                                          context,
                                          AppLocalizations.of(context)
                                              .patronLimit,
                                          AppLocalizations.of(context)
                                              .patronLimitAlert,
                                          () {},
                                          AppLocalizations.of(context).no,
                                          AppLocalizations.of(context).ok,
                                          false);
                                      return;
                                    }
                                    ParentRepository().addUserToPatronize(
                                        myUser!.id, widget.userModel.id);
                                    context.read<ParentBloc>().add(
                                        LoadParentById(
                                            id: FirebaseAuth
                                                .instance.currentUser!.uid,
                                            context: context));
                                    setState(() {
                                      isPatronized = true;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 45.w,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 3, horizontal: 0),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: isPatronized
                                              ? Colors.white
                                              : ColorValues.yellowAlt,
                                          size: 30,
                                        ),
                                        SizedBox(width: 2.w),
                                        isLoading
                                            ? const CircularProgressIndicator()
                                            : Text(
                                                isPatronized
                                                    ? AppLocalizations.of(
                                                            context)
                                                        .patronizedBtn
                                                    : AppLocalizations.of(
                                                            context)
                                                        .patronize,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13.sp),
                                              )
                                      ]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      Text(widget.userModel.username,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14.sp)),
                      if (widget.userModel.description != null)
                        Text(
                          widget.userModel.description ?? '',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCameraButton() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ValueListenableBuilder(
            valueListenable: _showFab,
            builder: (_, __, ___) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: AnimatedSlide(
                  duration: _duration,
                  offset: _showFab.value ? Offset.zero : const Offset(0, 2),
                  child: AnimatedOpacity(
                    duration: _duration,
                    opacity: _showFab.value ? 1 : 0,
                    child: FloatingActionButton(
                        onPressed: () {
                          if (widget.childList.value.length == 1) {
                            AutoRouter.of(context).navigate(GalleryListRoute(
                                childId: [widget.childList.value.first.id!],
                                isParentSelected: true,
                                momentModel: null));
                          } else {
                            AutoRouter.of(context).navigate(SelectChildRoute(
                                childId: widget.childId.value,
                                user: widget.userModel));
                          }
                        },
                        backgroundColor: Theme.of(context).canvasColor,
                        elevation: 5,
                        child: Icon(Icons.camera_alt_outlined,
                            color: Colors.black,
                            size: MediaQuery.of(context).size.width < 600
                                ? 10.w
                                : 7.w)),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildTopFloatingWidgets() {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: ValueListenableBuilder(
            valueListenable: _showFab,
            builder: (_, __, ___) {
              return Stack(
                children: [
                  Container(
                      margin: widget.type == 'explore'
                          ? EdgeInsets.only(top: 9.h)
                          : EdgeInsets.zero,
                      child: _buildTabContainer()),
                  if (widget.type == 'explore') _buildFloatingSearch(),
                ],
              );
            }),
      ),
    );
  }

  Padding _buildFloatingSearch() {
    return Padding(
      padding: EdgeInsets.only(
          top: 2.h, left: Styles.defaultPadding, right: Styles.defaultPadding),
      child: CustomSearchWidget(
          label: AppLocalizations.of(context).searchField,
          controller: _searchController,
          onChanged: widget.searchFieldOnChanged),
    );
  }

  Widget _buildTabContainer() {
    return ValueListenableBuilder(
        valueListenable: _selectedTab,
        builder: (_, __, ___) {
          return AnimatedSlide(
              duration: _duration,
              offset: _showFab.value ? Offset.zero : const Offset(0, -2),
              child: AnimatedOpacity(
                  duration: _duration,
                  opacity: _showFab.value ? 1 : 0,
                  child: _buildTabFab()));
        });
  }

  Widget _buildTabFab() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 20),
          width: 30.w,
          height: 6.h,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 2,
                spreadRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: InkWell(
                onTap: () {
                  _selectedTab.value = 0;
                },
                child: Icon(Icons.view_agenda_outlined,
                    size: 7.w,
                    color:
                        _selectedTab.value == 0 ? Colors.black : Colors.grey),
              )),
              Expanded(
                  child: InkWell(
                onTap: () {
                  _selectedTab.value = 1;
                },
                child: Icon(Icons.grid_view_outlined,
                    size: 7.w,
                    color:
                        _selectedTab.value == 1 ? Colors.black : Colors.grey),
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return ValueListenableBuilder(
        valueListenable: widget.grid,
        builder: (_, __, ___) {
          double height = widget.type == 'explore'
              ? 20.3.h
              : (widget.type == 'otherHall' ? 0 : 11.5.h);
          print('the grid length: ${widget.grid.value.length}');
          return Stack(
            children: [
              if (widget.grid.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: height,
                  color: Colors.white,
                ),
              Column(
                children: [
                  if (widget.type == 'hall')
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(top: height),
                      itemCount: widget.grid.value.length,
                      itemBuilder: (context, index) {
                        if (widget.grid.value.length == 1) {
                          return ValueListenableBuilder(
                              valueListenable: widget.grid,
                              builder: (_, __, ___) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _dateFormat.format(
                                          widget.grid.value[index].date!),
                                      style: TextStyle(
                                          fontSize: 30.sp,
                                          color: ColorValues.darkGreyAlt,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4),
                                    ),
                                    gridViewHall(
                                        indexPlus: indexPlus,
                                        isStart: isStart,
                                        ifLast: true),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                  ],
                                );
                              });
                        } else if (year.isEmpty) {
                          year.add(1);
                        } else if (index == 0) {
                          year.clear();
                          isStart = true;
                          gridList = 0;
                          indexPlus = 0;
                          year.add(1);
                        } else if (_dateFormat
                                .format(widget.grid.value[index].date!) ==
                            _dateFormat
                                .format(widget.grid.value[index - 1].date!)) {
                          year.add(1);
                          if (widget.grid.value.length == (index + 1)) {
                            if (gridList != 0) {
                              isStart = false;
                            }

                            if (isStart == false) {
                              indexPlus += gridList;
                            }

                            gridList = year.length;
                            year.clear();
                            year.add(1);

                            return ValueListenableBuilder(
                                valueListenable: widget.grid,
                                builder: (_, __, ___) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        _dateFormat.format(
                                            widget.grid.value[index - 1].date!),
                                        style: TextStyle(
                                            fontSize: 30.sp,
                                            color: ColorValues.darkGreyAlt,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4),
                                      ),
                                      gridViewHall(
                                          indexPlus: indexPlus,
                                          isStart: isStart),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                    ],
                                  );
                                });
                          }
                        } else if (_dateFormat
                                .format(widget.grid.value[index].date!) !=
                            _dateFormat
                                .format(widget.grid.value[index - 1].date!)) {
                          if (gridList != 0) {
                            isStart = false;
                          }

                          if (isStart == false) {
                            indexPlus += gridList;
                          }

                          gridList = year.length; // 2

                          year.clear();
                          year.add(1);
                          return ValueListenableBuilder(
                              valueListenable: widget.grid,
                              builder: (_, __, ___) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _dateFormat.format(
                                          widget.grid.value[index - 1].date!),
                                      style: TextStyle(
                                          fontSize: 30.sp,
                                          color: ColorValues.darkGreyAlt,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.4),
                                    ),
                                    gridViewHall(
                                        indexPlus: indexPlus, isStart: isStart),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    if (widget.grid.value.length ==
                                        (index + 1)) ...[
                                      Text(
                                        _dateFormat.format(
                                            widget.grid.value[index].date!),
                                        style: TextStyle(
                                            fontSize: 30.sp,
                                            color: ColorValues.darkGreyAlt,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.4),
                                      ),
                                      gridViewHall(
                                          ifLast: true,
                                          indexPlus: index,
                                          isStart: false),
                                    ]
                                  ],
                                );
                              });
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  if (widget.type != 'hall')
                    GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(top: height),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 0,
                                mainAxisSpacing: 0),
                        itemCount: widget.grid.value.length,
                        itemBuilder: (BuildContext _, index) {
                          return widget.grid.value[index].photos.isNotEmpty
                              ? BlocProvider(
                                  create: (context) => MomentBloc(
                                      momentRepository:
                                          context.read<MomentRepository>()),
                                  child: InkWell(
                                    onTap: () {
                                      AutoRouter.of(context).navigate(
                                          DetailRoute(
                                              moments: widget.grid.value,
                                              index: index));
                                    },
                                    child: ValueListenableBuilder(
                                        valueListenable: widget.grid,
                                        builder: (_, __, ___) {
                                          return Stack(
                                            children: [
                                              Container(
                                                color: ColorValues.greyAlt,
                                                child: CustomCarousel(
                                                  imgList: widget
                                                      .grid.value[index].photos,
                                                  type: 'grid',
                                                ),
                                              ),
                                              widget.grid.value[index].isPrivate
                                                  ? const Positioned.fill(
                                                      child: Align(
                                                          alignment: Alignment
                                                              .bottomRight,
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12),
                                                            child: Icon(
                                                                Icons
                                                                    .lock_outlined,
                                                                color: Colors
                                                                    .white),
                                                          )))
                                                  : const SizedBox.shrink(),
                                            ],
                                          );
                                        }),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }),
                  _buildDeadEndWidget()
                  // const CircularProgressIndicator()
                ],
              ),
            ],
          );
        });
  }

  Widget gridViewHall({
    bool ifLast = false,
    bool isStart = false,
    int isFirst = 0,
    int indexPlus = 0,
  }) {
    return Flexible(
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: ifLast == true ? 1 : gridList,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, crossAxisSpacing: 0, mainAxisSpacing: 0),
            itemBuilder: (context, gridIndex) {
              return InkWell(
                onTap: () {
                  AutoRouter.of(context).navigate(DetailRoute(
                      moments: widget.grid.value,
                      index:
                          isStart == true ? gridIndex : indexPlus + gridIndex));
                },
                child: ValueListenableBuilder(
                    valueListenable: widget.grid,
                    builder: (_, __, ___) {
                      return Stack(
                        children: [
                          Container(
                            color: ColorValues.greyAlt,
                            child: CustomCarousel(
                              imgList: isStart == true
                                  ? widget.grid.value[gridIndex].photos
                                  : widget
                                      .grid.value[indexPlus + gridIndex].photos,
                              type: 'grid',
                            ),
                          ),
                          widget
                                  .grid
                                  .value[isStart == true
                                      ? gridIndex
                                      : indexPlus + gridIndex]
                                  .isPrivate
                              ? const Positioned.fill(
                                  child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(Icons.lock_outlined,
                                            color: Colors.white),
                                      )))
                              : const SizedBox.shrink(),
                        ],
                      );
                    }),
              );
            }));
  }

  Widget _buildSelectedView() {
    return ValueListenableBuilder(
        valueListenable: _selectedTab,
        builder: (_, __, ___) {
          //debugPrint('widget type ${widget.type}');
          widget.list.value.removeWhere((element) {
            if (FirebaseAuth.instance.currentUser == null) {
              return true;
            }
            return element.parentId != FirebaseAuth.instance.currentUser!.uid &&
                element.isReported;
          });

          widget.grid.value.removeWhere((element) {
            if (FirebaseAuth.instance.currentUser == null) {
              return true;
            }
            return element.parentId != FirebaseAuth.instance.currentUser!.uid &&
                element.isReported;
          });
          return _selectedTab.value == 0 ? _buildListView() : _buildGridView();
        });
  }

  Widget _buildListView() {
    return ValueListenableBuilder(
        valueListenable: widget.list,
        builder: (_, __, ___) {
          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, index) {
                  return SizedBox(height: 1.h);
                },
                itemCount: widget.list.value.length,
                itemBuilder: (_, index) {
                  double padding = 0;
                  if (index == 0) {
                    if (widget.type == 'explore') {
                      padding = 18.5.h;
                    } else {
                      padding = widget.type == 'otherHall' ? 0 : 9.5.h;
                    }
                  }
                  return BlocProvider(
                    create: (context) => MomentBloc(
                        momentRepository: context.read<MomentRepository>()),
                    child: BlocBuilder<MomentBloc, MomentState>(
                      builder: (context, state) {
                        if (state is MomentLoaded) {
                          listReact.value = state.moments;
                          return DetailUi(
                            list: listReact,
                            index: 0,
                            paddingTop: padding,
                            userModel: widget.userModel,
                            context: context,
                          );
                        }
                        return widget.list.value[index].photos.isNotEmpty
                            ? DetailUi(
                                list: widget.list,
                                index: index,
                                paddingTop: padding,
                                userModel: widget.userModel,
                                context: context,
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  );
                },
              ),
              _buildDeadEndWidget()
            ],
          );
        });
  }

  Widget _buildDeadEndWidget() {
    return widget.list.value.isEmpty
        ? const SizedBox.shrink()
        : DelayedDisplay(
            delay: const Duration(milliseconds: 2000),
            child: Column(
              children: [
                SizedBox(height: 5.h),
                Image.asset('assets/return.png', width: 24),
                SizedBox(height: 3.h),
                Text(AppLocalizations.of(context).deadEnd,
                    style: const TextStyle(color: ColorValues.greyListView)),
                Text(AppLocalizations.of(context).allMomentsAreDisplayed,
                    style: TextStyle(
                        color: ColorValues.greyListView, fontSize: 10.sp)),
                SizedBox(height: 4.h),
              ],
            ),
          );
  }

  void _scrollControllerHallParent() {
    // Hall Parent
    if (_controllerHallParent.offset >=
            _controllerHallParent.position.maxScrollExtent &&
        !_controllerHallParent.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('list hall parent');
        widget.context!.read<MomentBloc>().add(
            NextListMomentsByParentId(parentId: widget.userModel.id, limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile hall parent');
        widget.context!.read<MomentBloc>().add(NextTileMomentsByParentId(
            parentId: widget.userModel.id, limit: 32));
      }
    }
  }

  void _scrollControllerHallChild() {
    // Hall Child
    if (_controllerHallChild.offset >=
            _controllerHallChild.position.maxScrollExtent &&
        !_controllerHallChild.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('list hall child');
        widget.context!.read<MomentBloc>().add(NextListMomentsByChildId(
            childId: widget.childId.value!,
            parentId: widget.userModel.id,
            limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile hall child');
        widget.context!.read<MomentBloc>().add(NextTileMomentsByChildId(
            childId: widget.childId.value!,
            parentId: widget.userModel.id,
            limit: 32));
      }
    }
  }

  void _scrollControllerExplore() {
    // Explore
    if (_controllerExplore.offset >=
            _controllerExplore.position.maxScrollExtent &&
        !_controllerExplore.position.outOfRange) {
      if (_selectedTab.value == 0) {
        widget.context!
            .read<MomentBloc>()
            .add(const FetchNextListMoments(limit: 8));
      } else if (_selectedTab.value == 1) {
        widget.context!
            .read<MomentBloc>()
            .add(const FetchNextTileMoments(limit: 32));
      }
    }
  }

  void _scrollControllerProfileParent() {
    // Profile Parent
    if (_controllerProfileParent.offset >=
            _controllerProfileParent.position.maxScrollExtent &&
        !_controllerProfileParent.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('list');
        print(widget.userModel.id);
        widget.context!.read<MomentBloc>().add(
            NextListMomentsByParentId(parentId: widget.userModel.id, limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile');
        widget.context!.read<MomentBloc>().add(NextTileMomentsByParentId(
            parentId: widget.userModel.id, limit: 32));
      }
    }
  }

  void _scrollControllerProfileChild() {
    // Profile Child
    if (_controllerProfileChild.offset >=
            _controllerProfileChild.position.maxScrollExtent &&
        !_controllerProfileChild.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('list profile child');
        widget.context!.read<MomentBloc>().add(NextListMomentsByChildId(
            childId: widget.childId.value!,
            parentId: widget.userModel.id,
            limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile profile child');
        widget.context!.read<MomentBloc>().add(NextTileMomentsByChildId(
            childId: widget.childId.value!,
            parentId: widget.userModel.id,
            limit: 32));
      }
    }
  }

  void _scrollControllerPatronize() {
    // Patronize
    if (_controllerPatronized.offset >=
            _controllerPatronized.position.maxScrollExtent &&
        !_controllerPatronized.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('listttttt');
        BlocProvider.of<MomentBloc>(widget.context!).add(
            NextPatronizeListMoments(
                patronizeds: widget.userModel.patronizeds, limit: 8));
        // widget.context!.read<MomentBloc>().add(NextPatronizeListMoments(
        //     patronizeds: widget.userModel.patronizeds, limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile');
        widget.context!.read<MomentBloc>().add(NextPatronizeTileMoments(
            patronizeds: widget.userModel.patronizeds, limit: 32));
      }
    }
  }

  void _scrollControllerFavorite() {
    // Patronize
    if (_controllerFavorite.offset >=
            _controllerFavorite.position.maxScrollExtent &&
        !_controllerFavorite.position.outOfRange) {
      if (_selectedTab.value == 0) {
        print('listttttt favorite');
        // BlocProvider.of<MomentBloc>(widget.context!).add(
        //     NextFavoriteListMoments(
        //         favorites: widget.userModel.favorites, limit: 8));
      } else if (_selectedTab.value == 1) {
        print('tile favorite');
        // widget.context!.read<MomentBloc>().add(NextFavoriteTileMoments(
        //     favorites: widget.userModel.favorites, limit: 32));
      }
    }
  }
}
