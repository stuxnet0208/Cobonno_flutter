import 'package:equatable/equatable.dart';

class AvatarModel extends Equatable {
  final String display, original, thumb128, thumb256;

  const AvatarModel({
    required this.display,
    required this.original,
    required this.thumb128,
    required this.thumb256,
  });

  factory AvatarModel.fromMap(Map<dynamic, dynamic> json) {
    return AvatarModel(
      display: json['display'] ?? '',
      original: json['original'] ?? '',
      thumb128: json['thumb128'] ?? '',
      thumb256: json['thumb256'] ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'display': display,
      'original': original,
      'thumb128': thumb128,
      'thumb256': thumb256,
    };
  }

  @override
  List<Object?> get props => [display, original, thumb128, thumb256];
}
