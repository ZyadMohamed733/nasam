import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
class GeofenceMapState { const GeofenceMapState({this.mapType=MapType.normal,this.focusRequest=0,this.focusedId}); final MapType mapType;final int focusRequest;final String? focusedId; }
class GeofenceMapCubit extends Cubit<GeofenceMapState> { GeofenceMapCubit():super(const GeofenceMapState());void cycleMapType(){final next=switch(state.mapType){MapType.normal=>MapType.hybrid,MapType.hybrid=>MapType.terrain,_=>MapType.normal};emit(GeofenceMapState(mapType:next,focusRequest:state.focusRequest,focusedId:state.focusedId));}void focus(String id)=>emit(GeofenceMapState(mapType:state.mapType,focusRequest:state.focusRequest+1,focusedId:id)); }
