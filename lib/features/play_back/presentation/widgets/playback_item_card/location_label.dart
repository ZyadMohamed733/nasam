import 'package:flutter/material.dart';

class LocationLabel extends StatelessWidget {
  const LocationLabel({
    required this.place,
    required this.style,
    required this.iconColor,
    required this.iconSize,
    this.alignEnd = false,
  });

  final String place;
  final TextStyle? style;
  final Color iconColor;
  final double iconSize;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final icon = WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Icon(Icons.location_on_outlined, size: iconSize, color: iconColor),
    );
    final gap = WidgetSpan(child: SizedBox(width: 3));
    final text = TextSpan(text: place, style: style);

    return Text.rich(
      TextSpan(
        children: alignEnd ? [text, gap, icon] : [icon, gap, text],
      ),
      textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}