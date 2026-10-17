import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetSvgImage extends StatelessWidget {
  const AssetSvgImage({
    required this.assetPath,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  static final Map<String, Future<Uint8List?>> _embeddedRasterCache =
      <String, Future<Uint8List?>>{};

  static Future<Uint8List?> _extractEmbeddedRaster(String assetPath) async {
    final String raw = await rootBundle.loadString(assetPath);
    final RegExp regex = RegExp(
      r'data:image\/(?:png|jpeg|jpg);base64,([A-Za-z0-9+/=]+)',
      caseSensitive: false,
    );
    final RegExpMatch? match = regex.firstMatch(raw);
    if (match == null) {
      return null;
    }

    try {
      return base64Decode(match.group(1)!);
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List?> _embeddedRasterFuture() {
    return _embeddedRasterCache.putIfAbsent(
      assetPath,
      () => _extractEmbeddedRaster(assetPath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _embeddedRasterFuture(),
      builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Image.memory(
            snapshot.data!,
            width: width,
            height: height,
            fit: fit,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          );
        }

        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
        );
      },
    );
  }
}
