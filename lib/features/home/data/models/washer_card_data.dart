import 'package:google_maps_flutter/google_maps_flutter.dart';

class WasherCardData {
  const WasherCardData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.rank,
    required this.distance,
    required this.reviews,
    required this.badge,
    required this.imageUrl,
    required this.imageAsset,
    required this.city,
    required this.point,
    required this.isAvailable,
    required this.isVerified,
    this.isTopWasher = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final String rating;
  final String rank;
  final String distance;
  final String reviews;
  final String badge;
  final String? imageUrl;
  final String imageAsset;
  final String city;
  final LatLng point;
  final bool isAvailable;
  final bool isVerified;
  final bool isTopWasher;
}
