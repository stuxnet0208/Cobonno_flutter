part of 'child_bloc.dart';

abstract class ChildState extends Equatable {
  const ChildState();
  @override
  List<Object> get props => [];
}

class ChildLoading extends ChildState {}

class ChildLoaded extends ChildState {
  final List<ChildModel> children;

  const ChildLoaded({required this.children});

  @override
  List<Object> get props => [children];
}
