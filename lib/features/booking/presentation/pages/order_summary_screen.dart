import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../shared/widgets/network_or_asset_image.dart';
import '../../data/models/booking_route_arguments.dart';
import '../../data/models/order_summary_draft.dart';
import '../../data/models/payment_method_data.dart';
import '../../data/services/booking_repository.dart';
import '../../utils/booking_formatters.dart';
import '../widgets/booking_header.dart';
import '../widgets/booking_selection_widgets.dart';
import '../widgets/payment_method_tile.dart';

class OrderSummaryScreen extends StatefulWidget {
  const OrderSummaryScreen({required this.draft, super.key});

  static const String routeName = AppRoutes.orderSummary;

  final OrderSummaryDraft draft;

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  final BookingRepository _bookingRepository = const BookingRepository();
  final TextEditingController _promoController = TextEditingController();

  List<PaymentMethodData> _paymentMethods = <PaymentMethodData>[];
  String? _selectedPaymentId;
  bool _isLoading = true;
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final List<PaymentMethodData> methods = await _bookingRepository
        .loadPaymentMethods();
    if (!mounted) {
      return;
    }
    String? initialSelectedPaymentId;
    if (methods.isNotEmpty) {
      initialSelectedPaymentId = methods.first.id;
      for (final PaymentMethodData method in methods) {
        if (method.isDefault) {
          initialSelectedPaymentId = method.id;
          break;
        }
      }
    }
    setState(() {
      _paymentMethods = methods;
      _selectedPaymentId = initialSelectedPaymentId;
      _isLoading = false;
    });
  }

  PaymentMethodData? get _selectedPaymentMethod {
    final String? selectedPaymentId = _selectedPaymentId;
    if (selectedPaymentId == null) {
      return null;
    }
    for (final PaymentMethodData method in _paymentMethods) {
      if (method.id == selectedPaymentId) {
        return method;
      }
    }
    return null;
  }

  Future<void> _checkout() async {
    final PaymentMethodData? paymentMethod = _selectedPaymentMethod;
    if (paymentMethod == null || _isCheckingOut) {
      return;
    }

    setState(() {
      _isCheckingOut = true;
    });

    try {
      await _bookingRepository.createReservation(
        draft: widget.draft,
        paymentMethod: paymentMethod,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.bookingReservationCreated)),
      );
      Navigator.of(context).pushNamed(
        AppRoutes.orders,
        arguments: const OrdersRouteArguments(showCompletedFirst: false),
      );
    } on StateError catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppTexts.bookingReservationFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final OrderSummaryDraft draft = widget.draft;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            BookingHeader(
              title: AppTexts.bookingOrderSummaryTitle,
              leadingIcon: Icons.menu_rounded,
              trailing: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF111216),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BookingSectionTitle(
                            label: AppTexts.bookingSectionService,
                          ),
                          const SizedBox(height: 10),
                          _ServiceSummaryCard(draft: draft),
                          const SizedBox(height: 18),
                          const BookingSectionTitle(
                            label: AppTexts.bookingSectionPaymentMethod,
                          ),
                          const SizedBox(height: 10),
                          if (_paymentMethods.isEmpty)
                            const EmptyBookingState(
                              message: AppTexts.bookingNoPaymentMethods,
                            )
                          else
                            for (final PaymentMethodData method
                                in _paymentMethods) ...[
                              PaymentMethodTile(
                                method: method,
                                selected: _selectedPaymentId == method.id,
                                onTap: () {
                                  setState(() {
                                    _selectedPaymentId = method.id;
                                  });
                                },
                              ),
                              if (method != _paymentMethods.last)
                                const SizedBox(height: 10),
                            ],
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _promoController,
                                  decoration: InputDecoration(
                                    hintText: AppTexts.bookingPromoHint,
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 54,
                                child: OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          AppTexts.bookingPromoInfo,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: const Text(
                                    AppTexts.bookingPromoApply,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF9CA2AD),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: Color(0xFF7F8692),
                              ),
                              children: [
                                TextSpan(text: AppTexts.bookingTermsPrefix),
                                TextSpan(
                                  text: AppTexts.authTermsAndConditions,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF204DA8),
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: AppTexts.authPrivacyPolicy,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF204DA8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
            BookingBottomBar(
              totalLabel: formatEuro(draft.totalPrice),
              ctaLabel: AppTexts.bookingCheckout,
              isBusy: _isCheckingOut,
              enabled: _selectedPaymentMethod != null,
              onPressed: _checkout,
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceSummaryCard extends StatelessWidget {
  const _ServiceSummaryCard({required this.draft});

  final OrderSummaryDraft draft;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: NetworkOrAssetImage(
                  assetPath: draft.washerImageAsset,
                  imageUrl: draft.washerImageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.washerName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111216),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.washerSubtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F8692),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE8EBF0), height: 1),
          const SizedBox(height: 14),
          _SummaryLine(
            label: AppTexts.bookingCarType,
            value: formatVehicleCategory(draft.vehicleCategory),
          ),
          _SummaryLine(
            label: draft.selectedPackage.name,
            value: formatEuro(
              draft.selectedPackage.priceFor(draft.vehicleCategory) ?? 0,
            ),
          ),
          for (final addon in draft.selectedAddons)
            _SummaryLine(
              label: addon.name,
              value: formatEuro(addon.priceFor(draft.vehicleCategory)),
            ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE8EBF0), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                AppTexts.bookingTotal,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111216),
                ),
              ),
              const Spacer(),
              Text(
                formatEuro(draft.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111216),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C414A),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111216),
            ),
          ),
        ],
      ),
    );
  }
}
