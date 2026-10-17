class ServicePackage {
  const ServicePackage({
    required this.id,
    required this.name,
    required this.features,
    required this.addonIds,
    required this.prices,
    required this.position,
    required this.isBestOffer,
    required this.published,
    this.vehicleCategory,
  });

  final String id;
  final String name;
  final List<String> features;
  final List<String> addonIds;
  final Map<String, double> prices;
  final int position;
  final bool isBestOffer;
  final bool published;
  final String? vehicleCategory;

  bool supportsCategory(String category) {
    final String normalized = category.trim().toLowerCase();
    if (prices.containsKey(normalized)) {
      return true;
    }
    final String? fallbackCategory = vehicleCategory?.trim().toLowerCase();
    return fallbackCategory == null || fallbackCategory == normalized;
  }

  double? priceFor(String category) {
    final String normalized = category.trim().toLowerCase();
    return prices[normalized] ??
        prices[vehicleCategory?.trim().toLowerCase()] ??
        prices.values.cast<double?>().firstWhere(
          (value) => value != null,
          orElse: () => null,
        );
  }
}
