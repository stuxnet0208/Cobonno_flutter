import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

abstract class BaseParentRepository {
  Stream<UserModel?> getParentById(String id, BuildContext context);
  Future<void> updateParent(UserModel model);
  Future<void> addMomentToFavorite(String parentId, String momentId);
  Future<void> removeMomentFromFavorite(String parentId, String momentId);
  Future<void> addUserToPatronize(String userId, String parentId);
  Future<void> removeUserToPatronize(String userId, String parentId);
  getListUserPatronized(List<String> patronizeds);
}
