import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/app_texts.dart';
import '../../data/models/washer_card_data.dart';
import 'washer_card.dart';

class ResultsSheet extends StatelessWidget {
  const ResultsSheet({
    required this.washers,
    required this.distanceLabelFor,
    required this.firestoreErrorMessage,
    required this.scrollController,
    required this.sheetController,
    required this.userLocation,
    required this.onOpenWasherDetails,
    super.key,
  });

  final List<WasherCardData> washers;
  final String Function(WasherCardData washer) distanceLabelFor;
  final String? firestoreErrorMessage;
  final ScrollController scrollController;
  final DraggableScrollableController sheetController;
  final LatLng? userLocation;
  final ValueChanged<WasherCardData> onOpenWasherDetails;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool showError = firestoreErrorMessage != null && washers.isEmpty;
    final EdgeInsets listPadding = EdgeInsets.fromLTRB(
      16,
      0,
      16,
      14 + MediaQuery.of(context).padding.bottom,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFEF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: listPadding,
        children: [
          const SizedBox(height: 8),
          ResultsSheetHandle(controller: sheetController),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
            child: Row(
              children: [
                Text(
                  AppTexts.homeResultsCount(washers.length),
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFA4A8B1),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      AppTexts.homeClosest,
                      style: textTheme.titleMedium?.copyWith(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    const SortArrowIcon(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (showError)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCEEEB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  firestoreErrorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB5473B),
                  ),
                ),
              ),
            ),
          if (washers.isEmpty && !showError)
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
              child: Text(
                userLocation == null
                    ? AppTexts.homeStartSearch
                    : AppTexts.homeNoFilterResults,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888C93),
                ),
              ),
            ),
          for (int index = 0; index < washers.length; index++) ...[
            WasherCard(
              data: washers[index],
              distanceLabel: distanceLabelFor(washers[index]),
              highlighted: washers[index].isTopWasher,
              onDetailsTap: () => onOpenWasherDetails(washers[index]),
            ),
            if (index != washers.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class SortArrowIcon extends StatelessWidget {
  const SortArrowIcon({super.key});

  static const String _svg = '''
<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M5.84251 6.00001L12.1575 6.00001C12.4068 5.99965 12.6511 6.0699 12.8622 6.20263C13.0732 6.33536 13.2424 6.52514 13.35 6.75001C13.476 7.01682 13.5246 7.31366 13.4901 7.60671C13.4556 7.89976 13.3395 8.17724 13.155 8.40751L9.99751 12.2325C9.8736 12.3755 9.7204 12.4901 9.5483 12.5687C9.37619 12.6473 9.18921 12.688 9.00001 12.688C8.81081 12.688 8.62383 12.6473 8.45172 12.5687C8.27962 12.4901 8.12642 12.3755 8.00251 12.2325L4.84501 8.40751C4.6605 8.17724 4.5444 7.89976 4.50992 7.60671C4.47545 7.31366 4.52399 7.01682 4.65001 6.75001C4.75767 6.52514 4.9268 6.33536 5.13784 6.20263C5.34888 6.0699 5.5932 5.99965 5.84251 6.00001Z" fill="#0C0D0D"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: 18, height: 18);
  }
}

class ResultsSheetHandle extends StatelessWidget {
  const ResultsSheetHandle({required this.controller, super.key});

  final DraggableScrollableController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragUpdate: (details) {
        if (!controller.isAttached) {
          return;
        }
        final double nextSize =
            (controller.size -
                    ((details.primaryDelta ?? 0) /
                        MediaQuery.sizeOf(context).height))
                .clamp(0.12, 0.9);
        controller.jumpTo(nextSize);
      },
      child: SizedBox(
        height: 22,
        child: Center(
          child: Container(
            width: 52,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0x120C0D0D),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ),
    );
  }
}
