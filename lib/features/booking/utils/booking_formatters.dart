String formatEuro(num value) {
  final bool isWhole = value % 1 == 0;
  if (isWhole) {
    return '€${value.toStringAsFixed(0)}';
  }
  return '€${value.toStringAsFixed(2)}';
}

String formatVehicleCategory(String value) {
  final String normalized = value.trim().toLowerCase();
  switch (normalized) {
    case 'small':
      return 'Small';
    case 'sedan':
      return 'Sedan';
    case 'suv':
      return 'SUV';
    default:
      if (normalized.isEmpty) {
        return 'Vehicle';
      }
      return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}

String formatBookingDateTime(DateTime? value) {
  if (value == null) {
    return 'Today';
  }

  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final int hour = value.hour % 12 == 0 ? 12 : value.hour % 12;
  final String minute = value.minute.toString().padLeft(2, '0');
  final String suffix = value.hour >= 12 ? 'PM' : 'AM';
  return '${months[value.month - 1]} ${value.day} · $hour:$minute $suffix';
}

String formatBookingDay(DateTime? value) {
  if (value == null) {
    return 'Today';
  }

  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[value.month - 1]} ${value.day}';
}

String normalizeStatusLabel(String status) {
  final String normalized = status.trim().toLowerCase();
  switch (normalized) {
    case 'completed':
    case 'done':
    case 'finished':
      return 'COMPLETED';
    case 'confirmed':
      return 'CONFIRMED';
    case 'pending':
      return 'PENDING';
    default:
      return 'IN PROGRESS';
  }
}
