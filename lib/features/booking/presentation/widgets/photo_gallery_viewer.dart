import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/widgets/network_or_asset_image.dart';

class PhotoGalleryViewer extends StatefulWidget {
  const PhotoGalleryViewer({
    required this.assetPath,
    required this.imageUrls,
    super.key,
    this.initialIndex = 0,
  });

  final String assetPath;
  final List<String?> imageUrls;
  final int initialIndex;

  static Future<void> show({
    required BuildContext context,
    required String assetPath,
    required List<String?> imageUrls,
    int initialIndex = 0,
  }) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close photos',
      barrierColor: Colors.black.withValues(alpha: 0.45),
      pageBuilder: (context, animation, secondaryAnimation) {
        return PhotoGalleryViewer(
          assetPath: assetPath,
          imageUrls: imageUrls,
          initialIndex: initialIndex,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }

  @override
  State<PhotoGalleryViewer> createState() => _PhotoGalleryViewerState();
}

class _PhotoGalleryViewerState extends State<PhotoGalleryViewer> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    final int maxIndex = widget.imageUrls.isEmpty ? 0 : widget.imageUrls.length - 1;
    _currentIndex = widget.initialIndex.clamp(0, maxIndex);
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String?> images = widget.imageUrls.isEmpty
        ? <String?>[null]
        : widget.imageUrls;

    return Material(
      color: Colors.transparent,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(color: Colors.black.withValues(alpha: 0.58)),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${_currentIndex + 1}/${images.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 38),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: AspectRatio(
                              aspectRatio: 0.68,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: NetworkOrAssetImage(
                                  assetPath: widget.assetPath,
                                  imageUrl: images[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
