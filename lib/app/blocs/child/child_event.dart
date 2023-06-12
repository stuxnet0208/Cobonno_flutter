part of 'child_bloc.dart';

abstract class ChildEvent extends Equatable {
  const ChildEvent();

  @override
  List<Object> get props => [];
}

class LoadChildByParentId extends ChildEvent {
  final String id;

  const LoadChildByParentId({required this.id});

  @override
  List<Object> get props => [id];
}

class LoadChildById extends ChildEvent {
  final String id;

  const LoadChildById({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateChild extends ChildEvent {
  final List<ChildModel> children;

  const UpdateChild({required this.children});

  @override
  List<Object> get props => [children];
}
