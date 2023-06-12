import 'package:auto_route/auto_route.dart';
import 'package:cobonno/app/repositories/repositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/color_values.dart';
import '../../common/shared_code.dart';
import '../../routes/router.gr.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<Icon, String> _map = {};

  @override
  void initState() {
    //debugPrint('home init state');
    _checkChildren();
    super.initState();
  }

  Future<void> _checkChildren() async {
    context.loaderOverlay.show();
    bool ifHasChildren = await AuthRepository().isHasChildren();
    if (!ifHasChildren) {
      Future.delayed(Duration.zero, () {
        AutoRouter.of(context).navigate(ChildFormRoute());
      });
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SharedCode.lightStatusBar());

    _map = {
      const Icon(Icons.museum_outlined): AppLocalizations.of(context).hall,
      const Icon(Icons.search_outlined): AppLocalizations.of(context).explore,
      const Icon(Icons.star): AppLocalizations.of(context).patronized,
      // const Icon(Icons.favorite): AppLocalizations.of(context).collections,
      const Icon(Icons.chat_outlined): AppLocalizations.of(context).feedback,
      // const Icon(Icons.card_giftcard): AppLocalizations.of(context)!.studio,
      // const Icon(Icons.festival_outlined): AppLocalizations.of(context)!.event,
    };

    return AutoTabsScaffold(
      backgroundColor: ColorValues.blueGrey,
      appBarBuilder: (_, tabsRouter) {
        return (tabsRouter.activeIndex != 0)
            ? _buildDefaultAppBar(tabsRouter.activeIndex)
            : AppBar(
                toolbarHeight: 0,
                systemOverlayStyle: SharedCode.lightStatusBar());
      },
      routes: [
        const HallRoute(),
        ExploreRoute(),
        const PatronizeRoute(),
        // const FavoriteRoute(),
        const FeedbackRoute(),
        // StudioRoute(),
        // EventRoute(),
      ],
      bottomNavigationBuilder: (_, tabsRouter) {
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedItemColor: ColorValues.blue,
          selectedLabelStyle: TextStyle(fontSize: 8.sp),
          unselectedLabelStyle: TextStyle(fontSize: 8.sp, color: Colors.grey),
          unselectedIconTheme: const IconThemeData(color: Colors.grey),
          items: List.generate(_map.length, (i) {
            return BottomNavigationBarItem(
              icon: _map.keys.elementAt(i),
              label: _map.values.elementAt(i),
            );
          }),
        );
      },
    );
  }

  AppBar _buildDefaultAppBar(int i) {
    return AppBar(
      title: Text(_map.values.elementAt(i)),
      systemOverlayStyle: SharedCode.lightStatusBar(),
      actions: [
        if (i == 2)
          IconButton(
              onPressed: () {
                AutoRouter.of(context).push(const PatronizeListRoute());
              },
              icon: const Icon(Icons.sort))
      ],
    );
  }
}
