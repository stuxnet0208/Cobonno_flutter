import 'package:equatable/equatable.dart';

class PhotoPathModel extends Equatable {
  final String listView, original, tileview;

  const PhotoPathModel({required this.listView, required this.original, required this.tileview});

  factory PhotoPathModel.fromMap(Map<dynamic, dynamic> json) {
    return PhotoPathModel(
      listView: json['listview'],
      original: json['original'],
      tileview: json['tileview'],
    );
  }

  Map<String, Object?> toJson() {
    return {
      'listview': listView,
      'original': original,
      'tileview': tileview,
    };
  }

  @override
  List<Object?> get props => [listView, original, tileview];
}
