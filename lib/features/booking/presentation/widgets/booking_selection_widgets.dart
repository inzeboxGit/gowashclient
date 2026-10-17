import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../shared/widgets/network_or_asset_image.dart';
import '../../data/models/service_addon.dart';
import '../../data/models/service_package.dart';
import '../../utils/booking_formatters.dart';

class BookingSectionTitle extends StatelessWidget {
  const BookingSectionTitle({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFF8E949E),
        letterSpacing: 0.4,
      ),
    );
  }
}

class VehicleCategorySelector extends StatelessWidget {
  const VehicleCategorySelector({
    required this.categories,
    required this.selectedCategory,
    required this.assetPath,
    super.key,
    this.onChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final String assetPath;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Center(
              child: NetworkOrAssetImage(
                assetPath: assetPath,
                fit: BoxFit.contain,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F1F4),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: categories.map((category) {
                final bool selected =
                    category.trim().toLowerCase() ==
                    selectedCategory.trim().toLowerCase();
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Material(
                      color: selected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        onTap: onChanged == null
                            ? null
                            : () => onChanged!(category),
                        borderRadius: BorderRadius.circular(9),
                        child: Center(
                          child: Text(
                            formatVehicleCategory(category).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: selected
                                  ? const Color(0xFF111216)
                                  : const Color(0xFF969CA6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class ServicePackageCard extends StatelessWidget {
  const ServicePackageCard({
    required this.package,
    required this.selected,
    required this.price,
    required this.onTap,
    super.key,
  });

  final ServicePackage package;
  final bool selected;
  final double price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? const Color(0xFF204DA8)
        : const Color(0xFFE2E5EA);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF204DA8)
                            : const Color(0xFFB8BDC6),
                        width: 1.5,
                      ),
                    ),
                    child: selected
                        ? const Center(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Color(0xFF204DA8),
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox(width: 8, height: 8),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      package.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111216),
                      ),
                    ),
                  ),
                  if (package.isBestOffer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF204DA8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        AppTexts.bookingBestOffer,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Text(
                    formatEuro(price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF204DA8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE6E9EE), height: 1),
              const SizedBox(height: 14),
              for (final String feature in package.features) ...[
                _FeatureRow(label: feature),
                if (feature != package.features.last) const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddonTile extends StatelessWidget {
  const AddonTile({
    required this.addon,
    required this.selected,
    required this.price,
    required this.onChanged,
    super.key,
  });

  final ServiceAddon addon;
  final bool selected;
  final double price;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F3F6),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            _iconForAddon(addon),
            size: 18,
            color: const Color(0xFF7F8692),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            addon.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111216),
            ),
          ),
        ),
        Text(
          formatEuro(price),
          style: TextStyle(
            fontSize: 16,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            color: selected ? const Color(0xFF111216) : const Color(0xFF8E949E),
          ),
        ),
        const SizedBox(width: 10),
        Switch.adaptive(
          value: selected,
          activeThumbColor: const Color(0xFF61CC73),
          activeTrackColor: const Color(0xFFBCEBC4),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFE4E6EB),
          onChanged: onChanged,
        ),
      ],
    );
  }

  IconData _iconForAddon(ServiceAddon addon) {
    final String key = (addon.iconKey ?? addon.name).toLowerCase();
    if (key.contains('engine')) {
      return Icons.settings_rounded;
    }
    if (key.contains('leather')) {
      return Icons.chair_alt_rounded;
    }
    if (key.contains('seat')) {
      return Icons.event_seat_rounded;
    }
    if (key.contains('plastic')) {
      return Icons.auto_fix_high_rounded;
    }
    if (key.contains('pet') || key.contains('hair')) {
      return Icons.pets_rounded;
    }
    return Icons.add_circle_outline_rounded;
  }
}

class AddonListCard extends StatelessWidget {
  const AddonListCard({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class BookingBottomBar extends StatelessWidget {
  const BookingBottomBar({
    required this.totalLabel,
    required this.ctaLabel,
    required this.onPressed,
    super.key,
    this.isBusy = false,
    this.enabled = true,
  });

  final String totalLabel;
  final String ctaLabel;
  final VoidCallback? onPressed;
  final bool isBusy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool canTap = enabled && !isBusy && onPressed != null;
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        12,
        14,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F3F5),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    AppTexts.bookingTotal,
                    style: TextStyle(fontSize: 12, color: Color(0xFF959CA6)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalLabel,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF204DA8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 64,
              child: ElevatedButton(
                onPressed: canTap ? onPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF111216),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFB7BBC4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        ctaLabel,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyBookingState extends StatelessWidget {
  const EmptyBookingState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF7F8692),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_rounded, size: 16, color: Color(0xFF204DA8)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label.replaceFirst(RegExp(r'^[✓\s]+'), ''),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F3440),
            ),
          ),
        ),
      ],
    );
  }
}
