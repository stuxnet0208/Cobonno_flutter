import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';
import '../../repositories/repositories.dart';

part 'parent_event.dart';
part 'parent_state.dart';

class ParentBloc extends Bloc<ParentEvent, ParentState> {
  final ParentRepository _parentRepository;
  StreamSubscription? _parentSubscription;

  ParentBloc({required ParentRepository repository})
      : _parentRepository = repository,
        super(ParentLoading()) {
    on<LoadParentById>(_onLoadParentById);
    on<LoadParentListByPatronize>(_onLoadParentListByPatronize);
    on<UpdateParent>(_onUpdateParent);
  }

  void _onUpdateParent(
    UpdateParent event,
    Emitter<ParentState> emit,
  ) async {
    if (isClosed) return;
    emit(ParentLoaded(parent: event.parent));
  }

  void _onLoadParentListByPatronize(
    LoadParentListByPatronize event,
    Emitter<ParentState> emit,
  ) async {
    emit(ParentLoading());
    var listParents =
        await _parentRepository.getListUserPatronized(event.patronizeds);
    emit(ParentListLoaded(parentList: listParents ?? []));
  }

  void _onLoadParentById(
    LoadParentById event,
    Emitter<ParentState> emit,
  ) async {
    await _parentSubscription?.cancel();
    // ignore: use_build_context_synchronously
    _parentSubscription = _parentRepository
        .getParentById(event.id, event.context)
        .listen((parent) {
      if (isClosed) return;
      add(UpdateParent(
          parent: parent ??
              const UserModel(
                id: 'null',
                email: 'email',
                username: 'username',
                favorites: [],
                patronizeds: [],
                momentsReported: [],
              )));
    });
  }
}
