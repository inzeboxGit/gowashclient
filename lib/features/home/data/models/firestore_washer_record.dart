import 'package:google_maps_flutter/google_maps_flutter.dart';

class FirestoreWasherRecord {
  const FirestoreWasherRecord({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ratingValue,
    required this.ratingLabel,
    required this.completedJobs,
    required this.businessTypes,
    required this.platform,
    required this.city,
    required this.imageUrl,
    required this.isAvailable,
    required this.isVerified,
    required this.point,
    required this.imageAsset,
  });

  final String id;
  final String title;
  final String subtitle;
  final double ratingValue;
  final String ratingLabel;
  final int completedJobs;
  final List<String> businessTypes;
  final String? platform;
  final String city;
  final String? imageUrl;
  final bool isAvailable;
  final bool isVerified;
  final LatLng point;
  final String imageAsset;
}
