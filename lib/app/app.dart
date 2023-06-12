import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_web_frame/flutter_web_frame.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'common/app_theme_data.dart';
import 'common/color_values.dart';
import 'provider/photo_provider.dart';
import 'routes/router.gr.dart';
import 'repositories/repositories.dart';
import 'blocs/blocs.dart';

final PhotoProvider provider = PhotoProvider();

class MyApp extends StatefulWidget {
  const MyApp(
      {Key? key,
      required this.language,
      required this.isProduction,
      required this.appRouter,
      this.deepLink})
      : super(key: key);
  final String language;
  final bool isProduction;
  final AppRouter appRouter;
  final PendingDynamicLinkData? deepLink;

  static void setLocale(BuildContext context, String newLanguage) async {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    if (state != null) {
      state.changeLanguage(newLanguage);
      //debugPrint('change language $newLanguage');
    }
  }

  static Uri? getDeepLink(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state?.widget.deepLink?.link;
  }

  static bool getIsProduction(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    bool isProduction = state?.widget.isProduction ?? false;
    //debugPrint('is production $isProduction');
    return isProduction;
  }

  static AppRouter? getAppRouter(BuildContext context) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    return state?.widget.appRouter;
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<Locale> selectedLocale = ValueNotifier(const Locale('ja'));

  @override
  void initState() {
    selectedLocale.value = Locale(widget.language);
    super.initState();
  }

  changeLanguage(String language) {
    selectedLocale.value = Locale(language);
    selectedLocale.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    //debugPrint('this is build in app');
    return ChangeNotifierProvider<PhotoProvider>.value(
      value: provider,
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider(
            lazy: false,
            create: (context) => AuthRepository(),
          ),
          RepositoryProvider(
            lazy: false,
            create: (context) => MomentRepository(),
          ),
          RepositoryProvider(
            lazy: false,
            create: (context) => ChildRepository(),
          ),
          RepositoryProvider(
            lazy: false,
            create: (context) => ParentRepository(),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              lazy: false,
              create: (context) => AuthBloc(
                authRepository: context.read<AuthRepository>(),
              ),
            ),
            BlocProvider(
              lazy: false,
              create: (context) => MomentBloc(
                momentRepository: context.read<MomentRepository>(),
              )
              // ..add(LoadAllMoments())
              ..add(const FetchFirstListMoments(limit: 8))
              ..add(const FetchFirstTileMoments(
                limit: 32))
            ),
            BlocProvider(
                lazy: false,
                create: (context) => ParentBloc(
                      repository: context.read<ParentRepository>(),
                    )),
            BlocProvider(
                lazy: false,
                create: (context) => ChildBloc(
                      repository: context.read<ChildRepository>(),
                    )),
          ],
          child: FlutterWebFrame(
            maximumSize: const Size(475.0, 812.0),
            enabled: kIsWeb,
            backgroundColor: Colors.grey[200],
            builder: (context) {
              return Sizer(builder: (context, orientation, deviceType) {
                return GlobalLoaderOverlay(
                  useDefaultLoading: false,
                  overlayWidget: const Center(
                      child: SpinKitChasingDots(
                    color: ColorValues.primaryRed,
                    size: 50.0,
                  )),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    buildWhen: (previous, current) => previous.status != current.status,
                    builder: (context, state) {
                      return ValueListenableBuilder(
                          valueListenable: selectedLocale,
                          builder: (_, __, ___) {
                            //debugPrint('build locale ${selectedLocale.value.languageCode}');
                            return MaterialApp.router(
                              title: 'Cobonno',
                              theme: AppThemeData.getTheme(context),
                              debugShowCheckedModeBanner: false,
                              localizationsDelegates: AppLocalizations.localizationsDelegates,
                              supportedLocales: const [Locale('en'), Locale('ja')],
                              locale: selectedLocale.value,
                              routerDelegate: widget.appRouter.delegate(),
                              routeInformationParser: widget.appRouter.defaultRouteParser(),
                              localeResolutionCallback: (locale, supportedLocales) {
                                for (var supportedLocale in supportedLocales) {
                                  if (supportedLocale.languageCode == locale?.languageCode &&
                                      supportedLocale.countryCode == locale?.countryCode) {
                                    return supportedLocale;
                                  }
                                }
                                return supportedLocales.first;
                              },
                            );
                          });
                    },
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
