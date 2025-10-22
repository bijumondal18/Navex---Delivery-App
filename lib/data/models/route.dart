import 'package:navex/data/models/waypoints.dart';

class RouteData {
  dynamic id;
  dynamic pharmacyId;
  dynamic routeName;
  dynamic startDate;
  dynamic startTime;
  dynamic pickupAddress;
  dynamic pickupLat;
  dynamic pickupLong;
  dynamic asignedDriver;
  dynamic totalDistance;
  dynamic totalDistanceKm;
  dynamic totalTimeSeconds;
  dynamic totalTime;
  dynamic polyline;
  dynamic routeOrder;
  dynamic routeType;
  dynamic driverShouldReturn;
  dynamic returnEta;
  dynamic returnTime;
  dynamic returnDistance;
  dynamic isLoaded;
  dynamic currentWaypoint;
  dynamic status;
  dynamic acceptedBy;
  dynamic tripStartTime;
  dynamic tripEndTime;
  dynamic delFlag;
  dynamic createdBy;
  dynamic createdByIp;
  dynamic updatedBy;
  dynamic updatedByIp;
  dynamic createdAt;
  dynamic updatedAt;
  List<Waypoints>? waypoints;

  RouteData({
    this.id,
    this.pharmacyId,
    this.routeName,
    this.startDate,
    this.startTime,
    this.pickupAddress,
    this.pickupLat,
    this.pickupLong,
    this.asignedDriver,
    this.totalDistance,
    this.totalDistanceKm,
    this.totalTimeSeconds,
    this.totalTime,
    this.polyline,
    this.routeOrder,
    this.routeType,
    this.driverShouldReturn,
    this.returnEta,
    this.returnTime,
    this.returnDistance,
    this.isLoaded,
    this.currentWaypoint,
    this.status,
    this.acceptedBy,
    this.tripStartTime,
    this.tripEndTime,
    this.delFlag,
    this.createdBy,
    this.createdByIp,
    this.updatedBy,
    this.updatedByIp,
    this.createdAt,
    this.updatedAt,
    this.waypoints,
  });

  RouteData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pharmacyId = json['pharmacy_id'];
    routeName = json['route_name'];
    startDate = json['start_date'];
    startTime = json['start_time'];
    pickupAddress = json['pickup_address'];
    pickupLat = json['pickup_lat'];
    pickupLong = json['pickup_long'];
    asignedDriver = json['asigned_driver'];
    totalDistance = json['total_distance'];
    totalDistanceKm = json['total_distance_km'];
    totalTimeSeconds = json['total_time_seconds'];
    totalTime = json['total_time'];
    polyline = json['polyline'];
    routeOrder = json['route_order'];
    routeType = json['route_type'];
    driverShouldReturn = json['driver_should_return'];
    returnEta = json['return_eta'];
    returnTime = json['return_time'];
    returnDistance = json['return_distance'];
    isLoaded = json['is_loaded'];
    currentWaypoint = json['current_waypoint'];
    status = json['status'];
    acceptedBy = json['accepted_by'];
    tripStartTime = json['trip_start_time'];
    tripEndTime = json['trip_end_time'];
    delFlag = json['del_flag'];
    createdBy = json['created_by'];
    createdByIp = json['created_by_ip'];
    updatedBy = json['updated_by'];
    updatedByIp = json['updated_by_ip'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    if (json['waypoints'] != null) {
      waypoints = <Waypoints>[];
      json['waypoints'].forEach((v) {
        waypoints!.add(Waypoints.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pharmacy_id'] = pharmacyId;
    data['route_name'] = routeName;
    data['start_date'] = startDate;
    data['start_time'] = startTime;
    data['pickup_address'] = pickupAddress;
    data['pickup_lat'] = pickupLat;
    data['pickup_long'] = pickupLong;
    data['asigned_driver'] = asignedDriver;
    data['total_distance'] = totalDistance;
    data['total_distance_km'] = totalDistanceKm;
    data['total_time_seconds'] = totalTimeSeconds;
    data['total_time'] = totalTime;
    data['polyline'] = polyline;
    data['route_order'] = routeOrder;
    data['route_type'] = routeType;
    data['driver_should_return'] = driverShouldReturn;
    data['return_eta'] = returnEta;
    data['return_time'] = returnTime;
    data['return_distance'] = returnDistance;
    data['is_loaded'] = isLoaded;
    data['current_waypoint'] = currentWaypoint;
    data['status'] = status;
    data['accepted_by'] = acceptedBy;
    data['trip_start_time'] = tripStartTime;
    data['trip_end_time'] = tripEndTime;
    data['del_flag'] = delFlag;
    data['created_by'] = createdBy;
    data['created_by_ip'] = createdByIp;
    data['updated_by'] = updatedBy;
    data['updated_by_ip'] = updatedByIp;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (waypoints != null) {
      data['waypoints'] = waypoints!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
