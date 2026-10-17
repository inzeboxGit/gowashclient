import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../models/route_preview.dart';

class DirectionsService {
  const DirectionsService();

  static const String _googleRoutesApiKey =
      'AIzaSyAcGP2ttg04MnWdJo7Bl_ZPpJWDZknMtZs';

  Future<RoutePreview> fetchRoutePreview({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final Uri uri = Uri.parse(
      'https://routes.googleapis.com/directions/v2:computeRoutes',
    );
    final http.Response response = await http.post(
      uri,
      headers: const <String, String>{
        'Content-Type': 'application/json',
        'X-Goog-FieldMask':
            'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline',
        'X-Goog-Api-Key': _googleRoutesApiKey,
      },
      body: jsonEncode({
        'origin': {
          'location': {
            'latLng': {
              'latitude': origin.latitude,
              'longitude': origin.longitude,
            },
          },
        },
        'destination': {
          'location': {
            'latLng': {
              'latitude': destination.latitude,
              'longitude': destination.longitude,
            },
          },
        },
        'travelMode': 'DRIVE',
        'routingPreference': 'TRAFFIC_AWARE',
        'polylineQuality': 'HIGH_QUALITY',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('Route request failed: ${response.statusCode}');
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> routes =
        data['routes'] as List<dynamic>? ?? <dynamic>[];
    if (routes.isEmpty) {
      throw StateError('No routes returned');
    }

    final Map<String, dynamic> route = routes.first as Map<String, dynamic>;
    final Map<String, dynamic>? polyline =
        route['polyline'] as Map<String, dynamic>?;
    final String encodedPolyline =
        polyline?['encodedPolyline'] as String? ?? '';
    final List<LatLng> points = _decodePolyline(encodedPolyline);
    final int? distanceMeters = route['distanceMeters'] as int?;
    final String? durationText = route['duration'] as String?;
    return RoutePreview(
      points: points,
      summary: _routeSummaryText(distanceMeters, durationText),
    );
  }

  String _routeSummaryText(int? distanceMeters, String? durationText) {
    final String distance = distanceMeters == null
        ? ''
        : distanceMeters < 1000
        ? '${distanceMeters.round()} m'
        : '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    final String duration = durationText == null
        ? ''
        : '${(double.tryParse(durationText.replaceAll('s', '')) ?? 0 / 60).round()} min';
    if (distance.isEmpty) {
      return duration;
    }
    if (duration.isEmpty) {
      return distance;
    }
    return '$distance · $duration';
  }

  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = <LatLng>[];
    int index = 0;
    int latitude = 0;
    int longitude = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int latitudeChange = (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);
      latitude += latitudeChange;

      result = 0;
      shift = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final int longitudeChange = (result & 1) != 0
          ? ~(result >> 1)
          : (result >> 1);
      longitude += longitudeChange;

      points.add(LatLng(latitude / 1e5, longitude / 1e5));
    }

    return points;
  }
}
