import 'package:flutter/material.dart';

import '../../data/models/payment_method_data.dart';

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    required this.method,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final PaymentMethodData method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFF204DA8)
                  : const Color(0xFFE2E5EA),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _PaymentBadge(kind: method.kind),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111216),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9AA0AA),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? const Color(0xFF204DA8)
                    : const Color(0xFFA4A9B2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentBadge extends StatelessWidget {
  const _PaymentBadge({required this.kind});

  final PaymentMethodKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case PaymentMethodKind.googlePay:
        return Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'G',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4285F4),
            ),
          ),
        );
      case PaymentMethodKind.paypal:
        return Container(
          width: 56,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Text(
            'P',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1B67B1),
            ),
          ),
        );
      case PaymentMethodKind.card:
      case PaymentMethodKind.unknown:
        return SizedBox(
          width: 56,
          height: 40,
          child: Stack(
            alignment: Alignment.center,
            children: const [
              Positioned(
                left: 6,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFEB001B),
                ),
              ),
              Positioned(
                right: 6,
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFF79E1B),
                ),
              ),
            ],
          ),
        );
    }
  }
}
