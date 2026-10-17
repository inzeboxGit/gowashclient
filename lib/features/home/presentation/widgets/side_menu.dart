import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../shared/widgets/asset_svg_image.dart';
import '../../data/models/category_data.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    required this.categories,
    required this.selectedTab,
    required this.onCategorySelected,
    required this.onFindWasher,
    required this.onOpenProfile,
    required this.onOpenOrders,
    super.key,
  });

  final List<CategoryData> categories;
  final int selectedTab;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onFindWasher;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenOrders;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width < 340
          ? MediaQuery.of(context).size.width * 0.9
          : 320,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 182,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                    child: const AssetSvgImage(
                      assetPath: 'assets/images/Side_menu.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Color(0x33002B80)),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 50, 32, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                AppTexts.appTitle,
                                style: TextStyle(
                                  fontSize: 28,
                                  height: 1.05,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => Navigator.of(context).pop(),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          AppTexts.homeDrawerTagline,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.1,
                            color: Color(0xD9FFFFFF),
                          ),
                        ),
                        const SizedBox(height: 18),
                        DrawerCategoryTabs(
                          categories: categories,
                          selectedIndex: selectedTab,
                          onSelected: onCategorySelected,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _DrawerItem(
            iconType: _DrawerIconType.myAccount,
            label: AppTexts.homeDrawerMyAccount,
            onTap: onOpenProfile,
          ),
          _DrawerItem(
            iconType: _DrawerIconType.findWasher,
            label: AppTexts.homeDrawerFindWasher,
            onTap: onFindWasher,
          ),
          _DrawerItem(
            iconType: _DrawerIconType.myWashes,
            label: AppTexts.homeDrawerMyWashes,
            onTap: onOpenOrders,
          ),
          const _DrawerItem(
            iconType: _DrawerIconType.help,
            label: AppTexts.homeDrawerHelp,
          ),
          const _DrawerItem(
            iconType: _DrawerIconType.about,
            label: AppTexts.homeDrawerAbout,
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Text(
              AppTexts.homeDrawerFooter,
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA0AA)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({required this.iconType, required this.label, this.onTap});

  final _DrawerIconType iconType;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F2F5))),
      ),
      child: ListTile(
        leading: _DrawerMenuIcon(iconType: iconType),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF101113),
          ),
        ),
        onTap: () {
          Navigator.of(context).pop();
          onTap?.call();
        },
      ),
    );
  }
}

class DrawerCategoryTabs extends StatelessWidget {
  const DrawerCategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<CategoryData> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x14000000),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(categories.length, (index) {
          final bool selected = index == selectedIndex;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelected(index),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    categories[index].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected
                          ? const Color(0xFF101113)
                          : const Color(0xE6FFFFFF),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

enum _DrawerIconType { myAccount, findWasher, myWashes, help, about }

class _DrawerMenuIcon extends StatelessWidget {
  const _DrawerMenuIcon({required this.iconType});

  final _DrawerIconType iconType;

  static const String _myAccountSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M12 8C12.2652 8 12.5195 8.10543 12.707 8.29297C12.8946 8.4805 13 8.73478 13 9C13 9.26522 12.8946 9.5195 12.707 9.70703C12.5195 9.89457 12.2652 10 12 10C11.7348 10 11.4805 9.89457 11.293 9.70703C11.1054 9.5195 11 9.26522 11 9C11 8.73478 11.1054 8.4805 11.293 8.29297C11.4805 8.10543 11.7348 8 12 8Z" fill="#0C0D0D"/>
<path fill-rule="evenodd" clip-rule="evenodd" d="M12 1C18.0751 1 23 5.92487 23 12C23 18.0751 18.0751 23 12 23C5.92487 23 1 18.0751 1 12C1 5.92487 5.92487 1 12 1ZM12 13C10.9391 13 9.92202 13.4217 9.17188 14.1719C8.65977 14.684 8.30024 15.3207 8.12402 16.0107C7.98773 16.5457 8.44787 17 9 17C9.55228 17 9.98035 16.5257 10.2451 16.041C10.3357 15.8753 10.45 15.7219 10.5859 15.5859C10.961 15.2109 11.4696 15 12 15C12.5304 15 13.039 15.2109 13.4141 15.5859C13.55 15.7219 13.6643 15.8753 13.7549 16.041C14.0197 16.5257 14.4477 17 15 17C15.5521 17 16.0123 16.5457 15.876 16.0107C15.6998 15.3207 15.3402 14.684 14.8281 14.1719C14.078 13.4217 13.0609 13 12 13ZM12 6C11.2044 6 10.4415 6.3163 9.87891 6.87891C9.3163 7.44152 9 8.20435 9 9C9 9.79565 9.3163 10.5585 9.87891 11.1211C10.4415 11.6837 11.2044 12 12 12C12.7956 12 13.5585 11.6837 14.1211 11.1211C14.6837 10.5585 15 9.79565 15 9C15 8.20435 14.6837 7.44152 14.1211 6.87891C13.5585 6.3163 12.7956 6 12 6Z" fill="#0C0D0D"/>
</svg>
''';

  static const String _findWasherSvg = '''
<svg width="22" height="22" viewBox="0 0 22 22" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M9.5 0C14.7467 0 19 4.25329 19 9.5C19 11.6108 18.3101 13.5598 17.1455 15.1367L20.21 16.9854C21.5159 17.7734 21.7358 19.5787 20.6572 20.6572C19.5787 21.7358 17.7734 21.5159 16.9854 20.21L15.1367 17.1455C13.5598 18.3101 11.6108 19 9.5 19C4.25329 19 0 14.7467 0 9.5C3.22129e-08 4.25329 4.25329 3.22139e-08 9.5 0ZM9.5 2C5.35786 2 2 5.35786 2 9.5C2 13.6421 5.35786 17 9.5 17C13.6421 17 17 13.6421 17 9.5C17 5.35786 13.6421 2 9.5 2Z" fill="#0C0D0D"/>
</svg>
''';

  static const String _myWashesSvg = '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M11.5 5.75C11.5 7.27499 10.8942 8.73753 9.81586 9.81586C8.73753 10.8942 7.27499 11.5 5.75 11.5C4.22501 11.5 2.76247 10.8942 1.68414 9.81586C0.605802 8.73753 0 7.27499 0 5.75C0 4.22501 0.605802 2.76247 1.68414 1.68414C2.76247 0.605802 4.22501 0 5.75 0C7.27499 0 8.73753 0.605802 9.81586 1.68414C10.8942 2.76247 11.5 4.22501 11.5 5.75ZM16.25 9.863C17.112 9.863 17.9386 9.52059 18.5481 8.9111C19.1576 8.3016 19.5 7.47495 19.5 6.613C19.5 5.75105 19.1576 4.9244 18.5481 4.3149C17.9386 3.70541 17.112 3.363 16.25 3.363C15.388 3.363 14.5614 3.70541 13.9519 4.3149C13.3424 4.9244 13 5.75105 13 6.613C13 7.47495 13.3424 8.3016 13.9519 8.9111C14.5614 9.52059 15.388 9.863 16.25 9.863ZM17.469 15.25C17.469 16.3772 17.0212 17.4582 16.2242 18.2552C15.4272 19.0522 14.3462 19.5 13.219 19.5C12.0918 19.5 11.0108 19.0522 10.2138 18.2552C9.41677 17.4582 8.969 16.3772 8.969 15.25C8.969 14.1228 9.41677 13.0418 10.2138 12.2448C11.0108 11.4478 12.0918 11 13.219 11C14.3462 11 15.4272 11.4478 16.2242 12.2448C17.0212 13.0418 17.469 14.1228 17.469 15.25Z" fill="#0C0D0D"/>
</svg>
''';

  static const String _helpSvg = '''
<svg width="20" height="23" viewBox="0 0 20 23" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M10 23L7 20H2C1.45 20 0.979333 19.8043 0.588 19.413C0.196667 19.0217 0.000666667 18.5507 0 18V2C0 1.45 0.196 0.979333 0.588 0.588C0.98 0.196667 1.45067 0.000666667 2 0H18C18.55 0 19.021 0.196 19.413 0.588C19.805 0.98 20.0007 1.45067 20 2V18C20 18.55 19.8043 19.021 19.413 19.413C19.0217 19.805 18.5507 20.0007 18 20H13L10 23ZM9.9 16C10.25 16 10.546 15.879 10.788 15.637C11.03 15.395 11.1507 15.0993 11.15 14.75C11.1493 14.4007 11.0283 14.1047 10.787 13.862C10.5457 13.6193 10.25 13.4987 9.9 13.5C9.55 13.5013 9.254 13.6223 9.012 13.863C8.77 14.1037 8.64933 14.3993 8.65 14.75C8.65067 15.1007 8.77167 15.3967 9.013 15.638C9.25433 15.8793 9.55 16 9.9 16ZM9 12.15H10.85C10.85 11.8667 10.8627 11.625 10.888 11.425C10.9133 11.225 10.9673 11.0333 11.05 10.85C11.1327 10.6667 11.2367 10.496 11.362 10.338C11.4873 10.18 11.6667 9.984 11.9 9.75C12.4833 9.16667 12.896 8.679 13.138 8.287C13.38 7.895 13.5007 7.44933 13.5 6.95C13.5 6.06667 13.2 5.35433 12.6 4.813C12 4.27167 11.1917 4.00067 10.175 4C9.25833 4 8.47933 4.225 7.838 4.675C7.19667 5.125 6.75067 5.75 6.5 6.55L8.15 7.2C8.26667 6.75 8.5 6.38767 8.85 6.113C9.2 5.83833 9.60833 5.70067 10.075 5.7C10.525 5.7 10.9 5.821 11.2 6.063C11.5 6.305 11.65 6.62567 11.65 7.025C11.65 7.30833 11.5583 7.60833 11.375 7.925C11.1917 8.24167 10.8833 8.59167 10.45 8.975C10.1667 9.20833 9.93733 9.43767 9.762 9.663C9.58667 9.88833 9.441 10.1257 9.325 10.375C9.209 10.6243 9.12567 10.887 9.075 11.163C9.02433 11.439 8.99933 11.768 9 12.15Z" fill="#0C0D0D"/>
</svg>
''';

  static const String _aboutSvg = '''
<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path fill-rule="evenodd" clip-rule="evenodd" d="M3 20H17C18.126 20 18.926 19.509 19.412 18.834C19.86 18.211 20 17.494 20 17V11C20 10.7348 19.8946 10.4804 19.7071 10.2929C19.5196 10.1054 19.2652 10 19 10H16V3C16 2.20435 15.6839 1.44129 15.1213 0.87868C14.5587 0.316071 13.7956 0 13 0H3C2.20435 0 1.44129 0.316071 0.87868 0.87868C0.316071 1.44129 0 2.20435 0 3V17C0 17.493 0.14 18.211 0.588 18.834C1.074 19.51 1.874 20 3 20ZM17 12C17.2652 12 17.5196 12.1054 17.7071 12.2929C17.8946 12.4804 18 12.7348 18 13V17C18 17.2652 17.8946 17.5196 17.7071 17.7071C17.5196 17.8946 17.2652 18 17 18C16.7348 18 16.4804 17.8946 16.2929 17.7071C16.1054 17.5196 16 17.2652 16 17V13C16 12.7348 16.1054 12.4804 16.2929 12.2929C16.4804 12.1054 16.7348 12 17 12ZM7 8C7 7.73478 7.10536 7.48043 7.29289 7.29289C7.48043 7.10536 7.73478 7 8 7C8.26522 7 8.51957 7.10536 8.70711 7.29289C8.89464 7.48043 9 7.73478 9 8C9 8.26522 8.89464 8.51957 8.70711 8.70711C8.51957 8.89464 8.26522 9 8 9C7.73478 9 7.48043 8.89464 7.29289 8.70711C7.10536 8.51957 7 8.26522 7 8ZM8 5C7.20435 5 6.44129 5.31607 5.87868 5.87868C5.31607 6.44129 5 7.20435 5 8C5 8.79565 5.31607 9.55871 5.87868 10.1213C6.44129 10.6839 7.20435 11 8 11C8.79565 11 9.55871 10.6839 10.1213 10.1213C10.6839 9.55871 11 8.79565 11 8C11 7.20435 10.6839 6.44129 10.1213 5.87868C9.55871 5.31607 8.79565 5 8 5ZM5 13C4.73478 13 4.48043 13.1054 4.29289 13.2929C4.10536 13.4804 4 13.7348 4 14C4 14.2652 4.10536 14.5196 4.29289 14.7071C4.48043 14.8946 4.73478 15 5 15H11C11.2652 15 11.5196 14.8946 11.7071 14.7071C11.8946 14.5196 12 14.2652 12 14C12 13.7348 11.8946 13.4804 11.7071 13.2929C11.5196 13.1054 11.2652 13 11 13H5Z" fill="#0C0D0D"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    switch (iconType) {
      case _DrawerIconType.myAccount:
        return SvgPicture.string(_myAccountSvg, width: 24, height: 24);
      case _DrawerIconType.findWasher:
        return SvgPicture.string(_findWasherSvg, width: 22, height: 22);
      case _DrawerIconType.myWashes:
        return SvgPicture.string(_myWashesSvg, width: 20, height: 20);
      case _DrawerIconType.help:
        return SvgPicture.string(_helpSvg, width: 20, height: 23);
      case _DrawerIconType.about:
        return SvgPicture.string(_aboutSvg, width: 20, height: 20);
    }
  }
}
