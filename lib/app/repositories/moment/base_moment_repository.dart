import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cobonno/app/blocs/blocs.dart';
import 'package:flutter/material.dart';

import '../../data/models/moment_model.dart';

abstract class BaseMomentRepository {
  Stream<List<MomentModel>> getAllMoments();
  Future<List<MomentModel>> fetchFirstListMoments(int limit);
  fetchNextListMoments(int limit);
  Future<List<MomentModel>> fetchFirstTileMoments(int limit);
  fetchNextTileMoments(int limit);

  firstMomentListByParentId(String id, int limit);
  nextListMomentByParentId(String id, int limit);
  firstMomentTileByParentId(String id, int limit);
  nextTileMomentByParentId(String id, int limit);

  firstMomentListByChildId(String id, String parentId, int limit);
  nextMomentListByChildId(String id, String parentId, int limit);
  firstMomentTileByChildId(String id, String parentId, int limit);
  nextMomentTileByChildId(String id, String parentId, int limit);

  Future<List<MomentModel>> getMomentByDocId(String id);

  Stream<List<MomentModel>> getMomentByChildId(String id, String parentId);
  Stream<List<MomentModel>> getMomentByParentId(String id);
  Stream<List<MomentModel>> getFavoriteMoments(List<String> favorites);
  Stream<List<MomentModel>> getMyFavoriteMoments(
      String parentId, List<String> favorites);

  Future<List<MomentModel>> firstPatronizeListMoments(
      List<String> patronizeds, int limit);
  nextPatronizeListMoments(List<String> patronizeds, int limit);
  Future<List<MomentModel>> firstPatronizeTileMoments(
      List<String> patronizeds, int limit);
  nextPatronizeTileMoments(List<String> patronizeds, int limit);

  Future<List<MomentModel>> firstFavoriteListMoments(
      List<String> favorites, int limit);
  nextFavoriteListMoments(List<String> favorites, int limit);
  Future<List<MomentModel>> firstFavoriteTileMoments(
      List<String> favorites, int limit);
  nextFavoriteTileMoments(List<String> favorites, int limit);

  Stream<List<MomentModel>> getPatronizeMoments(List<String> patronizeds);
  Stream<List<MomentModel>> getMyPatronizeMoments(
      String parentId, List<String> patronizeds);
  Stream<List<MomentModel>> getMomentsByTag(String tag);
  Stream<MomentModel> getMomentById(String momentId);
  Future<void> addUserReaction(
      String momentId, String reactionName, String parentId);
  Future<void> removeUserReaction(
      String momentId, String reactionName, String parentId);
  Future<DocumentReference> addMoment(MomentModel model);
  Future<void> updateMoment(MomentModel model);
  Future<void> reportMoment(
      BuildContext context, String momentId, String reason);
  Future<void> deleteMoment(BuildContext context, String momentId);
  Future<void> deleteMomentAdmin(
      BuildContext context, String momentId, String reason);
}
