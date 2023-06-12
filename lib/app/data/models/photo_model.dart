import 'package:equatable/equatable.dart';

import 'photo_path_model.dart';

class PhotoModel extends Equatable {
  final PhotoPathModel photoPathModel, photoUrlModel;

  const PhotoModel({required this.photoPathModel, required this.photoUrlModel});

  factory PhotoModel.fromMap(Map<dynamic, dynamic> json) {
    PhotoPathModel photoPathModel =
        PhotoPathModel.fromMap(json['photoPath'] as Map<String, dynamic>);
    PhotoPathModel photoUrlModel = PhotoPathModel.fromMap(json['photoUrl'] as Map<String, dynamic>);

    return PhotoModel(
      photoPathModel: photoPathModel,
      photoUrlModel: photoUrlModel,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'photoPath': photoPathModel.toJson(),
      'photoUrl': photoUrlModel.toJson(),
    };
  }

  @override
  List<Object?> get props => [photoPathModel, photoUrlModel];
}
