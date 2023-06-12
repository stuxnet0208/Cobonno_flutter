part of 'parent_bloc.dart';

abstract class ParentState extends Equatable {
  const ParentState();

  @override
  List<Object> get props => [];
}

class ParentLoading extends ParentState {}

class ParentLoaded extends ParentState {
  final UserModel parent;

  const ParentLoaded({required this.parent});

  @override
  List<Object> get props => [parent];
}

class ParentListLoaded extends ParentState {
  final List<UserModel> parentList;

  const ParentListLoaded({required this.parentList});

  @override
  List<Object> get props => [parentList];
}
