// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:io' as _i9;

import 'package:auto_route/auto_route.dart' as _i2;
import 'package:firebase_auth/firebase_auth.dart' as _i10;
import 'package:flutter/cupertino.dart' as _i4;
import 'package:flutter/material.dart' as _i3;
import 'package:photo_manager/photo_manager.dart' as _i8;

import '../data/models/child_model.dart' as _i5;
import '../data/models/moment_model.dart' as _i7;
import '../data/models/user_model.dart' as _i6;
import '../ui/screens.dart' as _i1;

class AppRouter extends _i2.RootStackRouter {
  AppRouter([_i3.GlobalKey<_i3.NavigatorState>? navigatorKey])
      : super(navigatorKey);

  @override
  final Map<String, _i2.PageFactory> pagesMap = {
    SplashRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.SplashPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LanguageSelectRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.LanguageSelectPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    HomeRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.HomePage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    PatronizeListRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.PatronizeListPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    OnBoardingRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.OnBoardingPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LoginRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.LoginPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    RegisterRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.RegisterPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    VerifyPhoneRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.VerifyPhonePage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    OtpVerificationRoute.name: (routeData) {
      final args = routeData.argsAs<OtpVerificationRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.OtpVerificationPage(
          key: args.key,
          phoneNumber: args.phoneNumber,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ForgotPasswordRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.ForgotPasswordPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SettingsRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.SettingsPage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    ChildFormRoute.name: (routeData) {
      final args = routeData.argsAs<ChildFormRouteArgs>(
          orElse: () => const ChildFormRouteArgs());
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.ChildFormPage(
          key: args.key,
          childModel: args.childModel,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ParentFormRoute.name: (routeData) {
      final args = routeData.argsAs<ParentFormRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.ParentFormPage(
          key: args.key,
          parentModel: args.parentModel,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    TermsAndConditionRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.TermsAndConditionPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    PrivacyPolicyRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.PrivacyPolicyPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    SelectChildRoute.name: (routeData) {
      final args = routeData.argsAs<SelectChildRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.SelectChildPage(
          key: args.key,
          childId: args.childId,
          user: args.user,
          momentModel: args.momentModel,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    GalleryListRoute.name: (routeData) {
      final args = routeData.argsAs<GalleryListRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.GalleryListPage(
          key: args.key,
          isParentSelected: args.isParentSelected,
          childId: args.childId,
          momentModel: args.momentModel,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ImageListRoute.name: (routeData) {
      final args = routeData.argsAs<ImageListRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.ImageListPage(
          key: args.key,
          path: args.path,
          setEntities: args.setEntities,
          entities: args.entities,
          checkboxes: args.checkboxes,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    MomentFormRoute.name: (routeData) {
      final args = routeData.argsAs<MomentFormRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.MomentFormPage(
          key: args.key,
          bytes: args.bytes,
          isParentSelected: args.isParentSelected,
          childId: args.childId,
          momentModel: args.momentModel,
          usedEntities: args.usedEntities,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    DetailRoute.name: (routeData) {
      final args = routeData.argsAs<DetailRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.DetailPage(
          key: args.key,
          moments: args.moments,
          index: args.index,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    CameraRoute.name: (routeData) {
      final args = routeData.argsAs<CameraRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.CameraPage(
          context: args.context,
          key: args.key,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    PreviewRoute.name: (routeData) {
      final args = routeData.argsAs<PreviewRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.PreviewPage(
          key: args.key,
          fileList: args.fileList,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    PhotoFilterRoute.name: (routeData) {
      final args = routeData.argsAs<PhotoFilterRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.PhotoFilterPage(
          key: args.key,
          assets: args.assets,
          isParentSelected: args.isParentSelected,
          childId: args.childId,
          momentModel: args.momentModel,
          usedEntities: args.usedEntities,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    IdentityFormRoute.name: (routeData) {
      final args = routeData.argsAs<IdentityFormRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.IdentityFormPage(
          key: args.key,
          user: args.user,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    ProfileRoute.name: (routeData) {
      final args = routeData.argsAs<ProfileRouteArgs>();
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.ProfilePage(
          key: args.key,
          parentId: args.parentId,
          childId: args.childId,
        ),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    LanguageRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.LanguagePage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    EmailVerificationRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.EmailVerificationPage(),
        transitionsBuilder: _i2.TransitionsBuilders.fadeIn,
        opaque: true,
        barrierDismissible: false,
      );
    },
    HallRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.HallPage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    ExploreRoute.name: (routeData) {
      final args = routeData.argsAs<ExploreRouteArgs>(
          orElse: () => const ExploreRouteArgs());
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: _i1.ExplorePage(
          key: args.key,
          initialSearch: args.initialSearch,
        ),
        opaque: true,
        barrierDismissible: false,
      );
    },
    StudioRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.StudioPage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    PatronizeRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.PatronizePage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    FavoriteRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.FavoritePage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    EventRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.EventPage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
    FeedbackRoute.name: (routeData) {
      return _i2.CustomPage<dynamic>(
        routeData: routeData,
        child: const _i1.FeedbackPage(),
        opaque: true,
        barrierDismissible: false,
      );
    },
  };

  @override
  List<_i2.RouteConfig> get routes => [
        _i2.RouteConfig(
          '/#redirect',
          path: '/',
          redirectTo: '/splash',
          fullMatch: true,
        ),
        _i2.RouteConfig(
          SplashRoute.name,
          path: '/splash',
        ),
        _i2.RouteConfig(
          LanguageSelectRoute.name,
          path: '/language_select',
        ),
        _i2.RouteConfig(
          HomeRoute.name,
          path: '/home',
          children: [
            _i2.RouteConfig(
              HallRoute.name,
              path: '',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              ExploreRoute.name,
              path: 'explore',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              StudioRoute.name,
              path: 'studio',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              PatronizeRoute.name,
              path: 'patronize',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              FavoriteRoute.name,
              path: 'favorite',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              EventRoute.name,
              path: 'event',
              parent: HomeRoute.name,
            ),
            _i2.RouteConfig(
              FeedbackRoute.name,
              path: 'feedback',
              parent: HomeRoute.name,
            ),
          ],
        ),
        _i2.RouteConfig(
          PatronizeListRoute.name,
          path: '/patronize_list',
        ),
        _i2.RouteConfig(
          OnBoardingRoute.name,
          path: '/onboarding',
        ),
        _i2.RouteConfig(
          LoginRoute.name,
          path: '/login',
        ),
        _i2.RouteConfig(
          RegisterRoute.name,
          path: '/register',
        ),
        _i2.RouteConfig(
          VerifyPhoneRoute.name,
          path: '/verify',
        ),
        _i2.RouteConfig(
          OtpVerificationRoute.name,
          path: '/otp',
        ),
        _i2.RouteConfig(
          ForgotPasswordRoute.name,
          path: '/forgot-password',
        ),
        _i2.RouteConfig(
          ForgotPasswordRoute.name,
          path: '/forgot-password',
        ),
        _i2.RouteConfig(
          SettingsRoute.name,
          path: '/settings',
        ),
        _i2.RouteConfig(
          ChildFormRoute.name,
          path: '/child',
        ),
        _i2.RouteConfig(
          ParentFormRoute.name,
          path: '/parent',
        ),
        _i2.RouteConfig(
          TermsAndConditionRoute.name,
          path: '/terms-and-condition',
        ),
        _i2.RouteConfig(
          PrivacyPolicyRoute.name,
          path: '/privacy-policy',
        ),
        _i2.RouteConfig(
          SelectChildRoute.name,
          path: '/select-child',
        ),
        _i2.RouteConfig(
          GalleryListRoute.name,
          path: '/gallery',
        ),
        _i2.RouteConfig(
          ImageListRoute.name,
          path: '/gallery-list',
        ),
        _i2.RouteConfig(
          MomentFormRoute.name,
          path: '/moment',
        ),
        _i2.RouteConfig(
          DetailRoute.name,
          path: '/detail',
        ),
        _i2.RouteConfig(
          CameraRoute.name,
          path: '/capture',
        ),
        _i2.RouteConfig(
          PreviewRoute.name,
          path: '/preview-capture',
        ),
        _i2.RouteConfig(
          PhotoFilterRoute.name,
          path: '/filter',
        ),
        _i2.RouteConfig(
          IdentityFormRoute.name,
          path: '/identity',
        ),
        _i2.RouteConfig(
          ProfileRoute.name,
          path: '/profile',
        ),
        _i2.RouteConfig(
          LanguageRoute.name,
          path: '/language',
        ),
        _i2.RouteConfig(
          EmailVerificationRoute.name,
          path: '/email-verification',
        ),
      ];
}

/// generated route for
/// [_i1.SplashPage]
class SplashRoute extends _i2.PageRouteInfo<void> {
  const SplashRoute()
      : super(
          SplashRoute.name,
          path: '/splash',
        );

  static const String name = 'SplashRoute';
}

/// generated route for
/// [_i1.LanguageSelectPage]
class LanguageSelectRoute extends _i2.PageRouteInfo<void> {
  const LanguageSelectRoute()
      : super(
          LanguageSelectRoute.name,
          path: '/language_select',
        );

  static const String name = 'LanguageSelectRoute';
}

/// generated route for
/// [_i1.HomePage]
class HomeRoute extends _i2.PageRouteInfo<void> {
  const HomeRoute({List<_i2.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          path: '/home',
          initialChildren: children,
        );

  static const String name = 'HomeRoute';
}

/// generated route for
/// [_i1.PatronizeListPage]
class PatronizeListRoute extends _i2.PageRouteInfo<void> {
  const PatronizeListRoute()
      : super(
          PatronizeListRoute.name,
          path: '/patronize_list',
        );

  static const String name = 'PatronizeListRoute';
}

/// generated route for
/// [_i1.OnBoardingPage]
class OnBoardingRoute extends _i2.PageRouteInfo<void> {
  const OnBoardingRoute()
      : super(
          OnBoardingRoute.name,
          path: '/onboarding',
        );

  static const String name = 'OnBoardingRoute';
}

/// generated route for
/// [_i1.LoginPage]
class LoginRoute extends _i2.PageRouteInfo<void> {
  const LoginRoute()
      : super(
          LoginRoute.name,
          path: '/login',
        );

  static const String name = 'LoginRoute';
}

/// generated route for
/// [_i1.RegisterPage]
class RegisterRoute extends _i2.PageRouteInfo<void> {
  const RegisterRoute()
      : super(
          RegisterRoute.name,
          path: '/register',
        );

  static const String name = 'RegisterRoute';
}

/// generated route for
/// [_i1.VerifyPhonePage]
class VerifyPhoneRoute extends _i2.PageRouteInfo<void> {
  const VerifyPhoneRoute()
      : super(
          VerifyPhoneRoute.name,
          path: '/verify',
        );

  static const String name = 'VerifyPhoneRoute';
}

/// generated route for
/// [_i1.OtpVerificationPage]
class OtpVerificationRoute extends _i2.PageRouteInfo<OtpVerificationRouteArgs> {
  OtpVerificationRoute({
    _i4.Key? key,
    required String phoneNumber,
  }) : super(
          OtpVerificationRoute.name,
          path: '/otp',
          args: OtpVerificationRouteArgs(
            key: key,
            phoneNumber: phoneNumber,
          ),
        );

  static const String name = 'OtpVerificationRoute';
}

class OtpVerificationRouteArgs {
  const OtpVerificationRouteArgs({
    this.key,
    required this.phoneNumber,
  });

  final _i4.Key? key;

  final String phoneNumber;

  @override
  String toString() {
    return 'OtpVerificationRouteArgs{key: $key, phoneNumber: $phoneNumber}';
  }
}

/// generated route for
/// [_i1.ForgotPasswordPage]
class ForgotPasswordRoute extends _i2.PageRouteInfo<void> {
  const ForgotPasswordRoute()
      : super(
          ForgotPasswordRoute.name,
          path: '/forgot-password',
        );

  static const String name = 'ForgotPasswordRoute';
}

/// generated route for
/// [_i1.SettingsPage]
class SettingsRoute extends _i2.PageRouteInfo<void> {
  const SettingsRoute()
      : super(
          SettingsRoute.name,
          path: '/settings',
        );

  static const String name = 'SettingsRoute';
}

/// generated route for
/// [_i1.ChildFormPage]
class ChildFormRoute extends _i2.PageRouteInfo<ChildFormRouteArgs> {
  ChildFormRoute({
    _i4.Key? key,
    _i5.ChildModel? childModel,
  }) : super(
          ChildFormRoute.name,
          path: '/child',
          args: ChildFormRouteArgs(
            key: key,
            childModel: childModel,
          ),
        );

  static const String name = 'ChildFormRoute';
}

class ChildFormRouteArgs {
  const ChildFormRouteArgs({
    this.key,
    this.childModel,
  });

  final _i4.Key? key;

  final _i5.ChildModel? childModel;

  @override
  String toString() {
    return 'ChildFormRouteArgs{key: $key, childModel: $childModel}';
  }
}

/// generated route for
/// [_i1.ParentFormPage]
class ParentFormRoute extends _i2.PageRouteInfo<ParentFormRouteArgs> {
  ParentFormRoute({
    _i4.Key? key,
    required _i6.UserModel parentModel,
  }) : super(
          ParentFormRoute.name,
          path: '/parent',
          args: ParentFormRouteArgs(
            key: key,
            parentModel: parentModel,
          ),
        );

  static const String name = 'ParentFormRoute';
}

class ParentFormRouteArgs {
  const ParentFormRouteArgs({
    this.key,
    required this.parentModel,
  });

  final _i4.Key? key;

  final _i6.UserModel parentModel;

  @override
  String toString() {
    return 'ParentFormRouteArgs{key: $key, parentModel: $parentModel}';
  }
}

/// generated route for
/// [_i1.TermsAndConditionPage]
class TermsAndConditionRoute extends _i2.PageRouteInfo<void> {
  const TermsAndConditionRoute()
      : super(
          TermsAndConditionRoute.name,
          path: '/terms-and-condition',
        );

  static const String name = 'TermsAndConditionRoute';
}

/// generated route for
/// [_i1.PrivacyPolicyPage]
class PrivacyPolicyRoute extends _i2.PageRouteInfo<void> {
  const PrivacyPolicyRoute()
      : super(
          PrivacyPolicyRoute.name,
          path: '/privacy-policy',
        );

  static const String name = 'PrivacyPolicyRoute';
}

/// generated route for
/// [_i1.SelectChildPage]
class SelectChildRoute extends _i2.PageRouteInfo<SelectChildRouteArgs> {
  SelectChildRoute({
    _i4.Key? key,
    String? childId,
    required _i6.UserModel user,
    _i7.MomentModel? momentModel,
  }) : super(
          SelectChildRoute.name,
          path: '/select-child',
          args: SelectChildRouteArgs(
            key: key,
            childId: childId,
            user: user,
            momentModel: momentModel,
          ),
        );

  static const String name = 'SelectChildRoute';
}

class SelectChildRouteArgs {
  const SelectChildRouteArgs({
    this.key,
    this.childId,
    required this.user,
    this.momentModel,
  });

  final _i4.Key? key;

  final String? childId;

  final _i6.UserModel user;

  final _i7.MomentModel? momentModel;

  @override
  String toString() {
    return 'SelectChildRouteArgs{key: $key, childId: $childId, user: $user, momentModel: $momentModel}';
  }
}

/// generated route for
/// [_i1.GalleryListPage]
class GalleryListRoute extends _i2.PageRouteInfo<GalleryListRouteArgs> {
  GalleryListRoute({
    _i4.Key? key,
    required bool isParentSelected,
    required List<String> childId,
    _i7.MomentModel? momentModel,
  }) : super(
          GalleryListRoute.name,
          path: '/gallery',
          args: GalleryListRouteArgs(
            key: key,
            isParentSelected: isParentSelected,
            childId: childId,
            momentModel: momentModel,
          ),
        );

  static const String name = 'GalleryListRoute';
}

class GalleryListRouteArgs {
  const GalleryListRouteArgs({
    this.key,
    required this.isParentSelected,
    required this.childId,
    this.momentModel,
  });

  final _i4.Key? key;

  final bool isParentSelected;

  final List<String> childId;

  final _i7.MomentModel? momentModel;

  @override
  String toString() {
    return 'GalleryListRouteArgs{key: $key, isParentSelected: $isParentSelected, childId: $childId, momentModel: $momentModel}';
  }
}

/// generated route for
/// [_i1.ImageListPage]
class ImageListRoute extends _i2.PageRouteInfo<ImageListRouteArgs> {
  ImageListRoute({
    _i4.Key? key,
    required _i8.AssetPathEntity path,
    required dynamic Function(List<_i8.AssetEntity>) setEntities,
    required List<_i8.AssetEntity> entities,
    required _i4.ValueNotifier<List<int>> checkboxes,
  }) : super(
          ImageListRoute.name,
          path: '/gallery-list',
          args: ImageListRouteArgs(
            key: key,
            path: path,
            setEntities: setEntities,
            entities: entities,
            checkboxes: checkboxes,
          ),
        );

  static const String name = 'ImageListRoute';
}

class ImageListRouteArgs {
  const ImageListRouteArgs({
    this.key,
    required this.path,
    required this.setEntities,
    required this.entities,
    required this.checkboxes,
  });

  final _i4.Key? key;

  final _i8.AssetPathEntity path;

  final dynamic Function(List<_i8.AssetEntity>) setEntities;

  final List<_i8.AssetEntity> entities;

  final _i4.ValueNotifier<List<int>> checkboxes;

  @override
  String toString() {
    return 'ImageListRouteArgs{key: $key, path: $path, setEntities: $setEntities, entities: $entities, checkboxes: $checkboxes}';
  }
}

/// generated route for
/// [_i1.MomentFormPage]
class MomentFormRoute extends _i2.PageRouteInfo<MomentFormRouteArgs> {
  MomentFormRoute({
    _i4.Key? key,
    required List<List<int>> bytes,
    bool? isParentSelected,
    List<String>? childId,
    _i7.MomentModel? momentModel,
    required List<String> usedEntities,
  }) : super(
          MomentFormRoute.name,
          path: '/moment',
          args: MomentFormRouteArgs(
            key: key,
            bytes: bytes,
            isParentSelected: isParentSelected,
            childId: childId,
            momentModel: momentModel,
            usedEntities: usedEntities,
          ),
        );

  static const String name = 'MomentFormRoute';
}

class MomentFormRouteArgs {
  const MomentFormRouteArgs({
    this.key,
    required this.bytes,
    this.isParentSelected,
    this.childId,
    this.momentModel,
    required this.usedEntities,
  });

  final _i4.Key? key;

  final List<List<int>> bytes;

  final bool? isParentSelected;

  final List<String>? childId;

  final _i7.MomentModel? momentModel;

  final List<String> usedEntities;

  @override
  String toString() {
    return 'MomentFormRouteArgs{key: $key, bytes: $bytes, isParentSelected: $isParentSelected, childId: $childId, momentModel: $momentModel, usedEntities: $usedEntities}';
  }
}

/// generated route for
/// [_i1.DetailPage]
class DetailRoute extends _i2.PageRouteInfo<DetailRouteArgs> {
  DetailRoute({
    _i4.Key? key,
    required List<_i7.MomentModel> moments,
    required int index,
  }) : super(
          DetailRoute.name,
          path: '/detail',
          args: DetailRouteArgs(
            key: key,
            moments: moments,
            index: index,
          ),
        );

  static const String name = 'DetailRoute';
}

class DetailRouteArgs {
  const DetailRouteArgs({
    this.key,
    required this.moments,
    required this.index,
  });

  final _i4.Key? key;

  final List<_i7.MomentModel> moments;

  final int index;

  @override
  String toString() {
    return 'DetailRouteArgs{key: $key, moments: $moments, index: $index}';
  }
}

/// generated route for
/// [_i1.CameraPage]
class CameraRoute extends _i2.PageRouteInfo<CameraRouteArgs> {
  CameraRoute({
    required _i4.BuildContext context,
    _i4.Key? key,
  }) : super(
          CameraRoute.name,
          path: '/capture',
          args: CameraRouteArgs(
            context: context,
            key: key,
          ),
        );

  static const String name = 'CameraRoute';
}

class CameraRouteArgs {
  const CameraRouteArgs({
    required this.context,
    this.key,
  });

  final _i4.BuildContext context;

  final _i4.Key? key;

  @override
  String toString() {
    return 'CameraRouteArgs{context: $context, key: $key}';
  }
}

/// generated route for
/// [_i1.PreviewPage]
class PreviewRoute extends _i2.PageRouteInfo<PreviewRouteArgs> {
  PreviewRoute({
    _i4.Key? key,
    required List<_i9.File> fileList,
  }) : super(
          PreviewRoute.name,
          path: '/preview-capture',
          args: PreviewRouteArgs(
            key: key,
            fileList: fileList,
          ),
        );

  static const String name = 'PreviewRoute';
}

class PreviewRouteArgs {
  const PreviewRouteArgs({
    this.key,
    required this.fileList,
  });

  final _i4.Key? key;

  final List<_i9.File> fileList;

  @override
  String toString() {
    return 'PreviewRouteArgs{key: $key, fileList: $fileList}';
  }
}

/// generated route for
/// [_i1.PhotoFilterPage]
class PhotoFilterRoute extends _i2.PageRouteInfo<PhotoFilterRouteArgs> {
  PhotoFilterRoute({
    _i4.Key? key,
    required List<_i8.AssetEntity> assets,
    required bool isParentSelected,
    required List<String> childId,
    _i7.MomentModel? momentModel,
    required List<String> usedEntities,
  }) : super(
          PhotoFilterRoute.name,
          path: '/filter',
          args: PhotoFilterRouteArgs(
            key: key,
            assets: assets,
            isParentSelected: isParentSelected,
            childId: childId,
            momentModel: momentModel,
            usedEntities: usedEntities,
          ),
        );

  static const String name = 'PhotoFilterRoute';
}

class PhotoFilterRouteArgs {
  const PhotoFilterRouteArgs({
    this.key,
    required this.assets,
    required this.isParentSelected,
    required this.childId,
    this.momentModel,
    required this.usedEntities,
  });

  final _i4.Key? key;

  final List<_i8.AssetEntity> assets;

  final bool isParentSelected;

  final List<String> childId;

  final _i7.MomentModel? momentModel;

  final List<String> usedEntities;

  @override
  String toString() {
    return 'PhotoFilterRouteArgs{key: $key, assets: $assets, isParentSelected: $isParentSelected, childId: $childId, momentModel: $momentModel, usedEntities: $usedEntities}';
  }
}

/// generated route for
/// [_i1.IdentityFormPage]
class IdentityFormRoute extends _i2.PageRouteInfo<IdentityFormRouteArgs> {
  IdentityFormRoute({
    _i4.Key? key,
    required _i10.User user,
  }) : super(
          IdentityFormRoute.name,
          path: '/identity',
          args: IdentityFormRouteArgs(
            key: key,
            user: user,
          ),
        );

  static const String name = 'IdentityFormRoute';
}

class IdentityFormRouteArgs {
  const IdentityFormRouteArgs({
    this.key,
    required this.user,
  });

  final _i4.Key? key;

  final _i10.User user;

  @override
  String toString() {
    return 'IdentityFormRouteArgs{key: $key, user: $user}';
  }
}

/// generated route for
/// [_i1.ProfilePage]
class ProfileRoute extends _i2.PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({
    _i4.Key? key,
    required String parentId,
    String? childId,
  }) : super(
          ProfileRoute.name,
          path: '/profile',
          args: ProfileRouteArgs(
            key: key,
            parentId: parentId,
            childId: childId,
          ),
        );

  static const String name = 'ProfileRoute';
}

class ProfileRouteArgs {
  const ProfileRouteArgs({
    this.key,
    required this.parentId,
    this.childId,
  });

  final _i4.Key? key;

  final String parentId;

  final String? childId;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key, parentId: $parentId, childId: $childId}';
  }
}

/// generated route for
/// [_i1.LanguagePage]
class LanguageRoute extends _i2.PageRouteInfo<void> {
  const LanguageRoute()
      : super(
          LanguageRoute.name,
          path: '/language',
        );

  static const String name = 'LanguageRoute';
}

/// generated route for
/// [_i1.EmailVerificationPage]
class EmailVerificationRoute extends _i2.PageRouteInfo<void> {
  const EmailVerificationRoute()
      : super(
          EmailVerificationRoute.name,
          path: '/email-verification',
        );

  static const String name = 'EmailVerificationRoute';
}

/// generated route for
/// [_i1.HallPage]
class HallRoute extends _i2.PageRouteInfo<void> {
  const HallRoute()
      : super(
          HallRoute.name,
          path: '',
        );

  static const String name = 'HallRoute';
}

/// generated route for
/// [_i1.ExplorePage]
class ExploreRoute extends _i2.PageRouteInfo<ExploreRouteArgs> {
  ExploreRoute({
    _i4.Key? key,
    String? initialSearch,
  }) : super(
          ExploreRoute.name,
          path: 'explore',
          args: ExploreRouteArgs(
            key: key,
            initialSearch: initialSearch,
          ),
        );

  static const String name = 'ExploreRoute';
}

class ExploreRouteArgs {
  const ExploreRouteArgs({
    this.key,
    this.initialSearch,
  });

  final _i4.Key? key;

  final String? initialSearch;

  @override
  String toString() {
    return 'ExploreRouteArgs{key: $key, initialSearch: $initialSearch}';
  }
}

/// generated route for
/// [_i1.StudioPage]
class StudioRoute extends _i2.PageRouteInfo<void> {
  const StudioRoute()
      : super(
          StudioRoute.name,
          path: 'studio',
        );

  static const String name = 'StudioRoute';
}

/// generated route for
/// [_i1.PatronizePage]
class PatronizeRoute extends _i2.PageRouteInfo<void> {
  const PatronizeRoute()
      : super(
          PatronizeRoute.name,
          path: 'patronize',
        );

  static const String name = 'PatronizeRoute';
}

/// generated route for
/// [_i1.FavoritePage]
class FavoriteRoute extends _i2.PageRouteInfo<void> {
  const FavoriteRoute()
      : super(
          FavoriteRoute.name,
          path: 'favorite',
        );

  static const String name = 'FavoriteRoute';
}

/// generated route for
/// [_i1.EventPage]
class EventRoute extends _i2.PageRouteInfo<void> {
  const EventRoute()
      : super(
          EventRoute.name,
          path: 'event',
        );

  static const String name = 'EventRoute';
}

/// generated route for
/// [_i1.FeedbackPage]
class FeedbackRoute extends _i2.PageRouteInfo<void> {
  const FeedbackRoute()
      : super(
          FeedbackRoute.name,
          path: 'feedback',
        );

  static const String name = 'FeedbackRoute';
}
