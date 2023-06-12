import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'avatar_model.dart';

class ChildModel extends Equatable {
  final String fullName;
  final AvatarModel avatarPath, avatarUrl;
  final DateTime birthday;
  final String? id, nickName;

  const ChildModel({
    this.id,
    required this.fullName,
    this.nickName,
    required this.birthday,
    required this.avatarUrl,
    required this.avatarPath,
  });

  factory ChildModel.fromMap(String id, Map<dynamic, dynamic> json) {
    AvatarModel avatarPath = AvatarModel.fromMap(json['avatarPath'] as Map<String, dynamic>);
    AvatarModel avatarUrl = AvatarModel.fromMap(json['avatarUrl'] as Map<String, dynamic>);

    Timestamp timestamp = json['birthday'] as Timestamp;
    return ChildModel(
      id: id,
      fullName: json['fullName'],
      nickName: json['nickName'],
      birthday: timestamp.toDate(),
      avatarUrl: avatarUrl,
      avatarPath: avatarPath,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'fullName': fullName,
      'nickName': nickName,
      'birthday': Timestamp.fromDate(birthday),
      'avatarUrl': avatarUrl.toJson(),
      'avatarPath': avatarPath.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id, fullName, nickName, birthday, avatarUrl, avatarPath];
}
