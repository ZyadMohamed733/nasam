import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/drawer_menu.dart';
import '../../domain/entities/geofence.dart';
import '../../domain/usecases/geofence_operations.dart';
enum GeofenceStatus { initial, loading, loaded, failure }
class GeofenceState {
  const GeofenceState({this.status=GeofenceStatus.initial,this.geofences=const [],this.query='',this.selectedId,this.failure});
  final GeofenceStatus status; final List<Geofence> geofences; final String query; final String? selectedId; final Object? failure;
  List<Geofence> get visibleGeofences { final q=foldForSearch(query); return geofences.where((g)=>foldForSearch(g.name).contains(q)).toList(); }
}
class GeofenceCubit extends Cubit<GeofenceState> {
  GeofenceCubit(this._get,this._delete,WatchGeofenceChangesUseCase watch):super(const GeofenceState()) { _subscription=watch().listen((_) { if(state.status==GeofenceStatus.loading){_pending=true;} else {unawaited(load());} }); }
  final GetGeofencesUseCase _get; final DeleteGeofenceUseCase _delete; late final StreamSubscription<void> _subscription; bool _pending=false,_deleting=false;
  @override Future<void> close() async { await _subscription.cancel(); await super.close(); }
  Future<void> load() async { if(state.status==GeofenceStatus.loading){_pending=true;return;} emit(GeofenceState(status:GeofenceStatus.loading,geofences:state.geofences,query:state.query,selectedId:state.selectedId)); final r=await _get(); if(isClosed)return; r.fold((e)=>emit(GeofenceState(status:GeofenceStatus.failure,geofences:state.geofences,query:state.query,selectedId:state.selectedId,failure:e)),(items)=>emit(GeofenceState(status:GeofenceStatus.loaded,geofences:items,query:state.query,selectedId:items.any((g)=>g.id==state.selectedId)?state.selectedId:null))); if(_pending&&!isClosed){_pending=false;await load();} }
  void search(String q)=>emit(GeofenceState(status:state.status,geofences:state.geofences,query:q,selectedId:state.selectedId,failure:state.failure));
  void select(String? id)=>emit(GeofenceState(status:state.status,geofences:state.geofences,query:state.query,selectedId:id,failure:state.failure));
  Future<bool> delete(String id) async { if(_deleting)return false;_deleting=true;try{final r=await _delete(id);if(isClosed)return false;if(r.isLeft())return false;await load();return true;}finally{_deleting=false;} }
}
