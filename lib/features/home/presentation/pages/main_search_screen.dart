import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../booking/data/models/booking_route_arguments.dart';
import '../../data/models/category_data.dart';
import '../../data/models/map_filter_type.dart';
import '../../data/models/washer_card_data.dart';
import '../../data/services/washer_repository.dart';
import '../widgets/home_icons.dart';
import '../widgets/home_map.dart';
import '../widgets/results_sheet.dart';
import '../widgets/search_bar.dart';
import '../widgets/side_menu.dart';
import '../widgets/washer_search_sheet.dart';

class MainSearchScreen extends StatefulWidget {
  const MainSearchScreen({super.key});

  static const String routeName = AppRoutes.mainSearch;

  @override
  State<MainSearchScreen> createState() => _MainSearchScreenState();
}

class _MainSearchScreenState extends State<MainSearchScreen> {
  _MainSearchScreenState() : _washerRepository = const WasherRepository();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final WasherRepository _washerRepository;

  StreamSubscription<List<WasherCardData>>? _washerSubscription;
  int _selectedTab = 0;
  int _locationRequestToken = 0;
  int _mapFocusToken = 0;
  int _routeRequestToken = 0;
  MapFilterType _activeFilter = MapFilterType.none;
  String? _focusedWasherId;
  String? _routedWasherId;
  LatLng? _userLocation;
  List<WasherCardData> _washers = <WasherCardData>[];
  String? _firestoreErrorMessage;

  static const List<CategoryData> _categories = [
    CategoryData(
      label: AppTexts.homeCategoryCar,
      icon: Icons.local_car_wash_rounded,
    ),
    CategoryData(
      label: AppTexts.homeCategoryInterior,
      icon: Icons.weekend_rounded,
    ),
    CategoryData(
      label: AppTexts.homeCategoryExterior,
      icon: Icons.house_siding_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToWashers();
  }

  @override
  void dispose() {
    _washerSubscription?.cancel();
    _sheetController.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (kDebugMode) {
      _subscribeToWashers();
    }
  }

  void _subscribeToWashers() {
    if (!_washerRepository.usesFirestoreBackend) {
      return;
    }

    _washerSubscription?.cancel();
    _washerSubscription = _washerRepository.watchWashers().listen(
      (washers) {
        if (!mounted) {
          return;
        }
        setState(() {
          _firestoreErrorMessage = null;
          _washers = washers;
        });
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Failed to load washers from Firestore: $error');
        if (!mounted) {
          return;
        }
        final bool hasExistingWashers = _washers.isNotEmpty;
        setState(() {
          _firestoreErrorMessage = hasExistingWashers
              ? null
              : AppTexts.homeFirestoreLoadFailed;
        });
      },
    );
  }

  List<WasherCardData> get _orderedWashers {
    final List<WasherCardData> washers = List<WasherCardData>.of(_washers);
    if (_userLocation == null) {
      return washers;
    }

    washers.sort((a, b) {
      return _distanceFromUser(a).compareTo(_distanceFromUser(b));
    });
    return washers;
  }

  List<WasherCardData> get _visibleWashers {
    final List<WasherCardData> washers = _orderedWashers;
    switch (_activeFilter) {
      case MapFilterType.none:
        return washers;
      case MapFilterType.topWasher:
        return washers.where((washer) => washer.isTopWasher).toList();
      case MapFilterType.withinFiveKm:
        if (_userLocation == null) {
          return <WasherCardData>[];
        }
        return washers
            .where((washer) => _distanceFromUser(washer) <= 5000)
            .toList();
      case MapFilterType.verified:
        return washers.where((washer) => washer.isVerified).toList();
      case MapFilterType.availableNow:
        return washers.where((washer) => washer.isAvailable).toList();
    }
  }

  double _distanceFromUser(WasherCardData washer) {
    final LatLng? userLocation = _userLocation;
    if (userLocation == null) {
      return double.infinity;
    }

    return Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      washer.point.latitude,
      washer.point.longitude,
    );
  }

  String _distanceLabelFor(WasherCardData washer) {
    final double meters = _distanceFromUser(washer);
    if (!meters.isFinite) {
      return washer.distance;
    }

    if (meters < 1000) {
      return '${meters.round()} m';
    }

    final double kilometers = meters / 1000;
    final int fractionDigits = kilometers < 10 ? 1 : 0;
    return '${kilometers.toStringAsFixed(fractionDigits)} km';
  }

  void _startWasherSearch() {
    if (!mounted) {
      return;
    }
    setState(() {
      _locationRequestToken++;
    });
  }

  void _focusWasher(WasherCardData washer) {
    if (!mounted) {
      return;
    }
    setState(() {
      _focusedWasherId = washer.id;
      _mapFocusToken++;
    });
  }

  void _showRouteToWasher(WasherCardData washer) {
    if (!mounted) {
      return;
    }
    setState(() {
      _activeFilter = MapFilterType.none;
      _focusedWasherId = washer.id;
      _routedWasherId = washer.id;
      _mapFocusToken++;
      _routeRequestToken++;
    });
  }

  void _openWasherDetails(WasherCardData washer) {
    Navigator.of(context).pushNamed(
      AppRoutes.washerDetails,
      arguments: WasherDetailsRouteArguments(
        washerId: washer.id,
        preview: washer,
      ),
    );
  }

  void _toggleFilter(MapFilterType filter) {
    final MapFilterType nextFilter = _activeFilter == filter
        ? MapFilterType.none
        : filter;
    if (nextFilter == MapFilterType.withinFiveKm && _userLocation == null) {
      _startWasherSearch();
    }
    setState(() {
      _activeFilter = nextFilter;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || nextFilter == MapFilterType.none) {
        return;
      }
      final List<WasherCardData> visibleWashers = _visibleWashers;
      if (visibleWashers.isNotEmpty) {
        _focusWasher(visibleWashers.first);
      }
    });
  }

  Future<void> _handleSearchTap() async {
    final WasherCardData? selectedWasher =
        await showModalBottomSheet<WasherCardData>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return WasherSearchSheet(
              washers: _orderedWashers,
              distanceLabelFor: _distanceLabelFor,
            );
          },
        );
    if (!mounted || selectedWasher == null) {
      return;
    }
    _showRouteToWasher(selectedWasher);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<WasherCardData> visibleWashers = _visibleWashers;

    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        categories: _categories,
        selectedTab: _selectedTab,
        onCategorySelected: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        onFindWasher: _startWasherSearch,
        onOpenProfile: () {
          Navigator.of(context).pushNamed(AppRoutes.profile);
        },
        onOpenOrders: () {
          Navigator.of(context).pushNamed(AppRoutes.orders);
        },
      ),
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu_rounded),
                  ),
                  Expanded(
                    child: Text(
                      AppTexts.appTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                    child: const SizedBox(
                      width: 68,
                      height: 48,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NotificationCountIcon(),
                          SizedBox(width: 9),
                          NotificationBellIcon(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: HomeSearchBar(onTap: _handleSearchTap),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: HomeMap(
                      washers: visibleWashers,
                      locationRequestToken: _locationRequestToken,
                      focusRequestToken: _mapFocusToken,
                      routeRequestToken: _routeRequestToken,
                      focusedWasherId: _focusedWasherId,
                      routedWasherId: _routedWasherId,
                      activeFilter: _activeFilter,
                      onUserLocationChanged: (location) {
                        if (_userLocation == location) {
                          return;
                        }
                        setState(() {
                          _userLocation = location;
                        });
                        if (_activeFilter != MapFilterType.none) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) {
                              return;
                            }
                            final List<WasherCardData> visibleAfterUpdate =
                                _visibleWashers;
                            if (visibleAfterUpdate.isNotEmpty) {
                              _focusWasher(visibleAfterUpdate.first);
                            }
                          });
                        }
                      },
                      onFilterSelected: _toggleFilter,
                      onWasherTap: _showRouteToWasher,
                    ),
                  ),
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 0.45,
                    minChildSize: 0.12,
                    maxChildSize: 0.9,
                    snap: true,
                    snapSizes: const [0.12, 0.45, 0.9],
                    builder: (context, scrollController) {
                      return ResultsSheet(
                        washers: visibleWashers,
                        distanceLabelFor: _distanceLabelFor,
                        firestoreErrorMessage: _firestoreErrorMessage,
                        scrollController: scrollController,
                        sheetController: _sheetController,
                        userLocation: _userLocation,
                        onOpenWasherDetails: _openWasherDetails,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
