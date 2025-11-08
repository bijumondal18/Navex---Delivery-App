part of 'route_bloc.dart';

sealed class RouteState extends Equatable {
  const RouteState();

  @override
  List<Object> get props => [];
}

final class RouteInitial extends RouteState {}

final class FetchUpcomingRoutesStateLoading extends RouteState {}

final class FetchUpcomingRoutesStateLoaded extends RouteState {
  final RouteResponse routeResponse;

  const FetchUpcomingRoutesStateLoaded({required this.routeResponse});

  @override
  List<Object> get props => [routeResponse];
}

final class FetchUpcomingRoutesStateFailed extends RouteState {
  final String error;

  const FetchUpcomingRoutesStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

final class FetchAcceptedRoutesStateLoading extends RouteState {}

final class FetchAcceptedRoutesStateLoaded extends RouteState {
  final RouteResponse routeResponse;

  const FetchAcceptedRoutesStateLoaded({required this.routeResponse});

  @override
  List<Object> get props => [routeResponse];
}

final class FetchAcceptedRoutesStateFailed extends RouteState {
  final String error;

  const FetchAcceptedRoutesStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

final class FetchRouteHistoryStateLoading extends RouteState {}

final class FetchRouteHistoryStateLoaded extends RouteState {
  final List<RouteData> routes;

  const FetchRouteHistoryStateLoaded({required this.routes});

  @override
  List<Object> get props => [routes];
}

final class FetchRouteHistoryStateFailed extends RouteState {
  final String error;

  const FetchRouteHistoryStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

final class FetchRouteDetailsStateLoading extends RouteState {}

final class FetchRouteDetailsStateLoaded extends RouteState {
  final RouteData routeData;

  const FetchRouteDetailsStateLoaded({required this.routeData});

  @override
  List<Object> get props => [routeData];
}

final class FetchRouteDetailsStateFailed extends RouteState {
  final String error;

  const FetchRouteDetailsStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}


final class AcceptRouteStateLoading extends RouteState {}

final class AcceptRouteStateLoaded extends RouteState {
  final AcceptedRouteResponse acceptedRouteResponse;

  const AcceptRouteStateLoaded({required this.acceptedRouteResponse});

  @override
  List<Object> get props => [acceptedRouteResponse];
}

final class AcceptRouteStateFailed extends RouteState {
  final String error;

  const AcceptRouteStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

final class LoadVehicleStateLoading extends RouteState {}

final class LoadVehicleStateLoaded extends RouteState {
  final CommonResponse response;

  const LoadVehicleStateLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

final class LoadVehicleStateFailed extends RouteState {
  final String error;

  const LoadVehicleStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}

final class CheckInStateLoading extends RouteState {}

final class CheckInStateLoaded extends RouteState {
  final CommonResponse response;

  const CheckInStateLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

final class CheckInStateFailed extends RouteState {
  final String error;

  const CheckInStateFailed({required this.error});

  @override
  List<Object> get props => [error];
}