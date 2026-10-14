import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/geofence.dart';

Color geofenceColor(GeofenceColor color) => switch(color){GeofenceColor.purple=>const Color(0xFF493091),GeofenceColor.green=>const Color(0xFF23935A),GeofenceColor.orange=>const Color(0xFFF47A13),GeofenceColor.red=>const Color(0xFFE51B4B),GeofenceColor.magenta=>const Color(0xFFD30FBD),GeofenceColor.blue=>const Color(0xFF087CAF),GeofenceColor.grey=>const Color(0xFF89899C),GeofenceColor.gold=>const Color(0xFFC68D00)};
double _hue(GeofenceColor c)=>switch(c){GeofenceColor.purple=>270,GeofenceColor.green=>140,GeofenceColor.orange=>30,GeofenceColor.red=>350,GeofenceColor.magenta=>310,GeofenceColor.blue=>200,GeofenceColor.grey=>240,GeofenceColor.gold=>45};
class GeoFenceMapController {
  GoogleMapController? _map;
  Future<void> zoomIn()=>_map?.animateCamera(CameraUpdate.zoomIn())??Future.value();
  Future<void> zoomOut()=>_map?.animateCamera(CameraUpdate.zoomOut())??Future.value();
  Future<void> focus(Geofence g) async { final map=_map;if(map==null)return; final bounds=_bounds(g.shape); if(bounds==null){final p=_center(g.shape);await map.animateCamera(CameraUpdate.newLatLngZoom(LatLng(p.latitude,p.longitude),15));}else{await map.animateCamera(CameraUpdate.newLatLngBounds(bounds,48));} }
}
LatLng _ll(GeoPoint p)=>LatLng(p.latitude,p.longitude);
GeoPoint _center(GeofenceShape s)=>switch(s){CircleShape(:final center)=>center,PolygonShape(:final points)=>points.first};
LatLngBounds? _bounds(GeofenceShape s){
  if(s is CircleShape){final d=s.radiusMeters/111000;return LatLngBounds(southwest:LatLng(s.center.latitude-d,s.center.longitude-d),northeast:LatLng(s.center.latitude+d,s.center.longitude+d));}
  if(s is! PolygonShape||s.points.isEmpty)return null; double south=90,north=-90,west=180,east=-180;for(final p in s.points){south=math.min(south,p.latitude);north=math.max(north,p.latitude);west=math.min(west,p.longitude);east=math.max(east,p.longitude);}if(south==north){south-=.002;north+=.002;}if(west==east){west-=.002;east+=.002;}return LatLngBounds(southwest:LatLng(south,west),northeast:LatLng(north,east));
}
class GeofenceMap extends StatefulWidget {
  const GeofenceMap({super.key,required this.controller,required this.geofences,required this.bottomInset,this.selectedId,this.mapType=MapType.normal,this.onSelect});
  final GeoFenceMapController controller; final List<Geofence> geofences; final double bottomInset; final String? selectedId; final MapType mapType; final ValueChanged<Geofence>? onSelect;
  @override State<GeofenceMap> createState()=>_GeofenceMapState();
}
class _GeofenceMapState extends State<GeofenceMap>{
  @override void dispose(){if(identical(widget.controller._map,_map))widget.controller._map=null;super.dispose();}
  GoogleMapController? _map;
  @override Widget build(BuildContext context){final polygons=<Polygon>{},circles=<Circle>{};final markers=<Marker>{};for(final g in widget.geofences){final c=geofenceColor(g.colorValue);final active=g.id==widget.selectedId;final z=active?3:1;switch(g.shape){case PolygonShape(:final points):if(points.length>=3)polygons.add(Polygon(polygonId:PolygonId(g.id),points:points.map(_ll).toList(),strokeColor:c,fillColor:c.withValues(alpha:.18),strokeWidth:active?4:2,zIndex:z));case CircleShape(:final center,:final radiusMeters):circles.add(Circle(circleId:CircleId(g.id),center:_ll(center),radius:radiusMeters,strokeColor:c,fillColor:c.withValues(alpha:.15),strokeWidth:active?4:2,zIndex:z));}final p=_center(g.shape);markers.add(Marker(markerId:MarkerId(g.id),position:_ll(p),icon:BitmapDescriptor.defaultMarkerWithHue(_hue(g.colorValue)),zIndexInt:z,onTap:()=>widget.onSelect?.call(g)));}
    return GoogleMap(initialCameraPosition:const CameraPosition(target:LatLng(24.86,46.40),zoom:12.5),onMapCreated:(m){_map=m;widget.controller._map=m;},mapType:widget.mapType,polygons:polygons,circles:circles,markers:markers,compassEnabled:false,myLocationButtonEnabled:false,zoomControlsEnabled:false, padding:EdgeInsets.only(bottom:widget.bottomInset));}
}
