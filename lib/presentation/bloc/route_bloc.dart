import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
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
       // if (response['status'] == true) {
          final routeResponse = RouteResponse.fromJson(response);
          emit(FetchUpcomingRoutesStateLoaded(routeResponse: routeResponse));
        //}
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
        // if (response['status'] == true) {
        final routeResponse = RouteResponse.fromJson(response);
        emit(FetchAcceptedRoutesStateLoaded(routeResponse: routeResponse));
        //}
      } catch (e) {
        emit(FetchAcceptedRoutesStateFailed(error: e.toString()));
      }
    });
  }
}
