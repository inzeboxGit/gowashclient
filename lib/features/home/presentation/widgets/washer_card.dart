import 'package:flutter/material.dart';

import '../../../../shared/widgets/asset_svg_image.dart';
import '../../data/models/washer_card_data.dart';
import 'home_icons.dart';

class WasherCard extends StatelessWidget {
  const WasherCard({
    required this.data,
    required this.distanceLabel,
    required this.highlighted,
    required this.onDetailsTap,
    super.key,
  });

  final WasherCardData data;
  final String distanceLabel;
  final bool highlighted;
  final VoidCallback onDetailsTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: highlighted
              ? Border.all(color: const Color(0xFF002B80), width: 2)
              : Border.all(color: Colors.white),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              SizedBox(
                height: 72,
                child: Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F6FA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: WasherPreviewImage(data: data),
                      ),
                    ),
                    const SizedBox(width: 17),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF131417),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (data.isVerified) ...[
                                const VerifiedBadgeIcon(size: 18),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  data.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF5F636B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 68,
                child: Row(
                  children: [
                    StatBlock(
                      icon: const Icon(
                        Icons.star_rounded,
                        size: 17,
                        color: Color(0xFF8B8F98),
                      ),
                      top: data.rating,
                      bottom: data.reviews,
                    ),
                    const StatDivider(),
                    StatBlock(
                      icon: const CrownIcon(size: 16, color: Color(0xFF8B8F98)),
                      top: data.rank,
                      bottom: data.badge,
                    ),
                    const StatDivider(),
                    StatBlock(
                      icon: const Icon(
                        Icons.location_on_rounded,
                        size: 17,
                        color: Color(0xFF8B8F98),
                      ),
                      top: distanceLabel,
                      bottom: data.city,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: const Color(0x1A002B80),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onDetailsTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: 44,
                    alignment: Alignment.center,
                    child: const Text(
                      'DETAILS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF23499A),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WasherPreviewImage extends StatelessWidget {
  const WasherPreviewImage({required this.data, super.key});

  final WasherCardData data;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = data.imageUrl;
    if (imageUrl == null) {
      return _fallback();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            _fallback(),
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _fallback();
      },
    );
  }

  Widget _fallback() {
    return AssetSvgImage(assetPath: data.imageAsset, fit: BoxFit.cover);
  }
}

class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 42, color: const Color(0xFFD9D9D9));
  }
}

class StatBlock extends StatelessWidget {
  const StatBlock({
    required this.icon,
    required this.top,
    required this.bottom,
    super.key,
  });

  final Widget icon;
  final String top;
  final String bottom;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                top,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF131417),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bottom,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF888C93)),
          ),
        ],
      ),
    );
  }
}
