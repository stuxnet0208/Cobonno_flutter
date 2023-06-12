import 'package:auto_route/auto_route.dart';

import '../ui/screens.dart';

// watch for file changes which will rebuild the generated files:
// flutter packages pub run build_runner watch

// only generate files once and exit after use:
// flutter packages pub run build_runner build

@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    CustomRoute(
        page: SplashPage,
        path: '/splash',
        initial: true,
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: LanguageSelectPage,
        path: '/language_select',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: HomePage,
        path: '/home',
        transitionsBuilder: TransitionsBuilders.fadeIn,
        children: [
          CustomRoute(page: HallPage, path: ''),
          CustomRoute(page: ExplorePage, path: 'explore'),
          CustomRoute(page: StudioPage, path: 'studio'),
          CustomRoute(page: PatronizePage, path: 'patronize'),
          CustomRoute(page: FavoritePage, path: 'favorite'),
          CustomRoute(page: EventPage, path: 'event'),
          CustomRoute(page: FeedbackPage, path: 'feedback'),
        ]),
    CustomRoute(
        page: PatronizeListPage,
        path: '/patronize_list',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: OnBoardingPage,
        path: '/onboarding',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: LoginPage,
        path: '/login',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: RegisterPage,
        path: '/register',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: VerifyPhonePage,
        path: '/verify',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: OtpVerificationPage,
        path: '/otp',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: ForgotPasswordPage,
        path: '/forgot-password',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: ForgotPasswordPage,
        path: '/forgot-password',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(page: SettingsPage, path: '/settings'),
    CustomRoute(
        page: ChildFormPage,
        path: '/child',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: ParentFormPage,
        path: '/parent',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: TermsAndConditionPage,
        path: '/terms-and-condition',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: PrivacyPolicyPage,
        path: '/privacy-policy',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: SelectChildPage,
        path: '/select-child',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: GalleryListPage,
        path: '/gallery',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: ImageListPage,
        path: '/gallery-list',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: MomentFormPage,
        path: '/moment',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: DetailPage,
        path: '/detail',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: CameraPage,
        path: '/capture',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: PreviewPage,
        path: '/preview-capture',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: PhotoFilterPage,
        path: '/filter',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: IdentityFormPage,
        path: '/identity',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: ProfilePage,
        path: '/profile',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: LanguagePage,
        path: '/language',
        transitionsBuilder: TransitionsBuilders.fadeIn),
    CustomRoute(
        page: EmailVerificationPage,
        path: '/email-verification',
        transitionsBuilder: TransitionsBuilders.fadeIn),
  ],
)
class $AppRouter {}
