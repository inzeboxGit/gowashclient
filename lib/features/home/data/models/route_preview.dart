import 'package:google_maps_flutter/google_maps_flutter.dart';

class RoutePreview {
  const RoutePreview({required this.points, required this.summary});

  final List<LatLng> points;
  final String summary;
}
