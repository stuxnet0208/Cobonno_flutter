import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cobonno/app/data/models/avatar_model.dart';
import 'package:cobonno/app/repositories/parent/parent_repository.dart';
import 'package:cobonno/l10n/l10n.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:twitter_login/twitter_login.dart';
import '../../app.dart';
import '../../common/shared_code.dart';
import '../../data/models/user_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/auth_service.dart';
import 'base_auth_repository.dart';
import 'package:path_provider/path_provider.dart';

class AuthRepository extends BaseAuthRepository {
  late final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get user => _auth.userChanges();

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<User> login(
      {required BuildContext context,
      required String email,
      required String password}) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthService.handleAuthErrorCodes(context, e.code);
    }
  }

  Future<File> getDefaultImage() async {
    Random random = Random();

    String assets = 'default-icon-';
    List<String> listDefault = [
      '${assets}blue.png',
      '${assets}green.png',
      '${assets}lime.png',
      '${assets}navy.png',
      '${assets}orange.png',
      '${assets}purple.png',
      '${assets}red.png',
      '${assets}white.png',
    ];

    int randomIdx = random.nextInt(listDefault.length);
    String randomDefault = listDefault[randomIdx];

    debugPrint('random 1: $randomDefault');

    final byteData = await rootBundle.load('assets/$randomDefault');

    final file = File('${(await getTemporaryDirectory()).path}/$randomDefault');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<TaskSnapshot> _uploadImage() async {
    File image = await getDefaultImage();

    Reference firebaseStorageRef =
        FirebaseStorage.instance.ref().child('users/default/avatar.png');
    late UploadTask uploadTask;
    if (kIsWeb) {
      var bytes = await image.readAsBytes();
      uploadTask = firebaseStorageRef.putData(
          bytes, SettableMetadata(contentType: 'image/png'));
    } else {
      uploadTask = firebaseStorageRef.putFile(File(image.path));
    }
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot;
  }

  @override
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required BuildContext context,
    String? invitationCode,
    String? phoneNumber,
  }) async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();
    String invitationConfig = remoteConfig.getString('signup_invitation_code');

    if (invitationCode != null &&
        invitationConfig.toLowerCase() != invitationCode.toLowerCase()) {
      throw 'invalid-invitation-code';
    }

    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User user = result.user!;
      await user.updateDisplayName(name);
      UserModel userModel = UserModel(
        id: user.uid,
        email: email,
        favorites: const [],
        patronizeds: const [],
        momentsReported: const [],
        username: name,
        invitationCode: invitationCode,
        phoneNumber: phoneNumber,
      );
      await DatabaseService().addUser(userModel);

      TaskSnapshot snapshot = await _uploadImage();
      String avatarUrl = await snapshot.ref.getDownloadURL();
      String avatarPath = snapshot.ref.fullPath;

      AvatarModel avatarUrlModel = AvatarModel(
          display: avatarUrl,
          original: avatarUrl,
          thumb128: avatarUrl,
          thumb256: avatarUrl);
      AvatarModel avatarPathModel = AvatarModel(
          display: avatarPath,
          original: avatarPath,
          thumb128: avatarPath,
          thumb256: avatarPath);

      userModel = UserModel(
          id: userModel.id,
          username: userModel.username,
          description: userModel.description,
          email: userModel.email,
          favorites: userModel.favorites,
          patronizeds: userModel.patronizeds,
          momentsReported: userModel.momentsReported,
          avatarUrl: avatarUrlModel,
          avatarPath: avatarPathModel,
          phoneNumber: userModel.phoneNumber);

      await ParentRepository().updateParent(userModel);
      return user;
    } on FirebaseAuthException catch (e) {
      throw AuthService.handleAuthErrorCodes(context, e.code);
    }
  }

  @override
  Future<void> removeAccount(BuildContext context) async {
    bool isProduction = MyApp.getIsProduction(context);
    HttpsCallable callable = FirebaseFunctions.instanceFor(
            region: isProduction ? 'asia-northeast1' : 'asia-east2')
        .httpsCallable('removeAccount');

    final results = await callable();
    final data =
        results.data as Map<String, dynamic>; // { uid: uid, success: true }
    if (!data['success']) throw data;
  }

  @override
  Future<User?> socialAuth(
      {bool isLogin = false, required UserCredential userCredential}) async {
    //debugPrint('social auth');
    await _checkNewUser(isLogin: isLogin, userCredential: userCredential);
    return userCredential.user;
  }

  Future<void> _checkNewUser(
      {bool isLogin = false, required UserCredential userCredential}) async {
    User? user = userCredential.user;
    // Check if user has registered and in login , if not, remove user and throw exception
    bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
    //debugPrint('is login $isLogin, isNewUser $isNewUser');
    if (isLogin && isNewUser) {
      await user?.delete();
      await SharedCode.logout();
      throw 'not-registered';
    }

    // Check if user has registered and in register, if yes, throw exception
    if (!isLogin && !isNewUser) {
      await SharedCode.logout();
      throw 'registered';
    }

    if (!isLogin && user != null) {
      await user.updateDisplayName(null);
      UserModel userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          favorites: const [],
          patronizeds: const [],
          momentsReported: const [],
          username: '',
          invitationCode: null,
          phoneNumber: null);
      await DatabaseService().addUser(userModel);
    }
  }

  static Future<UserCredential> fetchGoogleUserCredential() async {
    await SharedCode.logout();
    UserCredential userCredential;
    if (kIsWeb) {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider.addScope('profile').addScope('email');
      googleProvider.setCustomParameters(
          {'prompt': 'select_account', 'login_hint': 'user@example.com'});
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } else {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
    }
    return userCredential;
  }

  static Future<UserCredential> fetchFacebookUserCredential(
      BuildContext context) async {
    await SharedCode.logout();
    UserCredential userCredential;

    if (kIsWeb) {
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();

      facebookProvider.addScope('email');
      facebookProvider.setCustomParameters({
        'display': 'popup',
      });

      userCredential =
          await FirebaseAuth.instance.signInWithPopup(facebookProvider);
    } else {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.accessToken == null)
        throw AppLocalizations.of(context).accessTokenIsNull;

      // Create a credential from the access token
      final OAuthCredential facebookAuthCredential =
          FacebookAuthProvider.credential(loginResult.accessToken!.token);

      userCredential = await FirebaseAuth.instance
          .signInWithCredential(facebookAuthCredential);
    }

    return userCredential;
  }

  static Future<UserCredential> fetchTwitterUserCredential() async {
    await SharedCode.logoutSocial();

    UserCredential userCredential;

    if (kIsWeb) {
      TwitterAuthProvider twitterProvider = TwitterAuthProvider();
      userCredential =
          await FirebaseAuth.instance.signInWithPopup(twitterProvider);
    } else {
      // Create a TwitterLogin instance
      final twitterLogin = TwitterLogin(
          apiKey: 'UDgAmYOaqkLFs9uYQ7s8v1Up7',
          apiSecretKey: 'dyV59JPTrhPWXEtropwiv1brZcFqejmEDvWzo6eyeTvQQVI9wE',
          redirectURI: 'cobonno://');

      // Trigger the sign-in flow
      //debugPrint('api key: ${twitterLogin.apiKey}, secret: ${twitterLogin.apiSecretKey}, redirect: ${twitterLogin.redirectURI}');
      final authResult = await twitterLogin.loginV2();

      switch (authResult.status) {
        case TwitterLoginStatus.cancelledByUser:
          throw 'cancelled-by-user';
        case TwitterLoginStatus.error:
          throw authResult.errorMessage ?? 'Error';
        default:
          break;
      }

      // Create a credential from the access token
      final twitterAuthCredential = TwitterAuthProvider.credential(
        accessToken: authResult.authToken!,
        secret: authResult.authTokenSecret!,
      );

      userCredential = await FirebaseAuth.instance
          .signInWithCredential(twitterAuthCredential);
    }

    return userCredential;
  }

  @override
  Future<bool> isHasChildren() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid ?? '')
          .collection('children')
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
