import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:navex/data/models/accepted_route_response.dart';
import 'package:navex/data/models/common_response.dart';
import 'package:navex/data/models/route.dart';
import 'package:navex/data/models/route_response.dart';
import 'package:navex/data/repositories/route_repository.dart';

part 'route_event.dart';

part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final RouteRepository routeRepository;

  RouteBloc(this.routeRepository) : super(RouteInitial()) {
    /**
     * Fetch Upcoming Routes States Handling
     * */
    on<FetchUpcomingRoutesEvent>((event, emit) async {
      emit(FetchUpcomingRoutesStateLoading());
      try {
        final response = await routeRepository.fetchUpcomingRoutes(event.date);
        final routeResponse = RouteResponse.fromJson(response);
        emit(FetchUpcomingRoutesStateLoaded(routeResponse: routeResponse));
      } catch (e) {
        emit(FetchUpcomingRoutesStateFailed(error: e.toString()));
      }
    });

    /**
     * Fetch Accepted Routes States Handling
     * */
    on<FetchAcceptedRoutesEvent>((event, emit) async {
      emit(FetchAcceptedRoutesStateLoading());
      try {
        final response = await routeRepository.fetchAcceptedRoutes(event.date);
        final routeResponse = RouteResponse.fromJson(response);
        emit(FetchAcceptedRoutesStateLoaded(routeResponse: routeResponse));
      } catch (e) {
        emit(FetchAcceptedRoutesStateFailed(error: e.toString()));
      }
    });

    /**
     * Fetch Route Details States Handling
     * */
    on<FetchRouteDetailsEvent>((event, emit) async {
      emit(FetchRouteDetailsStateLoading());
      try {
        final response = await routeRepository.fetchRouteDetails(event.routeId);
        final routeData = RouteData.fromJson(response);
        emit(FetchRouteDetailsStateLoaded(routeData: routeData));
      } catch (e) {
        emit(FetchRouteDetailsStateFailed(error: e.toString()));
      }
    });

    /**
     * Accept Route States Handling
     * */
    on<AcceptRouteEvent>((event, emit) async {
      emit(AcceptRouteStateLoading());
      try {
        final response = await routeRepository.acceptRoute(event.routeId);
        final routeData = AcceptedRouteResponse.fromJson(response);
        emit(AcceptRouteStateLoaded(acceptedRouteResponse: routeData));
      } catch (e) {
        emit(AcceptRouteStateFailed(error: e.toString()));
      }
    });

    /**
     * Load Vehicle States Handling
     * */
    on<LoadVehicleEvent>((event, emit) async {
      emit(LoadVehicleStateLoading());
      try {
        final response = await routeRepository.loadVehicle(
          routeId: event.routeId,
          currentLat: event.currentLat,
          currentLng: event.currentLng,
        );
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);
          emit(LoadVehicleStateLoaded(response: commonResponse));
          add(FetchRouteDetailsEvent(routeId: event.routeId));
        } else {
          emit(LoadVehicleStateFailed(
            error: response['message'] ?? 'Unable to load vehicle',
          ));
        }
      } catch (e) {
        emit(LoadVehicleStateFailed(error: e.toString()));
      }
    });

    /**
     * Check-In States Handling
     * */
    on<CheckInEvent>((event, emit) async {
      emit(CheckInStateLoading());
      try {
        final response = await routeRepository.checkInRoute(event.routeId);
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);
          emit(CheckInStateLoaded(response: commonResponse));
          add(FetchRouteDetailsEvent(routeId: event.routeId));
        } else {
          emit(CheckInStateFailed(
            error: response['message'] ?? 'Unable to check in',
          ));
        }
      } catch (e) {
        emit(CheckInStateFailed(error: e.toString()));
      }
    });
  }
}
