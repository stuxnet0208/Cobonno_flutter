import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class DatabaseService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser(UserModel model) async {
    try {
      Map<String, Object?> json = model.toJson();
      json['createdAt'] = FieldValue.serverTimestamp();
      await users.doc(model.id).set(json);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> setUserPhone(String id, String phoneNumber) async {
    try {
      await users.doc(id).update({'phoneNumber': phoneNumber});
    } catch (e) {
      throw e.toString();
    }
  }

  Future<UserModel> getUserById(String id) async {
    DocumentSnapshot snapshot = await users.doc(id).get();
    return UserModel.fromMap(snapshot.id, snapshot.data() as Map<String, dynamic>);
  }
}
