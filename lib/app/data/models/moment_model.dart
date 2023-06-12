import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'photo_model.dart';
import 'reaction_model.dart';

class MomentModel extends Equatable {
  final String id, caption, parentId, forType;
  final String? title, documentId;
  final DateTime? createdAt, date;
  final List<String> childIds;
  final List<PhotoModel> photos;
  final List<String>? keywords;
  final bool isPrivate, isReported;
  bool isShowReaction;
  final ReactionModel reaction;

  MomentModel(
      {required this.id,
      required this.caption,
      required this.childIds,
      required this.parentId,
      required this.isPrivate,
      required this.isReported,
      required this.photos,
      required this.reaction,
      required this.forType,
      this.documentId,
      this.date,
      this.title,
      this.isShowReaction = false,
      this.createdAt,
      this.keywords});

  factory MomentModel.fromMap(String id, Map<dynamic, dynamic> json) {
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      dynamic timestamp = json['createdAt'];
      if (timestamp is Timestamp) {
        createdAt = timestamp.toDate();
      }
    }

    DateTime date = DateTime.now();
    if (json['date'] != null) {
      dynamic timestamp = json['date'];
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      }
    }

    List<String>? keywords =
        (json['keywords'] as List).map((item) => item as String).toList();

    List<String>? childIds =
        (json['childIds'] as List).map((item) => item as String).toList();

    List<PhotoModel> photos = (json['photos'] as List)
        .map((item) => PhotoModel.fromMap(item as Map<String, dynamic>))
        .toList();

    String parentId = json['parentId'];

    return MomentModel(
        id: id,
        documentId: json[FieldPath.documentId.toString()],
        forType: json['for'],
        caption: json['caption'],
        childIds: childIds,
        parentId: parentId,
        title: json['title'],
        keywords: keywords,
        createdAt: createdAt,
        date: date,
        isPrivate: json['isPrivate'] ?? false,
        isReported: json['isReported'] ?? false,
        photos: photos,
        reaction: ReactionModel.fromMap(json['reactions']));
  }

  Map<String, Object?> toJson() {
    return {
      'documentId': documentId,
      'caption': caption,
      'childIds': childIds,
      'for': forType,
      'date': date,
      'parentId': parentId,
      'title': title,
      'keywords': keywords,
      'isPrivate': isPrivate,
      'isReported': isReported,
      'photos': photos.map((e) => e.toJson()).toList(),
      'reactions': reaction.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        documentId,
        id,
        caption,
        childIds,
        title,
        parentId,
        isPrivate,
        keywords,
        photos,
        reaction,
        forType,
        isReported
      ];
}
