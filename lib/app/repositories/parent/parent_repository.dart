import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cobonno/app/common/shared_code.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import 'base_parent_repository.dart';

class ParentRepository extends BaseParentRepository {
  final FirebaseFirestore _db;

  ParentRepository({FirebaseFirestore? firebaseFirestore})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<UserModel?> getParentById(String id, BuildContext context) {
    return _db.collection('users').doc(id).snapshots().map((snapshot) {
      if (snapshot.data() == null) {
        SharedCode(context).handleAuthenticationRouting(
            logoutContext: context, isLogout: true);
      }
      return snapshot.data() == null
          ? null
          : UserModel.fromMap(
              snapshot.id, snapshot.data() as Map<String, dynamic>);
    });
  }

  @override
  Future<void> updateParent(UserModel model) async {
    await FirebaseAuth.instance.currentUser!.updateDisplayName(model.username);
    await FirebaseAuth.instance.currentUser!
        .updatePhotoURL(model.avatarUrl?.display);
    if (FirebaseAuth.instance.currentUser!.email == null) {
      await FirebaseAuth.instance.currentUser!.updateEmail(model.email);
    }
    return _db.collection('users').doc(model.id).update(model.toJson());
  }

  @override
  Future<void> addMomentToFavorite(String parentId, String momentId) {
    return _db.collection('users').doc(parentId).update({
      'favorites': FieldValue.arrayUnion([momentId])
    });
  }

  @override
  Future<void> removeMomentFromFavorite(String parentId, String momentId) {
    return _db.collection('users').doc(parentId).update({
      'favorites': FieldValue.arrayRemove([momentId])
    });
  }

  @override
  Future<void> addUserToPatronize(String userId, String parentId) {
    return _db.collection('users').doc(userId).update({
      'patronizeds': FieldValue.arrayUnion([parentId])
    });
  }

  @override
  Future<void> removeUserToPatronize(String userId, String parentId) {
    return _db.collection('users').doc(userId).update({
      'patronizeds': FieldValue.arrayRemove([parentId])
    });
  }

  Future<bool> checkIfParentUsernameValid(String username) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (user.displayName == username) {
        return true;
      }
    }

    QuerySnapshot snapshot = await _db
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return snapshot.docs.isEmpty;
  }

  Future<bool> checkIfEmailRegistered(String email) async {
    QuerySnapshot snapshot =
        await _db.collection('users').where('email', isEqualTo: email).get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  getListUserPatronized(List<String> patronizeds) async {
    if (patronizeds.isEmpty) {
      print('oe');
      return null;
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await _db
        .collection('users')
        .where(FieldPath.documentId, whereIn: patronizeds)
        .get();

    List<UserModel> result = snapshot.docs
        .map((snapshot) => UserModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    return result;
  }
}
