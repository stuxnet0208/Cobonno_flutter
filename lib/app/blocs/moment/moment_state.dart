part of 'moment_bloc.dart';

abstract class MomentState extends Equatable {
  const MomentState();

  @override
  List<Object> get props => [];
}

class MomentLoading extends MomentState {}

class MomentFetchLoading extends MomentState {}

class MomentListLoaded extends MomentState {
  final List<MomentModel> moments;

  const MomentListLoaded({this.moments = const <MomentModel>[]});
  @override
  List<Object> get props => [moments];
}

class MomentTileLoaded extends MomentState {
  final List<MomentModel> moments;

  const MomentTileLoaded({this.moments = const <MomentModel>[]});
  @override
  List<Object> get props => [moments];
}

class MomentLoaded extends MomentState {
  final List<MomentModel> moments;

  const MomentLoaded({this.moments = const <MomentModel>[]});
  @override
  List<Object> get props => [moments];
}

class MyMomentListLoaded extends MomentState {
  final List<MomentModel> moments;

  const MyMomentListLoaded({this.moments = const <MomentModel>[]});

  @override
  List<Object> get props => [moments];
}

class MyMomentTileLoaded extends MomentState {
  final List<MomentModel> moments;

  const MyMomentTileLoaded({this.moments = const <MomentModel>[]});

  @override
  List<Object> get props => [moments];
}

class MyMomentLoaded extends MomentState {
  final List<MomentModel> moments;

  const MyMomentLoaded({this.moments = const <MomentModel>[]});

  @override
  List<Object> get props => [moments];
}
