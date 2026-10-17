class ReservationData {
  const ReservationData({
    required this.id,
    required this.status,
    required this.referenceCode,
    required this.washerName,
    required this.vehicleCategory,
    required this.packageName,
    required this.addonNames,
    required this.totalPrice,
    required this.scheduledAt,
    this.progressLabel,
    this.washerPhoneNumber,
    this.invoiceUrl,
  });

  final String id;
  final String status;
  final String referenceCode;
  final String washerName;
  final String vehicleCategory;
  final String packageName;
  final List<String> addonNames;
  final double totalPrice;
  final DateTime? scheduledAt;
  final String? progressLabel;
  final String? washerPhoneNumber;
  final String? invoiceUrl;

  bool get isCompleted {
    final String normalized = status.trim().toLowerCase();
    return normalized == 'completed' ||
        normalized == 'done' ||
        normalized == 'finished';
  }
}
