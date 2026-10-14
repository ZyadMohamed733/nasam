import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/geofence.dart';
import '../../domain/entities/geofence_draft.dart';
import '../../domain/usecases/geofence_operations.dart';
enum GeofenceEditorStatus { initial, loading, ready, saving, saved, failure }
class GeofenceEditorState {
  const GeofenceEditorState({this.status=GeofenceEditorStatus.initial,this.id,this.draft=const GeofenceDraft(),this.currentStep=0,this.failure,this.dirty=false});
  final GeofenceEditorStatus status; final String? id; final GeofenceDraft draft; final int currentStep; final Failure? failure; final bool dirty;
  bool get stepValid=>switch(currentStep){0=>draft.infoValid,1=>draft.drawValid,2=>draft.timeValid,3=>draft.settingsValid,_=>true};
}
class GeofenceEditorCubit extends Cubit<GeofenceEditorState> {
  GeofenceEditorCubit(this._get,this._save):super(const GeofenceEditorState()); final GetGeofenceUseCase _get;final SaveGeofenceUseCase _save; bool _busy=false;
  void initCreate()=>emit(const GeofenceEditorState(status:GeofenceEditorStatus.ready));
  Future<void> load(String id) async {if(_busy)return;_busy=true;emit(GeofenceEditorState(status:GeofenceEditorStatus.loading,id:id));final r=await _get(id);_busy=false;if(isClosed)return;r.fold((e)=>emit(GeofenceEditorState(status:GeofenceEditorStatus.failure,id:id,failure:e)),(g)=>emit(GeofenceEditorState(status:GeofenceEditorStatus.ready,id:id,draft:GeofenceDraft(name:g.name,assetIds:g.assetIds,shape:g.shape,color:g.colorValue,schedule:g.schedule,settings:g.settings))));}
  void _change(GeofenceDraft d)=>emit(GeofenceEditorState(status:GeofenceEditorStatus.ready,id:state.id,draft:d,currentStep:state.currentStep,dirty:true));
  void setName(String v)=>_change(GeofenceDraft(name:v,assetIds:state.draft.assetIds,shape:state.draft.shape,color:state.draft.color,schedule:state.draft.schedule,settings:state.draft.settings));
  void setAssets(List<String> v)=>_change(GeofenceDraft(name:state.draft.name,assetIds:v,shape:state.draft.shape,color:state.draft.color,schedule:state.draft.schedule,settings:state.draft.settings));
  void setShape(GeofenceShape v)=>_change(GeofenceDraft(name:state.draft.name,assetIds:state.draft.assetIds,shape:v,color:state.draft.color,schedule:state.draft.schedule,settings:state.draft.settings));
  void setColor(GeofenceColor v)=>_change(GeofenceDraft(name:state.draft.name,assetIds:state.draft.assetIds,shape:state.draft.shape,color:v,schedule:state.draft.schedule,settings:state.draft.settings));
  void setSchedule(GeofenceSchedule v)=>_change(GeofenceDraft(name:state.draft.name,assetIds:state.draft.assetIds,shape:state.draft.shape,color:state.draft.color,schedule:v,settings:state.draft.settings));
  void setSettings(GeofenceSettings v)=>_change(GeofenceDraft(name:state.draft.name,assetIds:state.draft.assetIds,shape:state.draft.shape,color:state.draft.color,schedule:state.draft.schedule,settings:v));
  void next(){if(state.stepValid&&state.currentStep<4)emit(GeofenceEditorState(status:state.status,id:state.id,draft:state.draft,currentStep:state.currentStep+1,dirty:state.dirty));}
  void previous(){if(state.currentStep>0)goToStep(state.currentStep-1);}
  void goToStep(int i){if(i>=0&&i<=4)emit(GeofenceEditorState(status:state.status,id:state.id,draft:state.draft,currentStep:i,dirty:state.dirty));}
  Future<bool> save() async {if(_busy||!state.draft.isValid)return false;_busy=true;emit(GeofenceEditorState(status:GeofenceEditorStatus.saving,id:state.id,draft:state.draft,currentStep:state.currentStep,dirty:state.dirty));final r=await _save(state.draft,id:state.id);_busy=false;if(isClosed)return false;return r.fold((e){emit(GeofenceEditorState(status:GeofenceEditorStatus.failure,id:state.id,draft:state.draft,currentStep:state.currentStep,failure:e,dirty:state.dirty));return false;},(_){emit(GeofenceEditorState(status:GeofenceEditorStatus.saved,id:state.id,draft:state.draft,currentStep:state.currentStep));return true;});}
}
