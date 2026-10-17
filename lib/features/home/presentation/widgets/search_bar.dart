import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/app_texts.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0x120C0D0D)),
          ),
          child: const Row(
            children: [
              SearchBarSearchIcon(),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppTexts.homeSearchHint,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF888C93),
                  ),
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                height: 24,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFDFDFDF),
                ),
              ),
              SizedBox(width: 15),
              SearchBarFilterIcon(),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBarSearchIcon extends StatelessWidget {
  const SearchBarSearchIcon({super.key});

  static const String _svg = '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M9.5 0C14.7467 0 19 4.25329 19 9.5C19 11.6108 18.3101 13.5598 17.1455 15.1367L20.21 16.9854C21.5159 17.7734 21.7358 19.5787 20.6572 20.6572C19.5787 21.7358 17.7734 21.5159 16.9854 20.21L15.1367 17.1455C13.5598 18.3101 11.6108 19 9.5 19C4.25329 19 0 14.7467 0 9.5C3.22129e-08 4.25329 4.25329 3.22139e-08 9.5 0ZM9.5 2C5.35786 2 2 5.35786 2 9.5C2 13.6421 5.35786 17 9.5 17C13.6421 17 17 13.6421 17 9.5C17 5.35786 13.6421 2 9.5 2Z" fill="#888C93"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: 20, height: 20);
  }
}

class SearchBarFilterIcon extends StatelessWidget {
  const SearchBarFilterIcon({super.key});

  static const String _svg = '''
<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M8 14C7.71667 14 7.47933 13.904 7.288 13.712C7.09667 13.52 7.00067 13.2827 7 13C6.99933 12.7173 7.09533 12.48 7.288 12.288C7.48067 12.096 7.718 12 8 12H10C10.2833 12 10.521 12.096 10.713 12.288C10.905 12.48 11.001 12.7173 11 13C10.999 13.2827 10.903 13.5203 10.712 13.713C10.521 13.9057 10.2837 14.0013 10 14H8ZM4 8C3.71667 8 3.47933 7.904 3.288 7.712C3.09667 7.52 3.00067 7.28267 3 7C2.99933 6.71733 3.09533 6.48 3.288 6.288C3.48067 6.096 3.718 6 4 6H14C14.2833 6 14.521 6.096 14.713 6.288C14.905 6.48 15.001 6.71733 15 7C14.999 7.28267 14.903 7.52033 14.712 7.713C14.521 7.90567 14.2837 8.00133 14 8H4ZM1 2C0.716667 2 0.479333 1.904 0.288 1.712C0.0966667 1.52 0.000666667 1.28267 0 1C-0.000666667 0.717333 0.0953333 0.48 0.288 0.288C0.480667 0.096 0.718 0 1 0H17C17.2833 0 17.521 0.096 17.713 0.288C17.905 0.48 18.001 0.717333 18 1C17.999 1.28267 17.903 1.52033 17.712 1.713C17.521 1.90567 17.2837 2.00133 17 2H1Z" fill="#888C93"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_svg, width: 18, height: 18);
  }
}
