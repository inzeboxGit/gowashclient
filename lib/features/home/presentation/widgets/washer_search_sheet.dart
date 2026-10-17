import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../data/models/washer_card_data.dart';

class WasherSearchSheet extends StatefulWidget {
  const WasherSearchSheet({
    required this.washers,
    required this.distanceLabelFor,
    super.key,
  });

  final List<WasherCardData> washers;
  final String Function(WasherCardData washer) distanceLabelFor;

  @override
  State<WasherSearchSheet> createState() => _WasherSearchSheetState();
}

class _WasherSearchSheetState extends State<WasherSearchSheet> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<WasherCardData> get _results {
    if (_query.trim().isEmpty) {
      return widget.washers;
    }
    final String query = _query.trim().toLowerCase();
    return widget.washers.where((washer) {
      return washer.title.toLowerCase().contains(query) ||
          washer.city.toLowerCase().contains(query) ||
          washer.subtitle.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<WasherCardData> results = _results;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0x120C0D0D),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: AppTexts.homeSearchPrompt,
                    hintStyle: const TextStyle(color: Color(0xFF888C93)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF888C93),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7F7F8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              Flexible(
                child: results.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.fromLTRB(20, 10, 20, 28),
                        child: Text(
                          AppTexts.homeNoWasherMatch,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF888C93),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                        itemCount: results.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final WasherCardData washer = results[index];
                          return Material(
                            color: const Color(0xFFF7F7F8),
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onTap: () => Navigator.of(context).pop(washer),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: washer.isTopWasher
                                      ? const Color(0xFF143C94)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color(0x120C0D0D),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.local_car_wash_rounded,
                                  size: 20,
                                  color: washer.isTopWasher
                                      ? Colors.white
                                      : const Color(0xFF143C94),
                                ),
                              ),
                              title: Text(
                                washer.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF131417),
                                ),
                              ),
                              subtitle: Text(
                                '${widget.distanceLabelFor(washer)} • ${washer.city}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF888C93),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.north_east_rounded,
                                color: Color(0xFF143C94),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
