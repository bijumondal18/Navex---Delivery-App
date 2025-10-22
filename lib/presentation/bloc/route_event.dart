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

class FetchRouteDetailsEvent extends RouteEvent {
  final String routeId;

  const FetchRouteDetailsEvent({required this.routeId});

  @override
  List<Object> get props => [routeId];
}
