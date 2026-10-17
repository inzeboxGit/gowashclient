import 'package:flutter/material.dart';

class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({
    required this.text,
    super.key,
    this.trimLines = 3,
  });

  final String text;
  final int trimLines;

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    const TextStyle bodyStyle = TextStyle(
      fontSize: 14,
      height: 1.45,
      color: Color(0xFF4C515B),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: bodyStyle),
          textDirection: TextDirection.ltr,
          maxLines: widget.trimLines,
        )..layout(maxWidth: constraints.maxWidth);

        final bool exceeds = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Text(
                widget.text,
                maxLines: _expanded ? null : widget.trimLines,
                overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: bodyStyle,
              ),
            ),
            if (exceeds)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  child: Text(
                    _expanded ? 'Less' : 'More',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111216),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
