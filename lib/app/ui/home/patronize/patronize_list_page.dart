import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/blocs/blocs.dart';
import 'package:cobonno/app/common/color_values.dart';
import 'package:cobonno/app/common/shared_code.dart';
import 'package:cobonno/app/common/styles.dart';
import 'package:cobonno/app/data/models/user_model.dart';
import 'package:cobonno/app/repositories/repositories.dart';
import 'package:cobonno/app/routes/router.gr.dart';
import 'package:cobonno/app/widgets/reconnecting_widget.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';

class PatronizeListPage extends StatefulWidget {
  const PatronizeListPage({super.key});

  @override
  State<PatronizeListPage> createState() => _PatronizeListPageState();
}

class _PatronizeListPageState extends State<PatronizeListPage> {
  late UserModel _model;
  List<UserModel> _listUser = [];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParentBloc(
        repository: context.read<ParentRepository>(),
      )..add(LoadParentById(
          id: FirebaseAuth.instance.currentUser!.uid, context: context)),
      child: BlocBuilder<ParentBloc, ParentState>(
        builder: (context, state) {
          if (state is ParentLoading) {
            context.loaderOverlay.show();
          }
          if (state is ParentLoaded) {
            _model = state.parent;
            BlocProvider.of<ParentBloc>(context).add(
                LoadParentListByPatronize(patronizeds: _model.patronizeds));
          }

          return BlocBuilder<ParentBloc, ParentState>(
              builder: (context, state) {
            if (state is ParentListLoaded) {
              _listUser.clear();
              _listUser.addAll(state.parentList);
            }
            context.loaderOverlay.hide();
            return _body(context, _listUser);
          });
        },
      ),
    );
  }

  Widget _body(BuildContext context, List<UserModel> listUser) {
    return Scaffold(
      appBar: _buildDefaultAppBar(context),
      body: listUser.isNotEmpty
          ? SingleChildScrollView(
              child: Container(
              height: 100.h,
              margin:
                  const EdgeInsets.symmetric(horizontal: Styles.defaultPadding),
              child: IntrinsicHeight(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (listUser.isNotEmpty)
                        Text(
                          AppLocalizations.of(context).lastPostedAt,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.sp),
                        ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listUser.length,
                          itemBuilder: (context, index) {
                            // Next do blocprovider for each user here!
                            // debugPrint(
                            //     "list user " + listUser.length.toString());
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    AutoRouter.of(context).push(ProfileRoute(
                                        parentId: listUser[index].id));
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            ColorValues.loadingGrey,
                                        backgroundImage:
                                            listUser[index].avatarUrl == null
                                                ? null
                                                : NetworkImage(listUser[index]
                                                    .avatarUrl!
                                                    .display),
                                        radius: 5.w,
                                      ),
                                      SizedBox(
                                        width: 4.w,
                                      ),
                                      Expanded(
                                          child: Text(
                                        listUser[index].username,
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                      SizedBox(
                                        width: 2.w,
                                      ),
                                      Text(
                                        DateFormat('yyyy/MM/dd')
                                            .format(listUser[index].updatedAt!),
                                        style: TextStyle(fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                    height: 3.h,
                                    color: ColorValues.greyListView),
                              ],
                            );
                          },
                        ),
                      )
                    ]),
              ),
            ))
          : Center(
              child: Text(AppLocalizations.of(context).noData),
            ),
    );
  }

  AppBar _buildDefaultAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context).patronized),
      systemOverlayStyle: SharedCode.lightStatusBar(),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
            onPressed: () {
              AutoRouter.of(context).pop();
            },
            icon: const Icon(Icons.close))
      ],
    );
  }
}
