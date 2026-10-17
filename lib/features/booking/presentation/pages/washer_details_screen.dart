import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/network_or_asset_image.dart';
import '../../../home/data/models/washer_card_data.dart';
import '../../data/models/booking_route_arguments.dart';
import '../../data/models/order_summary_draft.dart';
import '../../data/models/service_addon.dart';
import '../../data/models/service_package.dart';
import '../../data/models/washer_details_data.dart';
import '../../data/services/booking_repository.dart';
import '../../utils/booking_formatters.dart';
import '../widgets/booking_selection_widgets.dart';
import '../widgets/expandable_description.dart';
import '../widgets/photo_gallery_viewer.dart';

class WasherDetailsScreen extends StatefulWidget {
  const WasherDetailsScreen({required this.washerId, super.key, this.preview});

  static const String routeName = AppRoutes.washerDetails;

  final String washerId;
  final WasherCardData? preview;

  @override
  State<WasherDetailsScreen> createState() => _WasherDetailsScreenState();
}

class _WasherDetailsScreenState extends State<WasherDetailsScreen> {
  final BookingRepository _bookingRepository = const BookingRepository();

  WasherDetailsData? _details;
  String? _selectedCategory;
  String? _selectedPackageId;
  final Set<String> _selectedAddonIds = <String>{};
  bool _isLoading = true;

  List<String?> _photoUrlsFor(WasherDetailsData details) {
    final List<String?> urls = <String?>[
      details.coverImageUrl,
      details.avatarImageUrl,
      ...details.galleryImageUrls,
    ];
    final List<String?> deduplicated = <String?>[];
    final Set<String> seen = <String>{};
    for (final String? url in urls) {
      if (url == null || url.trim().isEmpty) {
        continue;
      }
      if (seen.add(url)) {
        deduplicated.add(url);
      }
    }
    if (deduplicated.isEmpty) {
      return <String?>[null];
    }
    return deduplicated;
  }

  Future<void> _openPhotos() async {
    final WasherDetailsData? details = _details;
    if (details == null) {
      return;
    }
    await PhotoGalleryViewer.show(
      context: context,
      assetPath: details.imageAsset,
      imageUrls: _photoUrlsFor(details),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final WasherDetailsData details = await _bookingRepository
        .loadWasherDetails(washerId: widget.washerId, preview: widget.preview);
    if (!mounted) {
      return;
    }

    final String selectedCategory = details.vehicleCategories.first;
    final List<ServicePackage> packages = _packagesFor(
      selectedCategory,
      details,
    );
    final ServicePackage selectedPackage = packages.firstWhere(
      (item) => item.isBestOffer,
      orElse: () => packages.isEmpty
          ? const ServicePackage(
              id: '',
              name: '',
              features: <String>[],
              addonIds: <String>[],
              prices: <String, double>{},
              position: 0,
              isBestOffer: false,
              published: false,
            )
          : packages.first,
    );

    setState(() {
      _details = details;
      _selectedCategory = selectedCategory;
      _selectedPackageId = selectedPackage.id.isEmpty
          ? null
          : selectedPackage.id;
      _isLoading = false;
    });
  }

  List<ServicePackage> _packagesFor(
    String category,
    WasherDetailsData details,
  ) {
    return details.packages
        .where((item) => item.supportsCategory(category))
        .where((item) => item.priceFor(category) != null)
        .toList();
  }

  List<ServiceAddon> _addonsFor(String category, WasherDetailsData details) {
    return _addonsForPackage(
      category: category,
      details: details,
      packageId: _selectedPackageId,
    );
  }

  List<ServiceAddon> _addonsForPackage({
    required String category,
    required WasherDetailsData details,
    required String? packageId,
  }) {
    ServicePackage? selectedPackage;
    for (final ServicePackage package in details.packages) {
      if (package.id == packageId) {
        selectedPackage = package;
        break;
      }
    }
    final List<ServiceAddon> addons = details.addons
        .where((item) => item.supportsCategory(category))
        .toList();
    if (selectedPackage == null || selectedPackage.addonIds.isEmpty) {
      return addons;
    }
    return addons
        .where((item) => selectedPackage!.addonIds.contains(item.id))
        .toList();
  }

  ServicePackage? _selectedPackage(WasherDetailsData details) {
    for (final ServicePackage package in details.packages) {
      if (package.id == _selectedPackageId) {
        return package;
      }
    }
    return null;
  }

  double _totalPrice(WasherDetailsData details) {
    final String category =
        _selectedCategory ?? details.vehicleCategories.first;
    final ServicePackage? package = _selectedPackage(details);
    double total = package?.priceFor(category) ?? 0;
    for (final ServiceAddon addon in _addonsFor(category, details)) {
      if (_selectedAddonIds.contains(addon.id)) {
        total += addon.priceFor(category);
      }
    }
    return total;
  }

  void _handleCategoryChanged(String category) {
    final WasherDetailsData? details = _details;
    if (details == null) {
      return;
    }
    final List<ServicePackage> packages = _packagesFor(category, details);
    final String? nextPackageId =
        packages.any((item) => item.id == _selectedPackageId)
        ? _selectedPackageId
        : packages.isEmpty
        ? null
        : (packages.firstWhere(
            (item) => item.isBestOffer,
            orElse: () => packages.first,
          )).id;
    final Set<String> allowedAddonIds = _addonsForPackage(
      category: category,
      details: details,
      packageId: nextPackageId,
    ).map((item) => item.id).toSet();

    setState(() {
      _selectedCategory = category;
      _selectedPackageId = nextPackageId;
      _selectedAddonIds.removeWhere((id) => !allowedAddonIds.contains(id));
    });
  }

  void _openOrderSummary() {
    final WasherDetailsData? details = _details;
    if (details == null) {
      return;
    }
    final String category =
        _selectedCategory ?? details.vehicleCategories.first;
    final ServicePackage? package = _selectedPackage(details);
    if (package == null) {
      return;
    }

    final List<ServiceAddon> selectedAddons = _addonsFor(
      category,
      details,
    ).where((item) => _selectedAddonIds.contains(item.id)).toList();

    Navigator.of(context).pushNamed(
      AppRoutes.orderSummary,
      arguments: OrderSummaryRouteArguments(
        draft: OrderSummaryDraft(
          washerId: details.id,
          washerName: details.name,
          washerSubtitle: details.subtitle,
          washerImageAsset: details.imageAsset,
          washerImageUrl: details.avatarImageUrl ?? details.coverImageUrl,
          washerPhoneNumber: details.phoneNumber,
          vehicleCategory: category,
          selectedPackage: package,
          selectedAddons: selectedAddons,
          totalPrice: _totalPrice(details),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WasherDetailsData? details = _details;
    if (_isLoading || details == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F3F5),
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    final String selectedCategory =
        _selectedCategory ?? details.vehicleCategories.first;
    final List<ServicePackage> packages = _packagesFor(
      selectedCategory,
      details,
    );
    final List<ServiceAddon> addons = _addonsFor(selectedCategory, details);
    final ServicePackage? selectedPackage = _selectedPackage(details);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailsHero(details: details, onOpenPhotos: _openPhotos),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BookingSectionTitle(
                            label: AppTexts.bookingChooseVehicle,
                          ),
                          const SizedBox(height: 10),
                          VehicleCategorySelector(
                            categories: details.vehicleCategories,
                            selectedCategory: selectedCategory,
                            assetPath: details.imageAsset,
                            onChanged: _handleCategoryChanged,
                          ),
                          const SizedBox(height: 18),
                          const BookingSectionTitle(
                            label: AppTexts.bookingChoosePackage,
                          ),
                          const SizedBox(height: 10),
                          if (packages.isEmpty)
                            const EmptyBookingState(
                              message: AppTexts.bookingNoPackages,
                            )
                          else
                            for (final ServicePackage package in packages) ...[
                              ServicePackageCard(
                                package: package,
                                selected: selectedPackage?.id == package.id,
                                price: package.priceFor(selectedCategory) ?? 0,
                                onTap: () {
                                  setState(() {
                                    _selectedPackageId = package.id;
                                    _selectedAddonIds.removeWhere(
                                      (id) =>
                                          package.addonIds.isNotEmpty &&
                                          !package.addonIds.contains(id),
                                    );
                                  });
                                },
                              ),
                              if (package != packages.last)
                                const SizedBox(height: 10),
                            ],
                          const SizedBox(height: 18),
                          const BookingSectionTitle(
                            label: AppTexts.bookingAddons,
                          ),
                          const SizedBox(height: 10),
                          if (addons.isEmpty)
                            const EmptyBookingState(
                              message: AppTexts.bookingNoAddons,
                            )
                          else
                            AddonListCard(
                              children: [
                                for (final ServiceAddon addon in addons) ...[
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: AddonTile(
                                      addon: addon,
                                      selected: _selectedAddonIds.contains(
                                        addon.id,
                                      ),
                                      price: addon.priceFor(selectedCategory),
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedAddonIds.add(addon.id);
                                          } else {
                                            _selectedAddonIds.remove(addon.id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  if (addon != addons.last)
                                    const Divider(
                                      height: 1,
                                      color: Color(0xFFE8EBF0),
                                    ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BookingBottomBar(
              totalLabel: formatEuro(_totalPrice(details)),
              ctaLabel: AppTexts.bookingBookNow,
              enabled: packages.isNotEmpty && selectedPackage != null,
              onPressed: _openOrderSummary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsHero extends StatelessWidget {
  const _DetailsHero({required this.details, required this.onOpenPhotos});

  final WasherDetailsData details;
  final VoidCallback onOpenPhotos;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F3F5),
      child: Column(
        children: [
          SizedBox(
            height: 236,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: 176,
                  width: double.infinity,
                  child: NetworkOrAssetImage(
                    assetPath: details.imageAsset,
                    imageUrl: details.coverImageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  bottom: 52,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.16),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  left: 16,
                  child: _HeroIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 16,
                  child: _HeroIconButton(
                    icon: Icons.more_vert_rounded,
                    onTap: () {},
                  ),
                ),
                Positioned(
                  right: 24,
                  top: 110,
                  child: GestureDetector(
                    onTap: onOpenPhotos,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        AppTexts.bookingPhotos,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 104,
                  child: Container(
                    width: 110,
                    height: 92,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: NetworkOrAssetImage(
                      assetPath: details.imageAsset,
                      imageUrl: details.avatarImageUrl ?? details.coverImageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 122),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111216),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 15,
                                  color: Color(0xFF1A68F5),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    details.subtitle,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF7C8390),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _HeroStatCard(
                      primary: details.ratingLabel,
                      secondary: details.reviewLabel,
                      iconSvg: _starSvg,
                      iconWidth: 17,
                      iconHeight: 16,
                    ),
                    const SizedBox(width: 8),
                    _HeroStatCard(
                      primary: details.rankLabel,
                      secondary: details.badgeLabel,
                      iconSvg: _trophySvg,
                      iconWidth: 18,
                      iconHeight: 18,
                    ),
                    const SizedBox(width: 8),
                    _HeroStatCard(
                      primary: details.locationPrimary,
                      secondary: details.locationSecondary,
                      iconSvg: _locationSvg,
                      iconWidth: 18,
                      iconHeight: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ExpandableDescription(text: details.description),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Center(child: Icon(icon, size: 22, color: Colors.white)),
      ),
    );
  }
}

class _HeroStatCard extends StatelessWidget {
  const _HeroStatCard({
    required this.primary,
    required this.secondary,
    required this.iconSvg,
    required this.iconWidth,
    required this.iconHeight,
  });

  final String primary;
  final String secondary;
  final String iconSvg;
  final double iconWidth;
  final double iconHeight;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.string(
                  iconSvg,
                  width: iconWidth,
                  height: iconHeight,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    primary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111216),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              secondary,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF949AA4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const String _starSvg = '''
<svg width="17" height="16" viewBox="0 0 17 16" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M7.46597 0.557434C7.83278 -0.185812 8.89262 -0.185812 9.25944 0.557434L11.069 4.22392C11.2146 4.51906 11.4962 4.72363 11.8219 4.77096L15.8681 5.35891C16.6883 5.4781 17.0158 6.48607 16.4223 7.0646L13.4945 9.91857C13.2588 10.1483 13.1512 10.4793 13.2069 10.8037L13.898 14.8336C14.0381 15.6505 13.1807 16.2734 12.4471 15.8877L8.82804 13.9851C8.53672 13.8319 8.18868 13.8319 7.89736 13.9851L4.27832 15.8877C3.54469 16.2734 2.68726 15.6505 2.82737 14.8336L3.51855 10.8037C3.57418 10.4793 3.46664 10.1483 3.23095 9.91857L0.303086 7.0646C-0.290431 6.48607 0.0370791 5.4781 0.857299 5.35891L4.90351 4.77096C5.22922 4.72363 5.51078 4.51906 5.65645 4.22392L7.46597 0.557434Z" fill="#888C93"/>
</svg>
''';

const String _trophySvg = '''
<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M13.725 2.7122V2.125C13.725 1.57272 13.2773 1.125 12.725 1.125H5.275C4.72271 1.125 4.275 1.57272 4.275 2.125V2.7122H2.125C1.57271 2.7122 1.125 3.15991 1.125 3.7122L1.125 6.09868C1.125 8.04227 2.61259 9.63793 4.53015 9.89503C4.80496 10.6822 5.29217 11.3823 5.94032 11.9212C6.58847 12.4602 7.3735 12.8181 8.2125 12.957V13.7961C8.2125 14.2043 8.04656 14.5959 7.75119 14.8846C7.45582 15.1733 7.05522 15.3355 6.6375 15.3355H6.61974C6.19462 15.3355 5.85 15.6801 5.85 16.1053C5.85 16.5304 6.19462 16.875 6.61974 16.875H11.3803C11.8054 16.875 12.15 16.5304 12.15 16.1053C12.15 15.6801 11.8054 15.3355 11.3803 15.3355H11.3625C10.9448 15.3355 10.5442 15.1733 10.2488 14.8846C9.95344 14.5959 9.7875 14.2043 9.7875 13.7961V12.957C10.6265 12.8181 11.4115 12.4602 12.0597 11.9212C12.7078 11.3823 13.195 10.6822 13.4698 9.89503C15.3874 9.63793 16.875 8.04227 16.875 6.09868V3.7122C16.875 3.15991 16.4273 2.7122 15.875 2.7122H13.725ZM2.7 6.09868V4.25167H4.275V8.2755C3.81444 8.11634 3.41568 7.82155 3.13362 7.43171C2.85156 7.04188 2.70007 6.57616 2.7 6.09868ZM15.3 6.09868C15.2989 6.57603 15.1471 7.0414 14.8652 7.43117C14.5832 7.82095 14.185 8.1161 13.725 8.27627V4.25167H15.3V6.09868Z" fill="#888C93"/>
</svg>
''';

const String _locationSvg = '''
<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M7.58625 16.3583C7.8645 16.5878 8.15007 16.8053 8.44105 17.0162C8.77495 17.2583 9.22617 17.2599 9.55937 17.0169C9.84993 16.805 10.1348 16.5854 10.4137 16.3583C11.1735 15.7344 11.8885 15.058 12.5535 14.334C14.0865 12.6578 15.75 10.2278 15.75 7.5C15.75 6.61358 15.5754 5.73584 15.2362 4.91689C14.897 4.09794 14.3998 3.35382 13.773 2.72703C13.1462 2.10023 12.4021 1.60303 11.5831 1.26381C10.7642 0.924594 9.88642 0.75 9 0.75C8.11358 0.75 7.23583 0.924594 6.41689 1.26381C5.59794 1.60303 4.85382 2.10023 4.22703 2.72703C3.60023 3.35382 3.10303 4.09794 2.76381 4.91689C2.42459 5.73584 2.25 6.61358 2.25 7.5C2.25 10.2278 3.9135 12.657 5.4465 14.334C6.11146 15.0583 6.82647 15.7342 7.58625 16.3583ZM9 9.9375C8.35353 9.9375 7.73355 9.68069 7.27643 9.22357C6.81931 8.76645 6.5625 8.14647 6.5625 7.5C6.5625 6.85354 6.81931 6.23355 7.27643 5.77643C7.73355 5.31931 8.35353 5.0625 9 5.0625C9.64647 5.0625 10.2665 5.31931 10.7236 5.77643C11.1807 6.23355 11.4375 6.85354 11.4375 7.5C11.4375 8.14647 11.1807 8.76645 10.7236 9.22357C10.2665 9.68069 9.64647 9.9375 9 9.9375Z" fill="#888C93"/>
</svg>
''';
