part of 'route_bloc.dart';

sealed class RouteEvent extends Equatable {
  const RouteEvent();

  @override
  List<Object> get props => [];
}

class FetchUpcomingRoutesEvent extends RouteEvent {
  final String date;

  const FetchUpcomingRoutesEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class FetchAcceptedRoutesEvent extends RouteEvent {
  final String date;

  const FetchAcceptedRoutesEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class FetchRouteHistoryEvent extends RouteEvent {
  final String date;

  const FetchRouteHistoryEvent({required this.date});

  @override
  List<Object> get props => [date];
}

class FetchRouteDetailsEvent extends RouteEvent {
  final String routeId;

  const FetchRouteDetailsEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}

class AcceptRouteEvent extends RouteEvent {
  final String routeId;

  const AcceptRouteEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}

class LoadVehicleEvent extends RouteEvent {
  final String routeId;
  final double currentLat;
  final double currentLng;

  const LoadVehicleEvent({
    required this.routeId,
    required this.currentLat,
    required this.currentLng,
  });

  @override
  List<Object> get props => [routeId, currentLat, currentLng];
}

class CheckInEvent extends RouteEvent {
  final String routeId;

  const CheckInEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}

class CancelRouteEvent extends RouteEvent {
  final String routeId;

  const CancelRouteEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}

class MarkDeliveryEvent extends RouteEvent {
  final String deliveryRouteId;
  final String deliveryWaypointId;
  final double lat;
  final double long;
  final int deliveryType;
  final String deliveryDate;
  final String deliveryTime;
  final List<File> deliveryImages;
  final File? signature;
  final String? notes;
  final String? reason;
  final String? recipientName;
  final int? deliverTo;

  const MarkDeliveryEvent({
    required this.deliveryRouteId,
    required this.deliveryWaypointId,
    required this.lat,
    required this.long,
    required this.deliveryType,
    required this.deliveryDate,
    required this.deliveryTime,
    required this.deliveryImages,
    this.signature,
    this.notes,
    this.reason,
    this.recipientName,
    this.deliverTo,
  });

  @override
  List<Object> get props => [
    deliveryRouteId,
    deliveryWaypointId,
    lat,
    long,
    deliveryType,
    deliveryDate,
    deliveryTime,
    deliveryImages,
    signature?.path ?? '',
    notes ?? '',
    reason ?? '',
    recipientName ?? '',
    deliverTo ?? 0,
  ];
}