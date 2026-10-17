import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/utils/app_runtime.dart';
import '../models/firestore_washer_record.dart';
import '../models/washer_card_data.dart';

class WasherRepository {
  const WasherRepository();

  static const List<String> _washerImageAssets = [
    'assets/images/service_car.svg',
    'assets/images/service_interior.svg',
    'assets/images/service_exterior.svg',
  ];

  bool get usesFirestoreBackend => AppRuntime.supportsFirebaseBackend;

  // Watches the list of washers from Firestore, excluding banned washers.
  Stream<List<WasherCardData>> watchWashers() {
    if (!usesFirestoreBackend) {
      return const Stream<List<WasherCardData>>.empty();
    }

    return FirebaseFirestore.instance
        .collection('pub_laveurs')
        .where('isBanned', isEqualTo: false)
        .snapshots()
        .map((snapshot) => _buildWashersFromSnapshot(snapshot.docs));
  }

  // Builds a list of WasherCardData from Firestore documents, applying ranking and formatting.
  List<WasherCardData> _buildWashersFromSnapshot(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final List<FirestoreWasherRecord> records = <FirestoreWasherRecord>[];

    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc in docs) {
      final Map<String, dynamic> data = doc.data();
      if (_readBool(data['isBanned'])) {
        continue;
      }

      final Map<String, dynamic> laveurData =
          _asMap(data['laveurData']) ??
          _asMap(data['LaveurData']) ??
          <String, dynamic>{};
      final List<String> businessTypes = _readStringList(
        data['businessTypes'] ??
            laveurData['businessTypes'] ??
            laveurData['services'] ??
            data['services'],
      );
      final Map<String, dynamic>? locationData = _asMap(
        data['location'] ?? laveurData['location'],
      );
      final LatLng? point = _readLatLng(locationData);
      if (point == null) {
        continue;
      }
      final int completedJobs =
          _readInt(data['completedJobs'] ?? laveurData['completedJobs']) ?? 0;
      final double? ratingValue = _readDouble(
        data['rating'] ?? laveurData['rating'],
      );
      final bool isAvailable = _readBool(
        data['isAvailable'] ??
            data['availableNow'] ??
            laveurData['isAvailable'],
      );

      records.add(
        FirestoreWasherRecord(
          id: doc.id,
          title:
              _readString(data['businessName']) ??
              _readString(data['fullName']) ??
              'Washer',
          subtitle: _buildSubtitle(
            businessTypes,
            description:
                _readString(data['description']) ??
                _readString(laveurData['description']),
            isAvailable: isAvailable,
          ),
          ratingValue: ratingValue ?? 0,
          ratingLabel: _ratingLabel(ratingValue),
          completedJobs: completedJobs,
          businessTypes: businessTypes,
          platform:
              _readString(data['platform']) ??
              _readString(laveurData['platform']),
          city: _cityFromLocation(locationData),
          imageUrl: _readPrimaryImageUrl(data),
          isAvailable: isAvailable,
          isVerified: _readBool(data['isVerified']),
          point: point,
          imageAsset:
              _washerImageAssets[records.length % _washerImageAssets.length],
        ),
      );
    }

    if (records.isEmpty) {
      return <WasherCardData>[];
    }

    final List<FirestoreWasherRecord> rankedRecords =
        List<FirestoreWasherRecord>.of(records)..sort((a, b) {
          final int jobsCompare = b.completedJobs.compareTo(a.completedJobs);
          if (jobsCompare != 0) {
            return jobsCompare;
          }

          final int ratingCompare = b.ratingValue.compareTo(a.ratingValue);
          if (ratingCompare != 0) {
            return ratingCompare;
          }

          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });

    final Map<String, int> ranksById = <String, int>{};
    for (int i = 0; i < rankedRecords.length; i++) {
      ranksById[rankedRecords[i].id] = i + 1;
    }
    final String topWasherId = rankedRecords.first.id;

    return records.map((record) {
      final int rank = ranksById[record.id] ?? records.length;
      return WasherCardData(
        id: record.id,
        title: record.title,
        subtitle: record.subtitle,
        rating: record.ratingLabel,
        rank: '#$rank',
        distance: '--',
        reviews: _jobLabel(record.completedJobs),
        badge: rank == 1
            ? 'Top washer'
            : _buildBadge(
                isAvailable: record.isAvailable,
                isVerified: record.isVerified,
                platform: record.platform,
                businessTypes: record.businessTypes,
              ),
        imageUrl: record.imageUrl,
        imageAsset: record.imageAsset,
        city: record.city,
        point: record.point,
        isAvailable: record.isAvailable,
        isVerified: record.isVerified,
        isTopWasher: record.id == topWasherId,
      );
    }).toList();
  }

  String _buildSubtitle(
    List<String> businessTypes, {
    String? description,
    required bool isAvailable,
  }) {
    final String businessTypeLabel = _formatBusinessTypes(businessTypes);
    if (businessTypeLabel.isNotEmpty) {
      return businessTypeLabel;
    }

    final String? shortDescription = _shortLabel(description);
    if (shortDescription != null) {
      return shortDescription;
    }

    return isAvailable ? 'Available now' : 'Mobile detailer';
  }

  String _jobLabel(int completedJobs) {
    if (completedJobs == 1) {
      return '1 Job';
    }
    return '$completedJobs Jobs';
  }

  String _ratingLabel(double? firestoreRating) {
    if (firestoreRating == null || firestoreRating <= 0) {
      return 'New';
    }
    return firestoreRating.toStringAsFixed(1);
  }

  String _buildBadge({
    required bool isAvailable,
    required bool isVerified,
    required String? platform,
    required List<String> businessTypes,
  }) {
    if (isVerified) {
      return 'Verified';
    }
    if (isAvailable) {
      return 'Available now';
    }

    final String? platformLabel = _platformBadge(platform);
    if (platformLabel != null) {
      return platformLabel;
    }

    if (businessTypes.isNotEmpty) {
      return '${_formatBusinessType(businessTypes.first)} care';
    }

    return 'Mobile detailer';
  }

  String? _platformBadge(String? platform) {
    final String? normalized = _readString(platform)?.toLowerCase();
    if (normalized == null) {
      return null;
    }
    if (normalized == 'pro') {
      return 'Pro washer';
    }
    return _titleCaseWords(normalized);
  }

  String _formatBusinessTypes(List<String> businessTypes) {
    if (businessTypes.isEmpty) {
      return '';
    }

    return businessTypes
        .take(2)
        .map(_formatBusinessType)
        .where((item) => item.isNotEmpty)
        .join(' • ');
  }

  String _formatBusinessType(String value) {
    final String normalized = value.trim();
    if (normalized.isEmpty) {
      return '';
    }

    switch (normalized.toLowerCase()) {
      case 'car':
        return 'Car wash';
      case 'interior':
        return 'Interior care';
      case 'exterior':
        return 'Exterior care';
      default:
        return _titleCaseWords(normalized);
    }
  }

  String _titleCaseWords(String value) {
    return value
        .split(RegExp(r'[\s_-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) {
          final String lower = part.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  String? _shortLabel(String? value, {int maxLength = 56}) {
    final String? text = _readString(value);
    if (text == null) {
      return null;
    }
    if (text.length <= maxLength) {
      return text;
    }

    final String shortened = text.substring(0, maxLength);
    final int lastSpace = shortened.lastIndexOf(' ');
    final String safeText =
        (lastSpace > 20 ? shortened.substring(0, lastSpace) : shortened)
            .trimRight();
    return '$safeText...';
  }

  String _cityFromLocation(Map<String, dynamic>? location) {
    final String? address = _readString(location?['address']);
    if (address == null) {
      return 'Nearby';
    }

    final List<String> parts = address
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return 'Nearby';
    }
    if (parts.length == 1) {
      return parts.first;
    }

    return parts[parts.length - 2];
  }

  String? _readPrimaryImageUrl(Map<String, dynamic> data) {
    return _readString(_firstListItem(data['galleryUrls'])) ??
        _readString(data['bannerUrl']) ??
        _readString(data['logoUrl']);
  }

  dynamic _firstListItem(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first;
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, innerValue) => MapEntry(key.toString(), innerValue),
      );
    }
    return null;
  }

  String? _readString(dynamic value) {
    if (value == null) {
      return null;
    }
    final String text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  bool _readBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  int? _readInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  double? _readDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  LatLng? _readLatLng(dynamic value) {
    if (value is GeoPoint) {
      return LatLng(value.latitude, value.longitude);
    }

    final Map<String, dynamic>? location = _asMap(value);
    if (location == null) {
      return null;
    }

    final double? latitude = _readDouble(
      location['latitude'] ?? location['lat'],
    );
    final double? longitude = _readDouble(
      location['longitude'] ?? location['lng'] ?? location['lon'],
    );

    if (latitude == null || longitude == null) {
      return null;
    }

    return LatLng(latitude, longitude);
  }
}
