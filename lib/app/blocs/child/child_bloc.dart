import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../repositories/repositories.dart';
import '../../data/models/child_model.dart';

part 'child_event.dart';

part 'child_state.dart';

class ChildBloc extends Bloc<ChildEvent, ChildState> {
  final ChildRepository _childRepository;
  StreamSubscription? _childSubscription;

  ChildBloc({required ChildRepository repository})
      : _childRepository = repository,
        super(ChildLoading()) {
    on<LoadChildByParentId>(_onLoadChildById);
    on<UpdateChild>(_onUpdateChild);
  }

  void _onUpdateChild(
    UpdateChild event,
    Emitter<ChildState> emit,
  ) {
    if (isClosed) return;
    emit(ChildLoaded(children: event.children));
  }

  void _onLoadChildById(
    LoadChildByParentId event,
    Emitter<ChildState> emit,
  ) async {
    await _childSubscription?.cancel();
    _childSubscription = _childRepository.getChildrenByParentId(event.id).listen((child) {
      if (isClosed) return;
      add(UpdateChild(children: child));
    });
  }
}
