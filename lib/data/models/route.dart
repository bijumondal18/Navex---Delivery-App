
class RouteData {
  int? id;
  int? pharmacyId;
  String? routeName;
  String? startDate;
  String? startTime;
  String? pickupAddress;
  String? pickupLat;
  String? pickupLong;
  int? asignedDriver;
  String? totalDistance;
  String? totalDistanceKm;
  String? totalTimeSeconds;
  String? totalTime;
  String? polyline;
  int? routeOrder;
  String? routeType;
  String? driverShouldReturn;
  String? returnEta;
  String? returnTime;
  String? returnDistance;
  String? isLoaded;
  String? currentWaypoint;
  int? status;
  int? acceptedBy;
  String? tripStartTime;
  String? tripEndTime;
  String? delFlag;
  String? createdBy;
  String? createdByIp;
  String? updatedBy;
  String? updatedByIp;
  String? createdAt;
  String? updatedAt;

  RouteData(
      {this.id,
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
        this.updatedAt});

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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['id'] = this.id;
    data['pharmacy_id'] = this.pharmacyId;
    data['route_name'] = this.routeName;
    data['start_date'] = this.startDate;
    data['start_time'] = this.startTime;
    data['pickup_address'] = this.pickupAddress;
    data['pickup_lat'] = this.pickupLat;
    data['pickup_long'] = this.pickupLong;
    data['asigned_driver'] = this.asignedDriver;
    data['total_distance'] = this.totalDistance;
    data['total_distance_km'] = this.totalDistanceKm;
    data['total_time_seconds'] = this.totalTimeSeconds;
    data['total_time'] = this.totalTime;
    data['polyline'] = this.polyline;
    data['route_order'] = this.routeOrder;
    data['route_type'] = this.routeType;
    data['driver_should_return'] = this.driverShouldReturn;
    data['return_eta'] = this.returnEta;
    data['return_time'] = this.returnTime;
    data['return_distance'] = this.returnDistance;
    data['is_loaded'] = this.isLoaded;
    data['current_waypoint'] = this.currentWaypoint;
    data['status'] = this.status;
    data['accepted_by'] = this.acceptedBy;
    data['trip_start_time'] = this.tripStartTime;
    data['trip_end_time'] = this.tripEndTime;
    data['del_flag'] = this.delFlag;
    data['created_by'] = this.createdBy;
    data['created_by_ip'] = this.createdByIp;
    data['updated_by'] = this.updatedBy;
    data['updated_by_ip'] = this.updatedByIp;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
