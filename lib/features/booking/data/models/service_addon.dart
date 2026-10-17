class ServiceAddon {
  const ServiceAddon({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.categoryPrices,
    required this.position,
    required this.published,
    this.iconKey,
    this.vehicleCategory,
  });

  final String id;
  final String name;
  final double basePrice;
  final Map<String, double> categoryPrices;
  final int position;
  final bool published;
  final String? iconKey;
  final String? vehicleCategory;

  bool supportsCategory(String category) {
    final String normalized = category.trim().toLowerCase();
    if (categoryPrices.containsKey(normalized)) {
      return true;
    }
    final String? fallbackCategory = vehicleCategory?.trim().toLowerCase();
    return fallbackCategory == null || fallbackCategory == normalized;
  }

  double priceFor(String category) {
    final String normalized = category.trim().toLowerCase();
    return categoryPrices[normalized] ??
        categoryPrices[vehicleCategory?.trim().toLowerCase()] ??
        basePrice;
  }
}
