import 'customer.dart';

class Waypoints {
  dynamic id;
  dynamic routeId;
  dynamic customerId;
  dynamic address;
  dynamic addressLat;
  dynamic addressLong;
  dynamic optimizeOrder;
  dynamic eta;
  dynamic etaDistance;
  dynamic etaDuration;
  dynamic type;
  dynamic priority;
  dynamic packageCount;
  dynamic product;
  dynamic externalId;
  dynamic sellerName;
  dynamic sellerWebsite;
  dynamic sellerOrderId;
  dynamic sellerNote;
  dynamic driverNote;
  dynamic status;
  dynamic delFlag;
  dynamic createdBy;
  dynamic createdByIp;
  dynamic updatedBy;
  dynamic updatedByIp;
  dynamic createdAt;
  dynamic updatedAt;
  Customer? customer;

  Waypoints(
      {this.id,
        this.routeId,
        this.customerId,
        this.address,
        this.addressLat,
        this.addressLong,
        this.optimizeOrder,
        this.eta,
        this.etaDistance,
        this.etaDuration,
        this.type,
        this.priority,
        this.packageCount,
        this.product,
        this.externalId,
        this.sellerName,
        this.sellerWebsite,
        this.sellerOrderId,
        this.sellerNote,
        this.driverNote,
        this.status,
        this.delFlag,
        this.createdBy,
        this.createdByIp,
        this.updatedBy,
        this.updatedByIp,
        this.createdAt,
        this.updatedAt,
        this.customer});

  Waypoints.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    routeId = json['route_id'];
    customerId = json['customer_id'];
    address = json['address'];
    addressLat = json['address_lat'];
    addressLong = json['address_long'];
    optimizeOrder = json['optimize_order'];
    eta = json['eta'];
    etaDistance = json['eta_distance'];
    etaDuration = json['eta_duration'];
    type = json['type'];
    priority = json['priority'];
    packageCount = json['package_count'];
    product = json['product'];
    externalId = json['external_id'];
    sellerName = json['seller_name'];
    sellerWebsite = json['seller_website'];
    sellerOrderId = json['seller_order_id'];
    sellerNote = json['seller_note'];
    driverNote = json['driver_note'];
    status = json['status'];
    delFlag = json['del_flag'];
    createdBy = json['created_by'];
    createdByIp = json['created_by_ip'];
    updatedBy = json['updated_by'];
    updatedByIp = json['updated_by_ip'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customer = json['customer'] != null
        ?  Customer.fromJson(json['customer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['route_id'] = routeId;
    data['customer_id'] = customerId;
    data['address'] = address;
    data['address_lat'] = addressLat;
    data['address_long'] = addressLong;
    data['optimize_order'] = optimizeOrder;
    data['eta'] = eta;
    data['eta_distance'] = etaDistance;
    data['eta_duration'] = etaDuration;
    data['type'] = type;
    data['priority'] = priority;
    data['package_count'] = packageCount;
    data['product'] = product;
    data['external_id'] = externalId;
    data['seller_name'] = sellerName;
    data['seller_website'] = sellerWebsite;
    data['seller_order_id'] = sellerOrderId;
    data['seller_note'] = sellerNote;
    data['driver_note'] = driverNote;
    data['status'] = status;
    data['del_flag'] = delFlag;
    data['created_by'] = createdBy;
    data['created_by_ip'] = createdByIp;
    data['updated_by'] = updatedBy;
    data['updated_by_ip'] = updatedByIp;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    return data;
  }
}