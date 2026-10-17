import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';

class BookingHeader extends StatelessWidget {
  const BookingHeader({
    required this.title,
    super.key,
    this.onBack,
    this.leadingIcon,
    this.trailing,
    this.backgroundColor = const Color(0xFFF3F3F5),
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final IconData? leadingIcon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          _HeaderActionButton(
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
            child: Icon(
              leadingIcon ?? Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: const Color(0xFF111216),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111216),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: trailing ?? const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({
    required this.onMenuTap,
    required this.notificationCount,
    super.key,
  });

  final VoidCallback onMenuTap;
  final int notificationCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          _HeaderActionButton(
            onTap: onMenuTap,
            child: const Icon(
              Icons.menu_rounded,
              size: 22,
              color: Color(0xFF111216),
            ),
          ),
          const Expanded(
            child: Text(
              AppTexts.appTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111216),
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (notificationCount > 0)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_rounded,
                        size: 22,
                        color: Color(0xFF111216),
                      ),
                      Positioned(
                        top: -6,
                        right: -8,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFA4A35),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$notificationCount',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  const Icon(
                    Icons.notifications_none_rounded,
                    size: 22,
                    color: Color(0xFF111216),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(width: 44, height: 44, child: Center(child: child)),
      ),
    );
  }
}
