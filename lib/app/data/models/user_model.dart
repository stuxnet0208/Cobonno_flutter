import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import 'avatar_model.dart';

class UserModel extends Equatable {
  final String id, email;
  final String? phoneNumber;
  final String username;
  final String? description, invitationCode;
  final AvatarModel? avatarPath, avatarUrl;
  final List<String> favorites, momentsReported, patronizeds;
  final String role;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.favorites,
    required this.momentsReported,
    required this.patronizeds,
    this.role = 'user',
    this.phoneNumber,
    this.invitationCode,
    this.avatarUrl,
    this.avatarPath,
    this.description,
    this.updatedAt,
  });

  factory UserModel.fromMap(String id, Map<dynamic, dynamic> json) {
    DateTime updatedAt = DateTime.now();
    AvatarModel? avatarPath = json['avatarPath'] == null
        ? null
        : AvatarModel.fromMap(json['avatarPath'] as Map<String, dynamic>);
    AvatarModel? avatarUrl = json['avatarUrl'] == null
        ? null
        : AvatarModel.fromMap(json['avatarUrl'] as Map<String, dynamic>);
    List<String> patronizeds = json['patronizeds'] == null
        ? []
        : (json['patronizeds'] as List).map((item) => item as String).toList();
    List<String> favorites = json['favorites'] == null
        ? []
        : (json['favorites'] as List).map((item) => item as String).toList();
    List<String> momentsReported = json['momentsReported'] == null
        ? []
        : (json['momentsReported'] as List)
            .map((item) => item as String)
            .toList();
    if (json['updatedAt'] != null) {
      dynamic timestamp = json['updatedAt'];
      if (timestamp is Timestamp) {
        updatedAt = timestamp.toDate();
      }
    }
    return UserModel(
      id: id,
      email: json['email'],
      patronizeds: patronizeds,
      favorites: favorites,
      momentsReported: momentsReported,
      username: json['username'],
      invitationCode: json['invitationCode'],
      description: json['description'],
      phoneNumber: json['phoneNumber'],
      role: json['role'] ?? 'user',
      avatarUrl: avatarUrl,
      avatarPath: avatarPath,
      updatedAt: updatedAt
    );
  }

  Map<String, Object?> toJson() {
    return {
      'email': email,
      'username': username,
      'invitationCode': invitationCode,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl?.toJson(),
      'avatarPath': avatarPath?.toJson(),
      'description': description,
      'favorites': favorites,
      'patronizeds': patronizeds,
      'momentsReported': momentsReported,
      'role': role,
      'updatedAt': FieldValue.serverTimestamp()
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        username,
        phoneNumber,
        avatarUrl,
        avatarPath,
        favorites,
        patronizeds,
        description,
        invitationCode,
        role,
        momentsReported,
        updatedAt
      ];
}
