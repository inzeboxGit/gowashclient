import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../home/data/models/category_data.dart';
import '../../../home/presentation/widgets/side_menu.dart';
import '../../data/models/reservation_data.dart';
import '../../data/services/booking_repository.dart';
import '../widgets/booking_header.dart';
import '../widgets/booking_selection_widgets.dart';
import '../widgets/reservation_card.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.showCompletedFirst = false});

  static const String routeName = AppRoutes.orders;

  final bool showCompletedFirst;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const List<CategoryData> _categories = <CategoryData>[
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final BookingRepository _bookingRepository = const BookingRepository();

  late bool _showCompleted;

  @override
  void initState() {
    super.initState();
    _showCompleted = widget.showCompletedFirst;
  }

  void _showActionMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF3F3F5),
      drawer: SideMenu(
        categories: _categories,
        selectedTab: 0,
        onCategorySelected: (_) {},
        onFindWasher: () {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.mainSearch, (route) => false);
        },
        onOpenProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        onOpenOrders: () => Navigator.of(context).pop(),
      ),
      body: SafeArea(
        child: StreamBuilder<List<ReservationData>>(
          stream: _bookingRepository.watchReservations(),
          builder: (context, snapshot) {
            final List<ReservationData> reservations =
                snapshot.data ?? <ReservationData>[];
            final List<ReservationData> inProgress = reservations
                .where((item) => !item.isCompleted)
                .toList();
            final List<ReservationData> completed = reservations
                .where((item) => item.isCompleted)
                .toList();
            final List<ReservationData> visible = _showCompleted
                ? completed
                : inProgress;

            return Column(
              children: [
                OrdersHeader(
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  notificationCount: inProgress.length,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E9EC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _OrdersTabButton(
                            label: AppTexts.bookingOrdersInProgress,
                            selected: !_showCompleted,
                            onTap: () {
                              setState(() {
                                _showCompleted = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: _OrdersTabButton(
                            label: AppTexts.bookingOrdersCompleted,
                            selected: _showCompleted,
                            onTap: () {
                              setState(() {
                                _showCompleted = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : visible.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                          child: EmptyBookingState(
                            message: _showCompleted
                                ? AppTexts.bookingEmptyCompleted
                                : AppTexts.bookingEmptyInProgress,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                          itemBuilder: (context, index) {
                            final ReservationData reservation = visible[index];
                            return ReservationCard(
                              reservation: reservation,
                              onPrimaryAction: () {
                                if (reservation.isCompleted) {
                                  _showActionMessage(
                                    AppTexts.bookingReviewFlow,
                                  );
                                  return;
                                }
                                _showActionMessage(
                                  reservation.washerPhoneNumber == null
                                      ? AppTexts.bookingNoWasherPhone
                                      : AppTexts.bookingCallNumber(
                                          reservation.washerPhoneNumber!,
                                        ),
                                );
                              },
                              onSecondaryAction: () {
                                if (reservation.isCompleted) {
                                  _showActionMessage(
                                    reservation.invoiceUrl == null
                                        ? AppTexts.bookingNoInvoice
                                        : reservation.invoiceUrl!,
                                  );
                                  return;
                                }
                                _showActionMessage(
                                  AppTexts.bookingMessagingComing,
                                );
                              },
                            );
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemCount: visible.length,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrdersTabButton extends StatelessWidget {
  const _OrdersTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: selected
                  ? const Color(0xFF111216)
                  : const Color(0xFF989DA6),
            ),
          ),
        ),
      ),
    );
  }
}
