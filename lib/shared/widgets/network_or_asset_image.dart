import 'package:flutter/material.dart';

import 'asset_svg_image.dart';

class NetworkOrAssetImage extends StatelessWidget {
  const NetworkOrAssetImage({
    required this.assetPath,
    super.key,
    this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String assetPath;
  final String? imageUrl;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      child = Image.network(
        imageUrl!,
        fit: fit,
        filterQuality: FilterQuality.medium,
        loadingBuilder: (context, image, progress) {
          if (progress == null) {
            return image;
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              _fallback(),
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          );
        },
        errorBuilder: (context, error, stackTrace) => _fallback(),
      );
    } else {
      child = _fallback();
    }

    if (borderRadius == null) {
      return child;
    }

    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _fallback() {
    return AssetSvgImage(assetPath: assetPath, fit: fit);
  }
}
