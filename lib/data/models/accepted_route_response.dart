import 'package:navex/data/models/route.dart';

class AcceptedRouteResponse {
  bool? status;
  String? message;
  RouteData? route;

  AcceptedRouteResponse({this.status, this.message, this.route});

  AcceptedRouteResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    route = json['route'] != null ?  RouteData.fromJson(json['route']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (route != null) {
      data['route'] = route!.toJson();
    }
    return data;
  }
}