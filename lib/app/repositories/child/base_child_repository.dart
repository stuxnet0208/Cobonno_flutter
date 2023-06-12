import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../data/models/child_model.dart';

abstract class BaseChildRepository {
  Stream<List<ChildModel>> getChildrenByParentId(String id);
  Future<DocumentReference> addChild(String parentId, ChildModel model);
  Future<void> updateChild(String parentId, ChildModel oldModel, ChildModel model);
  Future<void> removeChild(String childId, BuildContext context);
}
