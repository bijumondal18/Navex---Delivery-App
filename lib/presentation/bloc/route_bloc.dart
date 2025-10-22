import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
  }
}
