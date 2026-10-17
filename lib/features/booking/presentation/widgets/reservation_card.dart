import 'package:flutter/material.dart';

import '../../../../core/config/app_texts.dart';
import '../../data/models/reservation_data.dart';
import '../../utils/booking_formatters.dart';

class ReservationCard extends StatelessWidget {
  const ReservationCard({
    required this.reservation,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    super.key,
  });

  final ReservationData reservation;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final bool completed = reservation.isCompleted;
    final String statusLabel = normalizeStatusLabel(reservation.status);
    final Color statusColor = completed
        ? const Color(0xFF5CC46C)
        : const Color(0xFF204DA8);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatBookingDateTime(reservation.scheduledAt),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111216),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reservation.referenceCode,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFA3A8B1),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: completed
                ? AppTexts.bookingReservationLabelWasher
                : AppTexts.bookingReservationLabelDate,
            value: completed
                ? reservation.washerName
                : formatBookingDay(reservation.scheduledAt),
          ),
          _InfoRow(
            label: AppTexts.bookingReservationLabelVehicle,
            value: formatVehicleCategory(reservation.vehicleCategory),
          ),
          _InfoRow(
            label: AppTexts.bookingReservationLabelPackage,
            value: reservation.packageName,
          ),
          if (reservation.addonNames.isNotEmpty)
            _InfoRow(
              label: AppTexts.bookingReservationLabelAddons,
              value: reservation.addonNames.join(', '),
            ),
          if (!completed && reservation.progressLabel != null)
            _InfoRow(
              label: AppTexts.bookingReservationLabelProgress,
              value: reservation.progressLabel!,
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
                formatEuro(reservation.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111216),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onSecondaryAction,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E5EA)),
                    foregroundColor: const Color(0xFF111216),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    completed
                        ? AppTexts.bookingReservationActionInvoice
                        : AppTexts.bookingReservationActionMessage,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrimaryAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111216),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    completed
                        ? AppTexts.bookingReservationActionReview
                        : AppTexts.bookingReservationActionCallWasher,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF585E68)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111216),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
