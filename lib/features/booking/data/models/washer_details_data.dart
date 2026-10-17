import '../../../home/data/models/washer_card_data.dart';
import 'service_addon.dart';
import 'service_package.dart';

class WasherDetailsData {
  const WasherDetailsData({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.ratingLabel,
    required this.reviewLabel,
    required this.rankLabel,
    required this.badgeLabel,
    required this.locationPrimary,
    required this.locationSecondary,
    required this.imageAsset,
    required this.vehicleCategories,
    required this.packages,
    required this.addons,
    required this.galleryImageUrls,
    this.coverImageUrl,
    this.avatarImageUrl,
    this.phoneNumber,
    this.preview,
  });

  final String id;
  final String name;
  final String subtitle;
  final String description;
  final String ratingLabel;
  final String reviewLabel;
  final String rankLabel;
  final String badgeLabel;
  final String locationPrimary;
  final String locationSecondary;
  final String imageAsset;
  final List<String> vehicleCategories;
  final List<ServicePackage> packages;
  final List<ServiceAddon> addons;
  final List<String> galleryImageUrls;
  final String? coverImageUrl;
  final String? avatarImageUrl;
  final String? phoneNumber;
  final WasherCardData? preview;
}
