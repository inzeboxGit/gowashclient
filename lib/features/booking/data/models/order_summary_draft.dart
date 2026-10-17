import 'service_addon.dart';
import 'service_package.dart';

class OrderSummaryDraft {
  const OrderSummaryDraft({
    required this.washerId,
    required this.washerName,
    required this.washerSubtitle,
    required this.washerImageAsset,
    required this.vehicleCategory,
    required this.selectedPackage,
    required this.selectedAddons,
    required this.totalPrice,
    this.washerImageUrl,
    this.washerPhoneNumber,
  });

  final String washerId;
  final String washerName;
  final String washerSubtitle;
  final String washerImageAsset;
  final String vehicleCategory;
  final ServicePackage selectedPackage;
  final List<ServiceAddon> selectedAddons;
  final double totalPrice;
  final String? washerImageUrl;
  final String? washerPhoneNumber;
}
