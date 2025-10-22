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
