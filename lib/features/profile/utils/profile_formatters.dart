String? readProfileString(Object? value) {
  if (value is String) {
    final String trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
  }
  return null;
}

String initialsFromName(String value) {
  final List<String> parts = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) {
    return 'AA';
  }
  if (parts.length == 1) {
    return parts.first.substring(0, 1).toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String normalizePhoneNumber(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) {
    return '+1$digits';
  }
  if (digits.length == 11 && digits.startsWith('1')) {
    return '+$digits';
  }
  return value.trim();
}

bool isEditablePhoneNumber(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length == 10 || (digits.length == 11 && digits.startsWith('1'));
}

String formatPhoneNumber(String value) {
  final String digits = value.replaceAll(RegExp(r'\D'), '');
  final String normalizedDigits = digits.length == 11 && digits.startsWith('1')
      ? digits.substring(1)
      : digits;

  if (normalizedDigits.length != 10) {
    return value;
  }

  final String areaCode = normalizedDigits.substring(0, 3);
  final String prefix = normalizedDigits.substring(3, 6);
  final String lineNumber = normalizedDigits.substring(6, 10);
  return '($areaCode) $prefix-$lineNumber';
}
