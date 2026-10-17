import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/utils/app_runtime.dart';
import '../../data/models/map_filter_type.dart';
import '../../data/models/route_preview.dart';
import '../../data/models/washer_card_data.dart';
import '../../data/services/directions_service.dart';
import 'home_icons.dart';

class MapFilterRow extends StatelessWidget {
  const MapFilterRow({
    required this.activeFilter,
    required this.onFilterSelected,
    super.key,
  });

  final MapFilterType activeFilter;
  final ValueChanged<MapFilterType> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChipButton(
            label: AppTexts.homeFilterTopWasher,
            icon: const CrownIcon(size: 16),
            background: const Color(0xFF0E1116),
            foreground: Colors.white,
            width: 138,
            selected: activeFilter == MapFilterType.topWasher,
            onTap: () => onFilterSelected(MapFilterType.topWasher),
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: AppTexts.homeFilterDistance,
            icon: const Icon(
              Icons.location_on_rounded,
              size: 16,
              color: Color(0xFF8B8F98),
            ),
            background: Colors.white,
            foreground: const Color(0xFF111216),
            width: 86,
            blurBackground: true,
            selected: activeFilter == MapFilterType.withinFiveKm,
            onTap: () => onFilterSelected(MapFilterType.withinFiveKm),
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: AppTexts.homeFilterVerified,
            icon: const VerifiedBadgeIcon(size: 16),
            background: Colors.white,
            foreground: const Color(0xFF111216),
            width: 106,
            blurBackground: true,
            selected: activeFilter == MapFilterType.verified,
            onTap: () => onFilterSelected(MapFilterType.verified),
          ),
          const SizedBox(width: 8),
          FilterChipButton(
            label: AppTexts.homeFilterAvailableNow,
            icon: const AvailableNowIcon(),
            background: Colors.white,
            foreground: const Color(0xFF111216),
            width: 170,
            blurBackground: true,
            selected: activeFilter == MapFilterType.availableNow,
            onTap: () => onFilterSelected(MapFilterType.availableNow),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

class FilterChipButton extends StatelessWidget {
  const FilterChipButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    super.key,
    this.width,
    this.blurBackground = false,
    this.selected = false,
  });

  final String label;
  final Widget icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final double? width;
  final bool blurBackground;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Widget chip = Container(
      width: width,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: selected
            ? Border.all(
                color: background == Colors.white
                    ? const Color(0xFF143C94)
                    : const Color(0x66FFFFFF),
              )
            : null,
        boxShadow: background == Colors.white
            ? const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          icon,
          const SizedBox(width: 6),
          if (width == null)
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            )
          else
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ),
        ],
      ),
    );

    if (!blurBackground) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: chip,
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
          child: chip,
        ),
      ),
    );
  }
}

class HomeMap extends StatefulWidget {
  const HomeMap({
    required this.washers,
    required this.locationRequestToken,
    required this.focusRequestToken,
    required this.routeRequestToken,
    required this.focusedWasherId,
    required this.routedWasherId,
    required this.activeFilter,
    required this.onUserLocationChanged,
    required this.onFilterSelected,
    required this.onWasherTap,
    super.key,
  });

  final List<WasherCardData> washers;
  final int locationRequestToken;
  final int focusRequestToken;
  final int routeRequestToken;
  final String? focusedWasherId;
  final String? routedWasherId;
  final MapFilterType activeFilter;
  final ValueChanged<LatLng> onUserLocationChanged;
  final ValueChanged<MapFilterType> onFilterSelected;
  final ValueChanged<WasherCardData> onWasherTap;

  @override
  State<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends State<HomeMap> with WidgetsBindingObserver {
  _HomeMapState() : _directionsService = const DirectionsService();

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(31.6295, -7.9811),
    zoom: 14.2,
  );
  static const Size _washerMarkerLogicalSize = Size(160, 63);
  static const double _markerPixelRatio = 3;
  static const Size _userMarkerLogicalSize = Size(20, 20);

  final DirectionsService _directionsService;

  GoogleMapController? _mapController;
  LatLng? _currentUserLocation;
  final Map<String, BitmapDescriptor> _washerMarkerIcons =
      <String, BitmapDescriptor>{};
  BitmapDescriptor? _userLocationMarkerIcon;
  Polyline? _routePolyline;
  String? _routeSummary;
  bool _isLoadingRoute = false;

  bool get _usesGoogleMap => AppRuntime.supportsNativeGoogleMap;

  @override
  void initState() {
    super.initState();
    if (_usesGoogleMap) {
      WidgetsBinding.instance.addObserver(this);
      _prepareMarkerIcons();
    }
  }

  @override
  void dispose() {
    if (_usesGoogleMap) {
      WidgetsBinding.instance.removeObserver(this);
    }
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _usesGoogleMap &&
        widget.locationRequestToken > 0) {
      _resolveUserLocation();
    }
  }

  @override
  void didUpdateWidget(covariant HomeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.washers != widget.washers && _usesGoogleMap) {
      _prepareMarkerIcons();
      if (_washerById(widget.routedWasherId) == null && mounted) {
        setState(() {
          _routePolyline = null;
          _routeSummary = null;
          _isLoadingRoute = false;
        });
      }
      if (_currentUserLocation == null && widget.washers.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusOnClosestWasher();
        });
      }
    }
    if (oldWidget.locationRequestToken != widget.locationRequestToken &&
        _usesGoogleMap) {
      _resolveUserLocation(interactive: true);
    }
    if (oldWidget.focusRequestToken != widget.focusRequestToken &&
        _usesGoogleMap) {
      _focusOnRequestedWasher();
    }
    if (oldWidget.routeRequestToken != widget.routeRequestToken &&
        _usesGoogleMap) {
      _drawRouteToRequestedWasher(interactive: true);
    }
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusOnUserLocation();
      _focusOnClosestWasher();
    });
  }

  Future<void> _resolveUserLocation({bool interactive = false}) async {
    if (!_usesGoogleMap) {
      return;
    }

    if (_currentUserLocation != null) {
      await _focusOnUserLocation();
      return;
    }

    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (interactive) {
        await _showLocationServicesDialog();
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && interactive) {
      final bool shouldContinue = await _showLocationPermissionDialog();
      if (!shouldContinue) {
        return;
      }
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (interactive) {
        await _showLocationSettingsDialog();
      }
      return;
    }

    final Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    final LatLng location = LatLng(position.latitude, position.longitude);

    if (!mounted) {
      return;
    }

    setState(() {
      _currentUserLocation = location;
    });
    widget.onUserLocationChanged(location);
    await _focusOnUserLocation();
    if (widget.routedWasherId != null) {
      await _drawRouteToRequestedWasher();
    }
  }

  Future<bool> _showLocationPermissionDialog() async {
    if (!mounted) {
      return false;
    }
    final bool? accepted = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.homeLocationAllowTitle),
          content: const Text(AppTexts.homeLocationAllowContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(AppTexts.homeLocationNotNow),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(AppTexts.homeContinue),
            ),
          ],
        );
      },
    );
    return accepted ?? false;
  }

  Future<void> _showLocationServicesDialog() async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.homeLocationServicesTitle),
          content: const Text(AppTexts.homeLocationServicesContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppTexts.homeLater),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openLocationSettings();
              },
              child: const Text(AppTexts.homeOpenSettings),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationSettingsDialog() async {
    if (!mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppTexts.homeLocationBlockedTitle),
          content: const Text(AppTexts.homeLocationBlockedContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppTexts.homeLater),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text(AppTexts.homeAppSettings),
            ),
          ],
        );
      },
    );
  }

  Future<void> _focusOnUserLocation() async {
    final GoogleMapController? controller = _mapController;
    final LatLng? location = _currentUserLocation;
    if (controller == null || location == null) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 13.8),
      ),
    );
  }

  Future<void> _focusOnClosestWasher() async {
    final GoogleMapController? controller = _mapController;
    if (!_usesGoogleMap ||
        controller == null ||
        !mounted ||
        _currentUserLocation != null ||
        widget.washers.isEmpty) {
      return;
    }

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: widget.washers.first.point, zoom: 13.4),
      ),
    );
  }

  Future<void> _focusOnRequestedWasher() async {
    final String? washerId = widget.focusedWasherId;
    final GoogleMapController? controller = _mapController;
    if (washerId == null || controller == null) {
      return;
    }
    WasherCardData? washer;
    for (final WasherCardData candidate in widget.washers) {
      if (candidate.id == washerId) {
        washer = candidate;
        break;
      }
    }
    if (washer == null) {
      return;
    }
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: washer.point, zoom: 14.8),
      ),
    );
  }

  Future<void> _drawRouteToRequestedWasher({bool interactive = false}) async {
    if (!_usesGoogleMap) {
      return;
    }

    final WasherCardData? washer = _washerById(widget.routedWasherId);
    if (washer == null) {
      if (mounted) {
        setState(() {
          _routePolyline = null;
          _routeSummary = null;
          _isLoadingRoute = false;
        });
      }
      return;
    }

    if (_currentUserLocation == null) {
      await _resolveUserLocation(interactive: interactive);
    }
    final LatLng? origin = _currentUserLocation;
    final GoogleMapController? controller = _mapController;
    if (origin == null || controller == null) {
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingRoute = true;
      });
    }

    try {
      final RoutePreview preview = await _directionsService.fetchRoutePreview(
        origin: origin,
        destination: washer.point,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _routePolyline = Polyline(
          polylineId: const PolylineId('washer-route'),
          points: preview.points,
          color: const Color(0xFF143C94),
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
        );
        _routeSummary = preview.summary;
        _isLoadingRoute = false;
      });
      await _fitRouteBounds(preview.points, origin, washer.point);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingRoute = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not draw directions. Enable Routes API for this Google Maps key.',
          ),
        ),
      );
    }
  }

  WasherCardData? _washerById(String? id) {
    if (id == null) {
      return null;
    }
    for (final WasherCardData washer in widget.washers) {
      if (washer.id == id) {
        return washer;
      }
    }
    return null;
  }

  Future<void> _fitRouteBounds(
    List<LatLng> points,
    LatLng origin,
    LatLng destination,
  ) async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) {
      return;
    }

    double minLat = origin.latitude;
    double maxLat = origin.latitude;
    double minLng = origin.longitude;
    double maxLng = origin.longitude;

    for (final LatLng point in <LatLng>[...points, destination]) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        56,
      ),
    );
  }

  String _washerMarkerIconKey(WasherCardData data) {
    return '${data.title}|${data.rating}|${data.isTopWasher}';
  }

  Future<void> _prepareMarkerIcons() async {
    if (!_usesGoogleMap || !mounted) {
      return;
    }

    final Map<String, BitmapDescriptor> nextIcons =
        <String, BitmapDescriptor>{};
    for (final WasherCardData washer in widget.washers) {
      final String key = _washerMarkerIconKey(washer);
      final BitmapDescriptor? cached = _washerMarkerIcons[key];
      if (cached != null) {
        nextIcons[key] = cached;
        continue;
      }
      nextIcons[key] = await _createWasherMarkerBitmap(washer);
    }

    final BitmapDescriptor userMarkerIcon =
        _userLocationMarkerIcon ?? await _createUserLocationBitmap();

    if (!mounted) {
      return;
    }

    setState(() {
      _washerMarkerIcons
        ..clear()
        ..addAll(nextIcons);
      _userLocationMarkerIcon = userMarkerIcon;
    });
  }

  Future<BitmapDescriptor> _createWasherMarkerBitmap(
    WasherCardData data,
  ) async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(_markerPixelRatio);

    final bool isTop = data.isTopWasher;
    final Color background = isTop ? const Color(0xFF143C94) : Colors.white;
    final Color nameColor = isTop ? Colors.white : const Color(0xFF111216);
    final Color ratingColor = isTop
        ? const Color(0x99FFFFFF)
        : const Color(0xFF7D818A);

    final RRect pill = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 160, 36),
      const Radius.circular(18),
    );
    final Paint shadowPaint = Paint()
      ..color = isTop ? const Color(0x26143C94) : const Color(0x14000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(pill.shift(const Offset(0, 7)), shadowPaint);

    final Paint pillPaint = Paint()..color = background;
    canvas.drawRRect(pill, pillPaint);

    _drawText(
      canvas,
      '★',
      const Offset(14, 6),
      const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFFDD738),
      ),
    );

    _drawText(
      canvas,
      data.title,
      const Offset(39, 8),
      TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: nameColor),
      maxWidth: 82,
    );

    _drawText(
      canvas,
      data.rating,
      const Offset(129, 8),
      TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: ratingColor),
      maxWidth: 18,
    );

    final Path pointerPath = Path()
      ..moveTo(71, 36)
      ..quadraticBezierTo(75, 36, 77.7, 39.1)
      ..quadraticBezierTo(80.5, 42.4, 80.5, 46.8)
      ..lineTo(80.5, 55)
      ..quadraticBezierTo(80.5, 56, 79.5, 56)
      ..quadraticBezierTo(78.5, 56, 78.5, 55)
      ..lineTo(78.5, 46.8)
      ..quadraticBezierTo(78.5, 42.4, 81.3, 39.1)
      ..quadraticBezierTo(84, 36, 88, 36)
      ..close();
    final Paint pointerPaint = Paint()..color = background;
    canvas.drawPath(pointerPath, pointerPaint);

    final Paint shadowCirclePaint = Paint()..color = const Color(0x330C0D0D);
    canvas.drawCircle(const Offset(80, 55), 8, shadowCirclePaint);
    final Paint dotPaint = Paint()
      ..color = isTop ? const Color(0xFF143C94) : const Color(0xFF0C0D0D);
    canvas.drawCircle(const Offset(80, 55), 4, dotPaint);

    final ui.Image image = await recorder.endRecording().toImage(
      (_washerMarkerLogicalSize.width * _markerPixelRatio).round(),
      (_washerMarkerLogicalSize.height * _markerPixelRatio).round(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: _markerPixelRatio,
      width: _washerMarkerLogicalSize.width,
      height: _washerMarkerLogicalSize.height,
    );
  }

  Future<BitmapDescriptor> _createUserLocationBitmap() async {
    final PictureRecorder recorder = PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    canvas.scale(_markerPixelRatio);

    final Offset center = Offset(
      _userMarkerLogicalSize.width / 2,
      _userMarkerLogicalSize.height / 2,
    );
    canvas.drawCircle(center, 10, Paint()..color = const Color(0x33143C94));
    canvas.drawCircle(center, 7, Paint()..color = Colors.white);
    canvas.drawCircle(center, 5, Paint()..color = const Color(0xFF143C94));

    final ui.Image image = await recorder.endRecording().toImage(
      (_userMarkerLogicalSize.width * _markerPixelRatio).round(),
      (_userMarkerLogicalSize.height * _markerPixelRatio).round(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return BitmapDescriptor.bytes(
      byteData!.buffer.asUint8List(),
      imagePixelRatio: _markerPixelRatio,
      width: _userMarkerLogicalSize.width,
      height: _userMarkerLogicalSize.height,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    double? maxWidth,
  }) {
    final TextPainter painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? double.infinity);
    painter.paint(canvas, offset);
  }

  Set<Marker> get _markers {
    if (!_usesGoogleMap) {
      return const <Marker>{};
    }

    final Set<Marker> markers = widget.washers.map((location) {
      final String markerKey = _washerMarkerIconKey(location);
      return Marker(
        markerId: MarkerId(
          'washer-${location.title}-${location.point.latitude}-${location.point.longitude}',
        ),
        position: location.point,
        infoWindow: InfoWindow(
          title: location.title,
          snippet: '${location.subtitle} • ${location.rating}',
        ),
        onTap: () => widget.onWasherTap(location),
        icon:
            _washerMarkerIcons[markerKey] ??
            BitmapDescriptor.defaultMarkerWithHue(
              location.isTopWasher
                  ? BitmapDescriptor.hueAzure
                  : BitmapDescriptor.hueRed,
            ),
        anchor: const Offset(0.5, 1),
      );
    }).toSet();

    final LatLng? userLocation = _currentUserLocation;
    if (userLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current-user-location'),
          position: userLocation,
          infoWindow: const InfoWindow(title: AppTexts.homeYourLocation),
          icon:
              _userLocationMarkerIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 2,
        ),
      );
    }

    return markers;
  }

  Set<Polyline> get _polylines {
    final Polyline? routePolyline = _routePolyline;
    if (routePolyline == null) {
      return const <Polyline>{};
    }
    return <Polyline>{routePolyline};
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_usesGoogleMap)
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            myLocationEnabled: false,
            trafficEnabled: false,
            buildingsEnabled: true,
            indoorViewEnabled: true,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: _handleMapCreated,
            onTap: (_) => _resolveUserLocation(interactive: true),
          )
        else
          MapFallback(washers: widget.washers),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 116,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFFEFEFEF), const Color(0x00EFEFEF)],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 0,
          top: 16,
          child: MapFilterRow(
            activeFilter: widget.activeFilter,
            onFilterSelected: widget.onFilterSelected,
          ),
        ),
        if (_isLoadingRoute || (_routeSummary?.isNotEmpty ?? false))
          Positioned(
            left: 16,
            right: 16,
            top: 68,
            child: Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: _isLoadingRoute
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Loading directions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF131417),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        _routeSummary!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF131417),
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

class MapFallback extends StatelessWidget {
  const MapFallback({required this.washers, super.key});

  final List<WasherCardData> washers;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFE7ECF3)),
      child: Stack(
        children: [
          if (washers.isNotEmpty)
            Positioned(
              left: 26,
              top: 126,
              child: MapLocationMarker(data: washers[0]),
            ),
          if (washers.length > 1)
            Positioned(
              right: 24,
              top: 88,
              child: MapLocationMarker(data: washers[1]),
            ),
          if (washers.length > 2)
            Positioned(
              right: 58,
              bottom: 60,
              child: MapLocationMarker(data: washers[2]),
            ),
        ],
      ),
    );
  }
}

class MapLocationMarker extends StatelessWidget {
  const MapLocationMarker({required this.data, super.key});

  final WasherCardData data;

  @override
  Widget build(BuildContext context) {
    final Color background = data.isTopWasher
        ? const Color(0xFF143C94)
        : Colors.white;
    final Color nameColor = data.isTopWasher
        ? Colors.white
        : const Color(0xFF111216);
    final Color ratingColor = data.isTopWasher
        ? const Color(0x99FFFFFF)
        : const Color(0xFF7D818A);

    return Semantics(
      label: '${data.rank} ${data.title} ${data.rating}',
      child: SizedBox(
        width: 160,
        height: 63,
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 0,
              child: Container(
                width: 160,
                height: 36,
                padding: const EdgeInsets.fromLTRB(14, 0, 13, 0),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: data.isTopWasher
                          ? const Color(0x26143C94)
                          : const Color(0x14000000),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Color(0xFFFDD738),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          text: data.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: nameColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    RichText(
                      text: TextSpan(
                        text: data.rating,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ratingColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: 36, child: MapMarkerPointer(color: background)),
            const Positioned(
              bottom: 0,
              child: SizedBox(
                width: 16,
                height: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0x330C0D0D),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.isTopWasher
                      ? const Color(0xFF143C94)
                      : const Color(0xFF0C0D0D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MapMarkerPointer extends StatelessWidget {
  const MapMarkerPointer({required this.color, super.key});

  final Color color;

  static const String _svg = '''
<svg width="20" height="20" viewBox="70.5 36 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M83.244 38.7071C82.1171 40.0593 81.5 41.7638 81.5 43.5239V55C81.5 55.5523 81.0523 56 80.5 56C79.9477 56 79.5 55.5523 79.5 55V43.5239C79.5 41.7638 78.8829 40.0593 77.756 38.7071C76.3265 36.9918 74.209 36 71.9761 36H70.5H90.5H89.0239C86.791 36 84.6735 36.9918 83.244 38.7071Z" fill="white"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      _svg,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
