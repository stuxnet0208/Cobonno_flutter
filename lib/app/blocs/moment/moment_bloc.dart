import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/moment_model.dart';
import '../../repositories/moment/moment_repository.dart';

part 'moment_event.dart';

part 'moment_state.dart';

class MomentBloc extends Bloc<MomentEvent, MomentState> {
  final MomentRepository _momentRepository;
  StreamSubscription? _momentSubscription;
  StreamSubscription? _mySubscription;

  MomentBloc({required MomentRepository momentRepository})
      : _momentRepository = momentRepository,
        super(MomentLoading()) {
    on<LoadAllMoments>(_onLoadMoments);
    on<FetchFirstListMoments>(_onFirstListMoments);
    on<FetchNextListMoments>(_onFetchListMoments);
    on<FetchFirstTileMoments>(_onFirstTileMoments);
    on<FetchNextTileMoments>(_onFetchTileMoments);

    on<FirstListMomentsByParentId>(_onFirstListMomentsByParentId);
    on<NextListMomentsByParentId>(_onNextListMomentsByParentId);
    on<FirstTileMomentsByParentId>(_onFirstTileMomentsByParentId);
    on<NextTileMomentsByParentId>(_onNextTileMomentsByParentId);

    on<FirstListMomentsByChildId>(_onFirstListMomentsByChildId);
    on<NextListMomentsByChildId>(_onNextListMomentsByChildId);
    on<FirstTileMomentsByChildId>(_onFirstTileMomentsByChildId);
    on<NextTileMomentsByChildId>(_onNextTileMomentsByChildId);

    on<LoadMomentByChildId>(_onLoadMomentsByChildId);
    on<LoadMomentByParentId>(_onLoadMomentsByParentId);
    on<LoadFavoriteMoments>(_onLoadFavoriteMoments);
    on<LoadFavoriteMomentsByParentId>(_onLoadFavoriteMomentsByParentId);
    on<LoadPatronizeMoments>(_onLoadPatronizeMoments);

    on<FirstPatronizeListMoments>(_onFirstPatronizeListMoments);
    on<NextPatronizeListMoments>(_onNextPatronizeListMoments);
    on<FirstPatronizeTileMoments>(_onFirstPatronizeTileMoments);
    on<NextPatronizeTileMoments>(_onNextPatronizeTileMoments);

    on<FirstFavoriteListMoments>(_onFirstFavoriteListMoments);
    on<NextFavoriteListMoments>(_onNextFavoriteListMoments);
    on<FirstFavoriteTileMoments>(_onFirstFavoriteTileMoments);
    on<NextFavoriteTileMoments>(_onNextFavoriteTileMoments);

    on<LoadMomentByDocId>(_onLoadMomentByDocId);

    on<LoadPatronizeMomentsByParentId>(_onLoadPatronizeMomentsByParentId);
    on<LoadMomentsByTag>(_onLoadMomentsByTag);
    on<LoadMomentById>(_onLoadMomentById);
    on<UpdateMoments>(_onUpdateMoments);
    on<UpdateListMoments>(_onUpdateListMoments);
    on<UpdateTileMoments>(_onUpdateTileMoments);
  }

  void _onUpdateMoments(
    UpdateMoments event,
    Emitter<MomentState> emit,
  ) {
    if (isClosed) return;
    if (event.isMyMoment) {
      emit(MyMomentLoaded(moments: event.moments));
    } else {
      emit(MomentLoaded(moments: event.moments));
    }
  }

  void _onUpdateListMoments(
    UpdateListMoments event,
    Emitter<MomentState> emit,
  ) {
    if (isClosed) return;
    if (event.isMyMoment) {
      emit(MyMomentListLoaded(moments: event.moments));
    } else {
      emit(MomentListLoaded(moments: event.moments));
    }
  }

  void _onUpdateTileMoments(
    UpdateTileMoments event,
    Emitter<MomentState> emit,
  ) {
    if (isClosed) return;
    if (event.isMyMoment) {
      emit(MyMomentTileLoaded(moments: event.moments));
    } else {
      emit(MomentTileLoaded(moments: event.moments));
    }
  }

  void _onLoadMoments(
    LoadAllMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription = _momentRepository.getAllMoments().listen(
      (moments) {
        // remove moment that has the same parent id as user because in explore we only want to show
        // other user's moments, we can't do it in moment_repository because it'll produce inequality error
        // (can't query isNotEqual with orderBy date)
        // update: as azetsu san requested, we should also see user owns public moment
        //         check https://app.clickup.com/t/2uvrpyd
        // moments.removeWhere((element) => element.parentId == FirebaseAuth.instance.currentUser!.uid);
        if (isClosed) return;
        add(UpdateMoments(moments: moments));
        add(UpdateMoments(moments: moments));
      },
    );
  }

  void _onFirstListMoments(
    FetchFirstListMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.fetchFirstListMoments(event.limit);
    if (isClosed) return;
    add(UpdateListMoments(moments: moments));
    add(UpdateListMoments(moments: moments));
  }

  void _onFetchListMoments(
    FetchNextListMoments event,
    Emitter<MomentState> emit,
  ) async {
    // await _momentSubscription?.cancel();
    var moments = await _momentRepository.fetchNextListMoments(event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
      add(UpdateListMoments(moments: moments));
    }
  }

  void _onFirstTileMoments(
    FetchFirstTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.fetchFirstTileMoments(event.limit);
    if (isClosed) return;
    add(UpdateTileMoments(moments: moments));
    add(UpdateTileMoments(moments: moments));
  }

  void _onFetchTileMoments(
    FetchNextTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    // await _momentSubscription?.cancel();
    var moments = await _momentRepository.fetchNextTileMoments(event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateTileMoments(moments: moments));
      add(UpdateTileMoments(moments: moments));
    }
  }

  void _onFirstListMomentsByParentId(
    FirstListMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstMomentListByParentId(
        event.parentId, event.limit);
    if (isClosed) return;

    if (moments != null) add(UpdateListMoments(moments: moments));
  }

  void _onNextListMomentsByParentId(
    NextListMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextListMomentByParentId(
        event.parentId, event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    }
  }

  void _onFirstTileMomentsByParentId(
    FirstTileMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstMomentTileByParentId(
        event.parentId, event.limit);
    if (isClosed) return;

    if (moments != null) add(UpdateTileMoments(moments: moments));
  }

  void _onNextTileMomentsByParentId(
    NextTileMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextTileMomentByParentId(
        event.parentId, event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateTileMoments(moments: moments));
    }
  }

  void _onFirstListMomentsByChildId(
    FirstListMomentsByChildId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstMomentListByChildId(
        event.childId, event.parentId, event.limit);
    if (isClosed) return;

    if (moments != null) add(UpdateListMoments(moments: moments));
  }

  void _onNextListMomentsByChildId(
    NextListMomentsByChildId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextMomentListByChildId(
        event.childId, event.parentId, event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    }
  }

  void _onFirstTileMomentsByChildId(
    FirstTileMomentsByChildId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstMomentTileByChildId(
        event.childId, event.parentId, event.limit);
    if (isClosed) return;

    if (moments != null) add(UpdateTileMoments(moments: moments));
  }

  void _onNextTileMomentsByChildId(
    NextTileMomentsByChildId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextMomentTileByChildId(
        event.childId, event.parentId, event.limit);

    if (moments != null) {
      emit(MomentFetchLoading());
      if (isClosed) return;
      add(UpdateTileMoments(moments: moments));
    }
  }

  void _onLoadMomentsByChildId(
    LoadMomentByChildId event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription = _momentRepository
        .getMomentByChildId(event.childId, event.parentId)
        .listen((moments) {
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    });
  }

  void _onLoadMomentsByParentId(
    LoadMomentByParentId event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription =
        _momentRepository.getMomentByParentId(event.parentId).listen((moments) {
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    });
  }

  void _onLoadFavoriteMoments(
    LoadFavoriteMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription =
        _momentRepository.getFavoriteMoments(event.favorites).listen((moments) {
      if (isClosed) return;
      moments.removeWhere((element) {
        if (FirebaseAuth.instance.currentUser == null) return true;
        return element.parentId == FirebaseAuth.instance.currentUser!.uid;
      });
      add(UpdateMoments(moments: moments));
    });
  }

  void _onLoadFavoriteMomentsByParentId(
    LoadFavoriteMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    await _mySubscription?.cancel();
    _mySubscription = _momentRepository
        .getMyFavoriteMoments(event.parentId, event.favorites)
        .listen((moments) {
      if (isClosed) return;
      add(UpdateMoments(moments: moments, isMyMoment: true));
    });
  }

  void _onLoadPatronizeMoments(
    LoadPatronizeMoments event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription = _momentRepository
        .getPatronizeMoments(event.patronizeds)
        .listen((moments) {
      if (isClosed) return;
      moments.removeWhere((element) {
        if (FirebaseAuth.instance.currentUser == null) return true;
        return element.parentId == FirebaseAuth.instance.currentUser!.uid;
      });
      add(UpdateMoments(moments: moments));
    });
  }

  void _onFirstPatronizeListMoments(
    FirstPatronizeListMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstPatronizeListMoments(
        event.patronizeds, event.limit);
    if (isClosed) return;
    add(UpdateListMoments(moments: moments));
  }

  void _onNextPatronizeListMoments(
    NextPatronizeListMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextPatronizeListMoments(
        event.patronizeds, event.limit);

    if (moments != null) {
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    } else {
      return null;
    }
  }

  void _onFirstPatronizeTileMoments(
    FirstPatronizeTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    // emit(MomentLoading());
    var moments = await _momentRepository.firstPatronizeTileMoments(
        event.patronizeds, event.limit);
    if (isClosed) return;
    add(UpdateTileMoments(moments: moments));
  }

  void _onNextPatronizeTileMoments(
    NextPatronizeTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextPatronizeListMoments(
        event.patronizeds, event.limit);

    if (moments != null) {
      if (isClosed) return;
      add(UpdateTileMoments(moments: moments));
    }
  }

  void _onFirstFavoriteListMoments(
    FirstFavoriteListMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.firstFavoriteListMoments(
        event.favorites, event.limit);
    if (isClosed) return;
    add(UpdateListMoments(moments: moments));
  }

  void _onNextFavoriteListMoments(
    NextFavoriteListMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextFavoriteListMoments(
        event.favorites, event.limit);

    if (moments != null) {
      if (isClosed) return;
      add(UpdateListMoments(moments: moments));
    }
  }

  void _onFirstFavoriteTileMoments(
    FirstFavoriteTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    // emit(MomentLoading());
    var moments = await _momentRepository.firstFavoriteTileMoments(
        event.favorites, event.limit);
    if (isClosed) return;
    add(UpdateTileMoments(moments: moments));
  }

  void _onNextFavoriteTileMoments(
    NextFavoriteTileMoments event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.nextFavoriteListMoments(
        event.favorites, event.limit);

    if (moments != null) {
      if (isClosed) return;
      add(UpdateTileMoments(moments: moments));
    }
  }

  void _onLoadMomentByDocId(
    LoadMomentByDocId event,
    Emitter<MomentState> emit,
  ) async {
    var moments = await _momentRepository.getMomentByDocId(event.id);

    if (moments != null) {
      if (isClosed) return;
      add(UpdateMoments(moments: moments));
    }
  }

  void _onLoadPatronizeMomentsByParentId(
    LoadPatronizeMomentsByParentId event,
    Emitter<MomentState> emit,
  ) async {
    await _mySubscription?.cancel();
    _mySubscription = _momentRepository
        .getMyFavoriteMoments(event.parentId, event.patronizeds)
        .listen((moments) {
      if (isClosed) return;
      add(UpdateMoments(moments: moments, isMyMoment: true));
    });
  }

  void _onLoadMomentsByTag(
    LoadMomentsByTag event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription =
        _momentRepository.getMomentsByTag(event.tag).listen((moments) {
      if (isClosed) return;
      add(UpdateMoments(moments: moments));
    });
  }

  void _onLoadMomentById(
    LoadMomentById event,
    Emitter<MomentState> emit,
  ) async {
    await _momentSubscription?.cancel();
    _momentSubscription =
        _momentRepository.getMomentById(event.momentId).listen((moments) {
      if (isClosed) return;
      add(UpdateMoments(moments: [moments]));
    });
  }
}
