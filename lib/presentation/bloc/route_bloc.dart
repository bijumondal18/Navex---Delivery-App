import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:navex/data/models/accepted_route_response.dart';
import 'package:navex/data/models/common_response.dart';
import 'package:navex/data/models/route.dart';
import 'package:navex/data/models/route_response.dart';
import 'package:navex/core/utils/app_preference.dart';
import 'package:navex/data/repositories/route_repository.dart';
import 'package:navex/service/location/background_location_service.dart';
import 'package:navex/service/firestore/route_firestore_service.dart';

part 'route_event.dart';

part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final RouteRepository routeRepository;
  FetchAcceptedRoutesStateLoaded? _lastAcceptedRoutesState;

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
        final loadedState = FetchAcceptedRoutesStateLoaded(routeResponse: routeResponse);
        _lastAcceptedRoutesState = loadedState; // Store the state
        emit(loadedState);
      } catch (e) {
        emit(FetchAcceptedRoutesStateFailed(error: e.toString()));
      }
    });

    /**
     * Fetch Route History States Handling
     * */
    on<FetchRouteHistoryEvent>((event, emit) async {
      emit(FetchRouteHistoryStateLoading());
      try {
        final response = await routeRepository.fetchRouteHistory();
        final routes = _mapToRouteList(response);
        emit(FetchRouteHistoryStateLoaded(routes: routes));
      } catch (e) {
        emit(FetchRouteHistoryStateFailed(error: e.toString()));
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
        
        // Save route to Firestore after successful acceptance
        if (routeData.status == true && routeData.route != null) {
          try {
            await RouteFirestoreService.createOrUpdateRoute(
              routeId: event.routeId,
              routeData: routeData.route!,
            );
            print('✅ Route saved to Firestore: route_id=${event.routeId}');
          } catch (firestoreError) {
            // Log error but don't fail the accept route operation
            print('⚠️ Failed to save route to Firestore (non-critical): $firestoreError');
          }
        }
        
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
          
          // Start background location tracking after successful vehicle load
          try {
            // Get driver ID from preferences
            final driverId = await AppPreference.getInt(AppPreference.userId);
            final driverIdString = driverId?.toString() ?? '';
            
            final locationService = BackgroundLocationService();
            await locationService.startTracking(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10, // Update every 10 meters
              routeId: event.routeId,
              driverId: driverIdString,
            );
          } catch (e) {
            // Log error but don't fail the load vehicle operation
            print('Failed to start background location tracking: $e');
          }
          
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

    /**
     * Cancel Route States Handling
     * */
    on<CancelRouteEvent>((event, emit) async {
      final routeId = event.routeId.toString();
      emit(CancelRouteStateLoading(routeId: routeId));
      try {
        final response = await routeRepository.cancelRoute(event.routeId);
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);
          
          // Update accepted routes state by removing the canceled route
          // Use the stored last accepted routes state instead of current state
          if (_lastAcceptedRoutesState != null) {
            final currentRoutes = _lastAcceptedRoutesState!.routeResponse.route ?? [];
            final canceledRouteId = event.routeId.toString();
            final updatedRoutes = currentRoutes.where((route) {
              // Compare route IDs as strings to handle different types
              final routeIdStr = route.id?.toString() ?? '';
              return routeIdStr != canceledRouteId;
            }).toList();
            
            // Create updated route response
            final updatedRouteResponse = RouteResponse(
              currentPage: _lastAcceptedRoutesState!.routeResponse.currentPage,
              route: updatedRoutes,
              firstPageUrl: _lastAcceptedRoutesState!.routeResponse.firstPageUrl,
              from: _lastAcceptedRoutesState!.routeResponse.from,
              lastPage: _lastAcceptedRoutesState!.routeResponse.lastPage,
              lastPageUrl: _lastAcceptedRoutesState!.routeResponse.lastPageUrl,
              links: _lastAcceptedRoutesState!.routeResponse.links,
              nextPageUrl: _lastAcceptedRoutesState!.routeResponse.nextPageUrl,
              path: _lastAcceptedRoutesState!.routeResponse.path,
              perPage: _lastAcceptedRoutesState!.routeResponse.perPage,
              prevPageUrl: _lastAcceptedRoutesState!.routeResponse.prevPageUrl,
              to: _lastAcceptedRoutesState!.routeResponse.to,
              total: _lastAcceptedRoutesState!.routeResponse.total,
            );
            
            // Create and store the updated state
            final updatedState = FetchAcceptedRoutesStateLoaded(routeResponse: updatedRouteResponse);
            _lastAcceptedRoutesState = updatedState; // Update stored state for next cancel
            emit(updatedState);
          }
          
          // Emit cancel success state
          emit(CancelRouteStateLoaded(response: commonResponse, routeId: routeId));
        } else {
          emit(CancelRouteStateFailed(
            error: response['message'] ?? 'Unable to cancel route',
            routeId: routeId,
          ));
        }
      } catch (e) {
        emit(CancelRouteStateFailed(error: e.toString(), routeId: routeId));
      }
    });

    /**
     * Mark Delivery States Handling
     * */
    on<MarkDeliveryEvent>((event, emit) async {
      emit(MarkDeliveryStateLoading());
      try {
        final response = await routeRepository.markDelivery(
          deliveryRouteId: event.deliveryRouteId,
          deliveryWaypointId: event.deliveryWaypointId,
          lat: event.lat,
          long: event.long,
          deliveryType: event.deliveryType,
          deliveryDate: event.deliveryDate,
          deliveryTime: event.deliveryTime,
          deliveryImages: event.deliveryImages,
          signature: event.signature,
          notes: event.notes,
          reason: event.reason,
          recipientName: event.recipientName,
          deliverTo: event.deliverTo,
        );
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);
          emit(MarkDeliveryStateLoaded(response: commonResponse));
        } else {
          emit(MarkDeliveryStateFailed(
            error: response['message'] ?? 'Unable to mark delivery',
          ));
        }
      } catch (e) {
        emit(MarkDeliveryStateFailed(error: e.toString()));
      }
    });

    /**
     * Complete Trip States Handling
     * */
    on<CompleteTripEvent>((event, emit) async {
      emit(CompleteTripStateLoading());
      try {
        final response = await routeRepository.completeTrip(
          routeId: event.routeId,
          completeDate: event.completeDate,
          completeTime: event.completeTime,
        );
        if (response['status'] == true) {
          final commonResponse = CommonResponse.fromJson(response);
          emit(CompleteTripStateLoaded(response: commonResponse));
          
            // Stop background location tracking after successful trip completion
            try {
              final locationService = BackgroundLocationService();
              await locationService.stopTracking(routeId: event.routeId);
            } catch (e) {
              // Log error but don't fail the complete trip operation
              print('Failed to stop background location tracking: $e');
            }
        } else {
          emit(CompleteTripStateFailed(
            error: response['message'] ?? 'Unable to complete trip',
          ));
        }
      } catch (e) {
        emit(CompleteTripStateFailed(error: e.toString()));
      }
    });
  }

  List<RouteData> _mapToRouteList(dynamic data) {
    if (data is List) {
      return data
          .map((item) {
            if (item is Map<String, dynamic>) {
              return RouteData.fromJson(item);
            }
            if (item is Map) {
              return RouteData.fromJson(
                item.map(
                  (key, value) => MapEntry(key.toString(), value),
                ),
              );
            }
            return null;
          })
          .whereType<RouteData>()
          .toList();
    } else if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is List) {
        return payload
            .map((item) {
              if (item is Map<String, dynamic>) {
                return RouteData.fromJson(item);
              }
              if (item is Map) {
                return RouteData.fromJson(
                  item.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ),
                );
              }
              return null;
            })
            .whereType<RouteData>()
            .toList();
      }

      if (data.containsKey('id')) {
        return [RouteData.fromJson(data)];
      }
    } else if (data is Map) {
      final mapData = data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      final payload = mapData['data'];
      if (payload is List) {
        return payload
            .map((item) {
              if (item is Map<String, dynamic>) {
                return RouteData.fromJson(item);
              }
              if (item is Map) {
                return RouteData.fromJson(
                  item.map(
                    (key, value) => MapEntry(key.toString(), value),
                  ),
                );
              }
              return null;
            })
            .whereType<RouteData>()
            .toList();
      }

      if (mapData.containsKey('id')) {
        return [RouteData.fromJson(mapData)];
      }
    }

    return [];
  }
}
