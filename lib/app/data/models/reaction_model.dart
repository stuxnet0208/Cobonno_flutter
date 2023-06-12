import 'package:equatable/equatable.dart';

class ReactionModel extends Equatable {
  final List<String> spark, thumb, lol, wow, love, clap;

  const ReactionModel(
      {required this.spark,
      required this.thumb,
      required this.lol,
      required this.wow,
      required this.clap,
      required this.love});

  factory ReactionModel.fromMap(Map<dynamic, dynamic> json) {
    List<String> sparks =
        (json['spark'] == null ? [] : json['spark'] as List).map((item) => item as String).toList();
    List<String> thumbs =
        (json['thumb'] == null ? [] : json['thumb'] as List).map((item) => item as String).toList();
    List<String> lols =
        (json['lol'] == null ? [] : json['lol'] as List).map((item) => item as String).toList();
    List<String> wows =
        (json['wow'] == null ? [] : json['wow'] as List).map((item) => item as String).toList();
    List<String> claps =
        (json['clap'] == null ? [] : json['clap'] as List).map((item) => item as String).toList();
    List<String> loves =
        (json['love'] == null ? [] : json['love'] as List).map((item) => item as String).toList();

    return ReactionModel(
      spark: sparks,
      thumb: thumbs,
      lol: lols,
      wow: wows,
      clap: claps,
      love: loves,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'spark': spark,
      'thumb': thumb,
      'lol': lol,
      'wow': wow,
      'clap': clap,
      'love': love,
    };
  }

  @override
  List<Object?> get props => [spark, thumb, lol, wow, clap, love];
}
