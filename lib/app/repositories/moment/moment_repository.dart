import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cobonno/app/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../data/models/moment_model.dart';
import 'base_moment_repository.dart';

class MomentRepository extends BaseMomentRepository {
  final FirebaseFirestore _db;
  QuerySnapshot<Map<String, dynamic>>? qsExpList,
      qsExpTile,
      qsParentList,
      qsParentTile,
      qsChildList,
      qsChildTile,
      qsPatronizeList,
      qsPatronizeTile,
      qsFavoriteList,
      qsFavoriteTile;
  QueryDocumentSnapshot<Map<String, dynamic>>? lastExpList,
      lastExpTile,
      lastParentList,
      lastMyParentList,
      lastParentTile,
      lastMyParentTile,
      lastChildList,
      lastMyChildList,
      lastChildTile,
      lastMyChildTile,
      lastPatronizeList,
      lastPatronizeTile,
      lastFavoriteList,
      lastFavoriteTile;
  List<MomentModel>? allExpList,
      allExpTile,
      allParentList,
      allMyParentList,
      allParentTile,
      allMyParentTile,
      allChildList,
      allMyChildList,
      allChildTile,
      allMyChildTile,
      allPatronizeList,
      allPatronizeTile,
      allFavoriteList,
      allFavoriteTile,
      firstFavList,
      firstFavTile;
  int indexFavList = 0,
      indexFavTile = 0,
      indexLengthList = 10,
      indexLengthTile = 10;

  MomentRepository({FirebaseFirestore? firebaseFirestore})
      : _db = firebaseFirestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<MomentModel>> getAllMoments() {
    return _db
        .collection('moments')
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<List<MomentModel>> fetchFirstListMoments(int limit) async {
    allExpList = [];
    qsExpList = await _db
        .collection('moments')
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    lastExpList = qsExpList!.docs[qsExpList!.docs.length - 1];
    List<MomentModel> result = qsExpList!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allExpList!.addAll(result);
    return allExpList!;
  }

  @override
  fetchNextListMoments(int limit) async {
    qsExpList = await _db
        .collection('moments')
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .startAfter([lastExpList!.get("date")])
        .limit(limit)
        .get();
    if (qsExpList!.docs.isNotEmpty) {
      lastExpList = qsExpList!.docs[qsExpList!.docs.length - 1];
      List<MomentModel> result = qsExpList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allExpList!.addAll(result);
      // print('add more data');
      return allExpList!;
    }
    // print('no more data');
    return null;
  }

  @override
  Future<List<MomentModel>> fetchFirstTileMoments(int limit) async {
    allExpTile = [];
    qsExpTile = await _db
        .collection('moments')
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    lastExpTile = qsExpTile!.docs[qsExpTile!.docs.length - 1];
    List<MomentModel> resultTile = qsExpTile!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allExpTile!.addAll(resultTile);
    return allExpTile!;
  }

  @override
  fetchNextTileMoments(int limit) async {
    qsExpTile = await _db
        .collection('moments')
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .startAfter([lastExpTile!.get("date")])
        .limit(limit)
        .get();
    if (qsExpTile!.docs.isNotEmpty) {
      lastExpTile = qsExpTile!.docs[qsExpTile!.docs.length - 1];
      List<MomentModel> resultTile = qsExpTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allExpTile!.addAll(resultTile);
      // print('add more data');
      return allExpTile!;
    }
    // print('no more data');
    return null;
  }

  @override
  firstMomentListByParentId(String id, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == id.trim();
    if (isCurrentUser) {
      allMyParentList = [];
      qsParentList = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      if (qsParentList!.docs.isEmpty) return null;

      lastMyParentList = qsParentList!.docs[qsParentList!.docs.length - 1];
      List<MomentModel> resultList = qsParentList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allMyParentList!.addAll(resultList);
      return allMyParentList!;
    } else {
      allParentList = [];
      qsParentList = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      lastParentList = qsParentList!.docs[qsParentList!.docs.length - 1];
      List<MomentModel> resultList = qsParentList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allParentList!.addAll(resultList);
      return allParentList!;
    }
  }

  @override
  nextListMomentByParentId(String id, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == id.trim();
    if (isCurrentUser) {
      qsParentList = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .orderBy('date', descending: true)
          .startAfter([lastMyParentList!.get("date")])
          .limit(limit)
          .get();
      if (qsParentList!.docs.isNotEmpty) {
        lastMyParentList = qsParentList!.docs[qsParentList!.docs.length - 1];
        List<MomentModel> resultList = qsParentList!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allMyParentList!.addAll(resultList);
        print('add more data usertrue');
        return allMyParentList!;
      }
      // print('no more data');
      return null;
    } else {
      qsParentList = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .startAfter([lastParentList!.get("date")])
          .limit(limit)
          .get();
      print(qsParentList!.docs.length);
      if (qsParentList!.docs.isNotEmpty) {
        lastParentList = qsParentList!.docs[qsParentList!.docs.length - 1];
        List<MomentModel> resultList = qsParentList!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allParentList!.addAll(resultList);
        print('add more data user falsee');
        return allParentList!;
      }
      // print('no more data');
      return null;
    }
  }

  @override
  firstMomentTileByParentId(String id, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == id.trim();

    if (isCurrentUser) {
      allMyParentTile = [];
      qsParentTile = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      if (qsParentTile!.docs.isEmpty) return null;

      lastMyParentTile = qsParentTile!.docs[qsParentTile!.docs.length - 1];
      List<MomentModel> resultTile = qsParentTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allMyParentTile!.addAll(resultTile);
      return allMyParentTile!;
    } else {
      allParentTile = [];
      qsParentTile = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      lastParentTile = qsParentTile!.docs[qsParentTile!.docs.length - 1];
      List<MomentModel> resultTile = qsParentTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allParentTile!.addAll(resultTile);
      return allParentTile!;
    }
  }

  @override
  nextTileMomentByParentId(String id, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == id.trim();
    if (isCurrentUser) {
      qsParentTile = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .orderBy('date', descending: true)
          .startAfter([lastMyParentTile!.get("date")])
          .limit(limit)
          .get();
      print(qsParentTile!.docs.length);
      if (qsParentTile!.docs.isNotEmpty) {
        lastMyParentTile = qsParentTile!.docs[qsParentTile!.docs.length - 1];
        List<MomentModel> resultTile = qsParentTile!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allMyParentTile!.addAll(resultTile);
        // print('add more data');
        return allMyParentTile!;
      }
      // print('no more data');
      return null;
    } else {
      qsParentTile = await _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .startAfter([lastParentTile!.get("date")])
          .limit(limit)
          .get();
      print(qsParentTile!.docs.length);
      if (qsParentTile!.docs.isNotEmpty) {
        lastParentTile = qsParentTile!.docs[qsParentTile!.docs.length - 1];
        List<MomentModel> resultList = qsParentTile!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allParentTile!.addAll(resultList);
        // print('add more data');
        return allParentTile!;
      }
      // print('no more data');
      return null;
    }
  }

  @override
  firstMomentListByChildId(String id, String parentId, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == parentId.trim();
    print("iscurrentuserrr" + isCurrentUser.toString());
    if (isCurrentUser) {
      allMyChildList = [];
      qsChildList = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      if (qsChildList!.docs.isEmpty) return null;

      lastMyChildList = qsChildList!.docs[qsChildList!.docs.length - 1];
      List<MomentModel> resultList = qsChildList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allMyChildList!.addAll(resultList);
      return allMyChildList!;
    } else {
      allChildList = [];
      qsChildList = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      lastChildList = qsChildList!.docs[qsChildList!.docs.length - 1];
      List<MomentModel> resultList = qsChildList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allChildList!.addAll(resultList);
      return allChildList!;
    }
  }

  @override
  nextMomentListByChildId(String id, String parentId, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == parentId.trim();
    if (isCurrentUser) {
      qsChildList = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .orderBy('date', descending: true)
          .startAfter([lastMyChildList!.get("date")])
          .limit(limit)
          .get();
      if (qsChildList!.docs.isNotEmpty) {
        lastMyChildList = qsChildList!.docs[qsChildList!.docs.length - 1];
        List<MomentModel> resultList = qsChildList!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allMyChildList!.addAll(resultList);
        print('add more data usertrue');
        return allMyChildList!;
      }
      // print('no more data');
      return null;
    } else {
      qsChildList = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .startAfter([lastChildList!.get("date")])
          .limit(limit)
          .get();
      print(qsChildList!.docs.length);
      if (qsChildList!.docs.isNotEmpty) {
        lastChildList = qsChildList!.docs[qsChildList!.docs.length - 1];
        List<MomentModel> resultList = qsChildList!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allChildList!.addAll(resultList);
        print('add more data user falsee');
        return allChildList!;
      }
      // print('no more data');
      return null;
    }
  }

  @override
  firstMomentTileByChildId(String id, String parentId, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == parentId.trim();
    if (isCurrentUser) {
      allMyChildTile = [];
      qsChildTile = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      if (qsChildTile!.docs.isEmpty) return null;

      lastMyChildTile = qsChildTile!.docs[qsChildTile!.docs.length - 1];
      List<MomentModel> resultTile = qsChildTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allMyChildTile!.addAll(resultTile);
      return allMyChildTile!;
    } else {
      allChildTile = [];
      qsChildTile = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .limit(limit)
          .get();
      lastChildTile = qsChildTile!.docs[qsChildTile!.docs.length - 1];
      List<MomentModel> resultTile = qsChildTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allChildTile!.addAll(resultTile);
      return allChildTile!;
    }
  }

  @override
  nextMomentTileByChildId(String id, String parentId, int limit) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == parentId.trim();
    if (isCurrentUser) {
      qsChildTile = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .orderBy('date', descending: true)
          .startAfter([lastMyChildTile!.get("date")])
          .limit(limit)
          .get();
      if (qsChildTile!.docs.isNotEmpty) {
        lastMyChildTile = qsChildTile!.docs[qsChildTile!.docs.length - 1];
        List<MomentModel> resultList = qsChildTile!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allMyChildTile!.addAll(resultList);
        print('add more data usertrue');
        return allMyChildTile!;
      }
      // print('no more data');
      return null;
    } else {
      qsChildTile = await _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .startAfter([lastChildTile!.get("date")])
          .limit(limit)
          .get();
      print(qsChildTile!.docs.length);
      if (qsChildTile!.docs.isNotEmpty) {
        lastChildTile = qsChildTile!.docs[qsChildTile!.docs.length - 1];
        List<MomentModel> resultList = qsChildTile!.docs
            .map(
                (snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
            .toList();
        allChildTile!.addAll(resultList);
        print('add more data user falsee');
        return allChildTile!;
      }
      // print('no more data');
      return null;
    }
  }

  @override
  Future<List<MomentModel>> getMomentByDocId(String id) async {
    var qs = await _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: [id]).get();
    List<MomentModel> result = qs.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    print(result.length);
    return result;
  }

  @override
  Stream<List<MomentModel>> getMomentByChildId(String id, String parentId) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == parentId.trim();
    if (isCurrentUser) {
      return _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
                .toList();
          });
    } else {
      return _db
          .collection('moments')
          .where('childIds', arrayContainsAny: [id])
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
                .toList();
          });
    }
  }

  @override
  Stream<List<MomentModel>> getMomentByParentId(String id) {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    bool isCurrentUser = currentUserId.trim() == id.trim();
    if (isCurrentUser) {
      return _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
            .toList();
      });
    } else {
      return _db
          .collection('moments')
          .where('parentId', isEqualTo: id)
          .where('isPrivate', isEqualTo: false)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
            .toList();
      });
    }
  }

  @override
  Stream<List<MomentModel>> getFavoriteMoments(List<String> favorites) {
    return _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: favorites)
        .where('isPrivate', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<MomentModel>> getMyFavoriteMoments(
      String parentId, List<String> favorites) {
    return _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: favorites)
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<MomentModel>> getPatronizeMoments(List<String> patronizeds) {
    return _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Stream<List<MomentModel>> getMyPatronizeMoments(
      String parentId, List<String> patronizeds) {
    return _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('parentId', isEqualTo: parentId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  @override
  Future<List<MomentModel>> firstPatronizeListMoments(
      List<String> patronizeds, int limit) async {
    allPatronizeList = [];
    qsPatronizeList = await _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    lastPatronizeList = qsPatronizeList!.docs[qsPatronizeList!.docs.length - 1];
    List<MomentModel> result = qsPatronizeList!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allPatronizeList!.addAll(result);
    return allPatronizeList!;
  }

  @override
  nextPatronizeListMoments(List<String> patronizeds, int limit) async {
    qsPatronizeList = await _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .startAfter([lastPatronizeList!.get("date")])
        .limit(limit)
        .get();
    if (qsPatronizeList!.docs.isNotEmpty) {
      lastPatronizeList =
          qsPatronizeList!.docs[qsPatronizeList!.docs.length - 1];
      List<MomentModel> resultList = qsPatronizeList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allPatronizeList!.addAll(resultList);
      // print('add more data');
      return allPatronizeList!;
    }
    // print('no more data');
    return null;
  }

  @override
  Future<List<MomentModel>> firstPatronizeTileMoments(
      List<String> patronizeds, int limit) async {
    allPatronizeTile = [];
    qsPatronizeTile = await _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .limit(limit)
        .get();
    lastPatronizeTile = qsPatronizeTile!.docs[qsPatronizeTile!.docs.length - 1];
    List<MomentModel> result = qsPatronizeTile!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allPatronizeTile!.addAll(result);
    return allPatronizeTile!;
  }

  @override
  nextPatronizeTileMoments(List<String> patronizeds, int limit) async {
    qsPatronizeTile = await _db
        .collection('moments')
        .where('parentId', whereIn: patronizeds)
        .where('isPrivate', isEqualTo: false)
        .orderBy('date', descending: true)
        .startAfter([lastPatronizeTile!.get("date")])
        .limit(limit)
        .get();
    if (qsPatronizeTile!.docs.isNotEmpty) {
      lastPatronizeList =
          qsPatronizeTile!.docs[qsPatronizeTile!.docs.length - 1];
      List<MomentModel> resultTile = qsPatronizeTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allPatronizeTile!.addAll(resultTile);
      // print('add more data');
      return allPatronizeTile!;
    }
    // print('no more data');
    return null;
  }

  @override
  Future<List<MomentModel>> firstFavoriteListMoments(
      List<String> favorites, int limit) async {
    allFavoriteList = [];
    List<String> tempList = [];
    List<List<String>> favoriteResult = [];
    if (favorites.length >= 10) {
      for (int i = indexFavList; i < indexLengthList; i++) {
        tempList.add(favorites[i]);
      }
    }
    // print("favorites: ${favoriteResult[0]}");
    qsFavoriteList = await _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: tempList)
        .orderBy(FieldPath.documentId)
        .limit(10)
        .get();
    lastFavoriteList = qsFavoriteList!.docs[qsFavoriteList!.docs.length - 1];
    List<MomentModel> resultList = qsFavoriteList!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allFavoriteList!.addAll(resultList);
    return allFavoriteList!;
  }

  @override
  nextFavoriteListMoments(List<String> favorites, int limit) async {
    qsFavoriteList = await _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: favorites)
        .orderBy(FieldPath.documentId)
        .startAfter([lastFavoriteList!.get(FieldPath.documentId.name)])
        .limit(10)
        .get();
    if (qsFavoriteList!.docs.isNotEmpty) {
      lastFavoriteList = qsFavoriteList!.docs[qsFavoriteList!.docs.length - 1];
      List<MomentModel> resultList = qsFavoriteList!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allFavoriteList!.addAll(resultList);
      // print('add more data');
      return allFavoriteList!;
    }
    // print('no more data');
    return null;
  }

  @override
  Future<List<MomentModel>> firstFavoriteTileMoments(
      List<String> favorites, int limit) async {
    allFavoriteTile = [];
    List<String> tempList = [];
    List<List<String>> favoriteResult = [];
    int indexFav = 0;
    for (int i = 0; i < 10; i++) {
      tempList.add(favorites[i]);
      // if (i == 9) {
      //   favoriteResult[indexFav].addAll(tempList);
      //   indexFav++;
      // }
    }
    // print("favorites: ${favoriteResult[0]}");
    qsFavoriteTile = await _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: tempList)
        .orderBy(FieldPath.documentId)
        .limit(10)
        .get();
    lastFavoriteTile = qsFavoriteTile!.docs[qsFavoriteTile!.docs.length - 1];
    List<MomentModel> resultTile = qsFavoriteTile!.docs
        .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
        .toList();
    allFavoriteTile!.addAll(resultTile);
    return allFavoriteTile!;
  }

  @override
  nextFavoriteTileMoments(List<String> favorites, int limit) async {
    qsFavoriteTile = await _db
        .collection('moments')
        .where(FieldPath.documentId, whereIn: favorites)
        .orderBy(FieldPath.documentId)
        .startAfter([lastFavoriteTile!.get("date")])
        .limit(10)
        .get();
    if (qsFavoriteTile!.docs.isNotEmpty) {
      lastFavoriteList = qsFavoriteTile!.docs[qsFavoriteTile!.docs.length - 1];
      List<MomentModel> resultTile = qsFavoriteTile!.docs
          .map((snapshot) => MomentModel.fromMap(snapshot.id, snapshot.data()))
          .toList();
      allFavoriteTile!.addAll(resultTile);
      // print('add more data');
      return allFavoriteTile!;
    }
    // print('no more data');
    return null;
  }

  @override
  Future<void> addUserReaction(
      String momentId, String reactionName, String parentId) async {
    await _db.collection('moments').doc(momentId).update({
      'reactions.$reactionName': FieldValue.arrayUnion([parentId])
    });
  }

  @override
  Future<void> removeUserReaction(
      String momentId, String reactionName, String parentId) async {
    await _db.collection('moments').doc(momentId).update({
      'reactions.$reactionName': FieldValue.arrayRemove([parentId])
    });
  }

  @override
  Stream<List<MomentModel>> getMomentsByTag(String tag) {
    return _db
        .collection('moments')
        .where('keywords', arrayContainsAny: [tag])
        .where('isPrivate', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MomentModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  @override
  Stream<MomentModel> getMomentById(String momentId) {
    return _db.collection('moments').doc(momentId).snapshots().map((snapshot) =>
        MomentModel.fromMap(
            snapshot.id, snapshot.data() as Map<String, dynamic>));
  }

  @override
  Future<DocumentReference<Object?>> addMoment(MomentModel model) {
    Map<String, Object?> json = model.toJson();
    json['createdAt'] = FieldValue.serverTimestamp();
    return _db.collection('moments').add(json);
  }

  @override
  Future<void> updateMoment(MomentModel model) {
    return _db.collection('moments').doc(model.id).update(model.toJson());
  }

  @override
  Future<void> deleteMoment(BuildContext context, String momentId) async {
    bool isProduction = MyApp.getIsProduction(context);
    HttpsCallable callable = FirebaseFunctions.instanceFor(
            region: isProduction ? 'asia-northeast1' : 'asia-east2')
        .httpsCallable('deleteMoment');
    dynamic results = await callable.call(<String, dynamic>{
      'momentId': momentId,
    });
    final data = results.data as Map<String, dynamic>;
    if (!data['success']) throw data;
  }

  @override
  Future<void> deleteMomentAdmin(
      BuildContext context, String momentId, String reason) async {
    bool isProduction = MyApp.getIsProduction(context);
    HttpsCallable callable = FirebaseFunctions.instanceFor(
            region: isProduction ? 'asia-northeast1' : 'asia-east2')
        .httpsCallable('deleteMoment');
    dynamic results = await callable.call(<String, dynamic>{
      'momentId': momentId,
      'reason': reason,
    });
    //debugPrint('delete moment admin $momentId $reason');
    final data = results.data as Map<String, dynamic>;
    //debugPrint('delete moment admin $data');
    if (!data['success']) throw data;
  }

  @override
  Future<void> reportMoment(
      BuildContext context, String momentId, String reason) async {
    bool isProduction = MyApp.getIsProduction(context);
    HttpsCallable callable = FirebaseFunctions.instanceFor(
            region: isProduction ? 'asia-northeast1' : 'asia-east2')
        .httpsCallable('reportMoment');
    dynamic results = await callable.call(<String, dynamic>{
      'momentId': momentId,
      'reason': reason,
    });
    //debugPrint("moment reported $momentId");
    final data = results.data as Map<String, dynamic>;
    if (!data['success']) throw data;
  }
}
