import 'package:flutter/material.dart';

class GeofencePage extends StatelessWidget{
  const GeofencePage({super.key, required this.openDrawer});
  final VoidCallback openDrawer;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container();
  }

}

/*
GeofencePage  --> MapWidget  + GeoBottomSheet
MapWidget --> List Of Markers  + MapControllersWidget
GeoBottomSheet --> it is exist in POi feature  but the AppButton is Different as it will push user to
pages --> Create GeoFencePage

GeoFencePage

 consist of
  StepsWidgetHeader
 5 steps
 -1 - InfoStepWidget
  2- DrawStepWidget
  3- TimeStepWidget
  4- SettingWidget
  5 -ViewStepWidget

 Back Next Buttons Widget
  InfoStep i need note to make the BottomSheet tobe also outside the widget and name in InfoStepBottomsheet
   DrawStepWidget  has two tabs widget
       and- Polygon tab
        - points tab

       note that PolYgeonWidget is shared between two tabs and it has Plougoen color and the polygeon map

       points tab has  ploygeonWidget and SettingCircilayrangeWidget
       Polygeon tab has a ploygeonwidget and  PolygeonInfo


    - TimeStepWidget has two tabs AlwaysActivetab and Speicif schdular Tab
     - SettingStepWidget has shared widget called ReactivationٍSettingWidget that has RadioButton and title and subtitle and main header and this is optional

     - view Setting  - each card has edit button icon that naivgate me to speicif step

 */