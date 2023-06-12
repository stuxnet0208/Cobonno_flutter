import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

import '../../blocs/blocs.dart';
import '../../common/color_values.dart';
import '../../data/models/moment_model.dart';
import '../../data/models/user_model.dart';
import '../../repositories/repositories.dart';
import '../../widgets/detail_ui.dart';
import '../../widgets/reconnecting_widget.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({Key? key, required this.moments, required this.index})
      : super(key: key);
  final List<MomentModel> moments;
  final int index;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final ValueNotifier<List<MomentModel>> _list = ValueNotifier([]);
  final ValueNotifier<int> _index = ValueNotifier(0);
  final ValueNotifier<List<MomentModel>> listReact = ValueNotifier([]);
  late UserModel _model;

  @override
  void initState() {
    _index.value = widget.index;
    _list.value = widget.moments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorValues.blueGrey,
      appBar: AppBar(title: Text(AppLocalizations.of(context).moment)),
      body: MultiBlocProvider(
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
        child: ValueListenableBuilder(
            valueListenable: _index,
            builder: (_, __, ___) {
              return _buildBody();
            }),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ParentBloc, ParentState>(
      builder: (context, state) {
        if (state is ParentLoading) {
          context.loaderOverlay.show();
          return const SizedBox.shrink();
        }
        if (state is ParentLoaded) {
          _model = state.parent;
          BlocProvider.of<MomentBloc>(context)
              .add(LoadMomentById(momentId: widget.moments[_index.value].id));
          if (context.loaderOverlay.overlayWidgetType != ReconnectingWidget) {
            context.loaderOverlay.hide();
          }
        }

        return CarouselSlider.builder(
            itemCount: _list.value.length,
            itemBuilder: (_, index, realIndex) => SingleChildScrollView(
                  child: BlocBuilder<MomentBloc, MomentState>(
                    builder: (context, state) {
                      if (state is MomentLoaded) {
                        listReact.value = state.moments;
                          return DetailUi(
                            list: listReact,
                            index: 0,
                            userModel: _model,
                            context: context,
                          );
                      }
                      return DetailUi(
                          list: _list,
                          index: index,
                          userModel: _model,
                          key: UniqueKey());
                    },
                  ),
                ),
            options: CarouselOptions(
                onPageChanged: (i, __) {
                  _index.value = i;
                },
                initialPage: widget.index,
                autoPlay: false,
                viewportFraction: 1,
                height: double.infinity,
                enableInfiniteScroll: false));
      },
    );
  }
}
