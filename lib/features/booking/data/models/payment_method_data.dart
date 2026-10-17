enum PaymentMethodKind { card, googlePay, paypal, unknown }

class PaymentMethodData {
  const PaymentMethodData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    this.isDefault = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final PaymentMethodKind kind;
  final bool isDefault;
}
