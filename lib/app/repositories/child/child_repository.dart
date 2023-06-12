import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cobonno/app/app.dart';
import 'package:flutter/material.dart';

import '../../data/models/child_model.dart';
import 'base_child_repository.dart';

class ChildRepository extends BaseChildRepository {
  final FirebaseFirestore _db;

  ChildRepository({FirebaseFirestore? firebaseFirestore})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChildModel>> getChildrenByParentId(String id) {
    return _db
        .collection('users')
        .doc(id)
        .collection('children')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChildModel.fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<DocumentReference> addChild(String parentId, ChildModel model) {
    Map<String, Object?> json = model.toJson();
    json['createdAt'] = FieldValue.serverTimestamp();
    return _db.collection('users').doc(parentId).collection('children').add(json);
  }

  @override
  Future<void> updateChild(String parentId, ChildModel oldModel, ChildModel model) {
    return _db
        .collection('users')
        .doc(parentId)
        .collection('children')
        .doc(oldModel.id)
        .update(model.toJson());
  }

  @override
  Future<void> removeChild(String childId, BuildContext context) async {
    bool isProduction = MyApp.getIsProduction(context);
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: isProduction ? 'asia-northeast1' : 'asia-east2')
            .httpsCallable('deleteChild');
    dynamic results = await callable.call(<String, dynamic>{
      'childId': childId,
    });
    final data =
        results.data as Map<String, dynamic>; // { success: true, childId: childId, uid: uid }
    if (!data['success']) throw data;
  }
}
