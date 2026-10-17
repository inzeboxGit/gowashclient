import '../../../home/data/models/washer_card_data.dart';
import 'order_summary_draft.dart';

class WasherDetailsRouteArguments {
  const WasherDetailsRouteArguments({required this.washerId, this.preview});

  final String washerId;
  final WasherCardData? preview;
}

class OrderSummaryRouteArguments {
  const OrderSummaryRouteArguments({required this.draft});

  final OrderSummaryDraft draft;
}

class OrdersRouteArguments {
  const OrdersRouteArguments({this.showCompletedFirst = false});

  final bool showCompletedFirst;
}
