part of 'moment_bloc.dart';

abstract class MomentEvent extends Equatable {
  const MomentEvent();

  @override
  List<Object> get props => [];
}

class LoadAllMoments extends MomentEvent {}

class FetchFirstListMoments extends MomentEvent {
  final int limit;
  const FetchFirstListMoments({this.limit = 8});
}

class FetchNextListMoments extends MomentEvent {
  final int limit;
  const FetchNextListMoments({required this.limit});
}

class FetchFirstTileMoments extends MomentEvent {
  final int limit;
  const FetchFirstTileMoments({this.limit = 30});
}

class FetchNextTileMoments extends MomentEvent {
  final int limit;
  const FetchNextTileMoments({required this.limit});
}

class FirstListMomentsByParentId extends MomentEvent {
  final String parentId;
  final int limit;
  const FirstListMomentsByParentId({required this.parentId, this.limit = 8});
}

class NextListMomentsByParentId extends MomentEvent {
  final String parentId;
  final int limit;
  const NextListMomentsByParentId({required this.parentId, this.limit = 8});
}

class FirstTileMomentsByParentId extends MomentEvent {
  final String parentId;
  final int limit;
  const FirstTileMomentsByParentId({required this.parentId, this.limit = 32});
}

class NextTileMomentsByParentId extends MomentEvent {
  final String parentId;
  final int limit;
  const NextTileMomentsByParentId({required this.parentId, this.limit = 8});
}

class FirstListMomentsByChildId extends MomentEvent {
  final String childId, parentId;
  final int limit;

  const FirstListMomentsByChildId(
      {required this.childId, required this.parentId, this.limit = 8});

  @override
  List<Object> get props => [childId, parentId];
}

class NextListMomentsByChildId extends MomentEvent {
  final String childId, parentId;
  final int limit;

  const NextListMomentsByChildId(
      {required this.childId, required this.parentId, this.limit = 8});

  @override
  List<Object> get props => [childId, parentId];
}

class FirstTileMomentsByChildId extends MomentEvent {
  final String childId, parentId;
  final int limit;

  const FirstTileMomentsByChildId(
      {required this.childId, required this.parentId, this.limit = 32});

  @override
  List<Object> get props => [childId, parentId];
}

class NextTileMomentsByChildId extends MomentEvent {
  final String childId, parentId;
  final int limit;

  const NextTileMomentsByChildId(
      {required this.childId, required this.parentId, this.limit = 32});

  @override
  List<Object> get props => [childId, parentId];
}

class LoadMomentByChildId extends MomentEvent {
  final String childId, parentId;

  const LoadMomentByChildId({required this.childId, required this.parentId});

  @override
  List<Object> get props => [childId, parentId];
}

class LoadMomentByParentId extends MomentEvent {
  final String parentId;

  const LoadMomentByParentId({required this.parentId});

  @override
  List<Object> get props => [parentId];
}

class LoadFavoriteMoments extends MomentEvent {
  final List<String> favorites;

  const LoadFavoriteMoments({required this.favorites});

  @override
  List<Object> get props => [favorites];
}

class LoadFavoriteMomentsByParentId extends MomentEvent {
  final List<String> favorites;
  final String parentId;

  const LoadFavoriteMomentsByParentId(
      {required this.favorites, required this.parentId});

  @override
  List<Object> get props => [favorites, parentId];
}

class LoadPatronizeMoments extends MomentEvent {
  final List<String> patronizeds;

  const LoadPatronizeMoments({required this.patronizeds});

  @override
  List<Object> get props => [patronizeds];
}

class FirstPatronizeListMoments extends MomentEvent {
  final List<String> patronizeds;
  final int limit;

  const FirstPatronizeListMoments({required this.patronizeds, this.limit = 8});

  @override
  List<Object> get props => [patronizeds, limit];
}

class NextPatronizeListMoments extends MomentEvent {
  final List<String> patronizeds;
  final int limit;

  const NextPatronizeListMoments({required this.patronizeds, this.limit = 8});

  @override
  List<Object> get props => [patronizeds, limit];
}

class FirstPatronizeTileMoments extends MomentEvent {
  final List<String> patronizeds;
  final int limit;

  const FirstPatronizeTileMoments({required this.patronizeds, this.limit = 32});

  @override
  List<Object> get props => [patronizeds, limit];
}

class NextPatronizeTileMoments extends MomentEvent {
  final List<String> patronizeds;
  final int limit;

  const NextPatronizeTileMoments({required this.patronizeds, this.limit = 32});

  @override
  List<Object> get props => [patronizeds, limit];
}

class FirstFavoriteListMoments extends MomentEvent {
  final List<String> favorites;
  final int limit;

  const FirstFavoriteListMoments({required this.favorites, this.limit = 8});

  @override
  List<Object> get props => [favorites];
}

class NextFavoriteListMoments extends MomentEvent {
  final List<String> favorites;
  final int limit;

  const NextFavoriteListMoments({required this.favorites, this.limit = 8});

  @override
  List<Object> get props => [favorites];
}

class FirstFavoriteTileMoments extends MomentEvent {
  final List<String> favorites;
  final int limit;

  const FirstFavoriteTileMoments({required this.favorites, this.limit = 8});

  @override
  List<Object> get props => [favorites];
}

class NextFavoriteTileMoments extends MomentEvent {
  final List<String> favorites;
  final int limit;

  const NextFavoriteTileMoments({required this.favorites, this.limit = 8});

  @override
  List<Object> get props => [favorites];
}

class LoadPatronizeMomentsByParentId extends MomentEvent {
  final List<String> patronizeds;
  final String parentId;

  const LoadPatronizeMomentsByParentId(
      {required this.patronizeds, required this.parentId});

  @override
  List<Object> get props => [patronizeds, parentId];
}

class LoadMomentsByTag extends MomentEvent {
  final String tag;

  const LoadMomentsByTag({required this.tag});

  @override
  List<Object> get props => [tag];
}

class LoadMomentById extends MomentEvent {
  final String momentId;

  const LoadMomentById({required this.momentId});

  @override
  List<Object> get props => [momentId];
}

class UpdateMoments extends MomentEvent {
  final List<MomentModel> moments;
  final bool isMyMoment;

  const UpdateMoments({required this.moments, this.isMyMoment = false});

  @override
  List<Object> get props => [moments, isMyMoment];
}

class UpdateListMoments extends MomentEvent {
  final List<MomentModel> moments;
  final bool isMyMoment;

  const UpdateListMoments({required this.moments, this.isMyMoment = false});

  @override
  List<Object> get props => [moments, isMyMoment];
}

class UpdateTileMoments extends MomentEvent {
  final List<MomentModel> moments;
  final bool isMyMoment;

  const UpdateTileMoments({required this.moments, this.isMyMoment = false});

  @override
  List<Object> get props => [moments, isMyMoment];
}

class LoadMomentByDocId extends MomentEvent {
  final String id;

  const LoadMomentByDocId({required this.id});

  @override
  List<Object> get props => [id];
}
