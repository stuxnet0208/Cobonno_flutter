part of 'parent_bloc.dart';

abstract class ParentEvent extends Equatable {
  const ParentEvent();

  @override
  List<Object> get props => [];
}

class LoadParentById extends ParentEvent {
  final String id;
  final BuildContext context;

  const LoadParentById({required this.id, required this.context});

  @override
  List<Object> get props => [id, context];
}

class LoadParentListByPatronize extends ParentEvent {
  final List<String> patronizeds;

  const LoadParentListByPatronize({required this.patronizeds});

  @override
  List<Object> get props => [patronizeds];
}

class UpdateParent extends ParentEvent {
  final UserModel parent;

  const UpdateParent({required this.parent});

  @override
  List<Object> get props => [parent];
}
