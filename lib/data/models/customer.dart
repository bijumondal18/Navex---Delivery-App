class Customer {
  dynamic id;
  dynamic userId;
  dynamic pharmacyId;
  dynamic name;
  dynamic email;
  dynamic phone;
  dynamic address;
  dynamic addressLat;
  dynamic addressLong;
  dynamic city;
  dynamic state;
  dynamic zip;
  dynamic status;
  dynamic delFlag;
  dynamic createdBy;
  dynamic createdByIp;
  dynamic updatedBy;
  dynamic updatedByIp;
  dynamic createdAt;
  dynamic updatedAt;

  Customer(
      {this.id,
        this.userId,
        this.pharmacyId,
        this.name,
        this.email,
        this.phone,
        this.address,
        this.addressLat,
        this.addressLong,
        this.city,
        this.state,
        this.zip,
        this.status,
        this.delFlag,
        this.createdBy,
        this.createdByIp,
        this.updatedBy,
        this.updatedByIp,
        this.createdAt,
        this.updatedAt});

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    pharmacyId = json['pharmacy_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    address = json['address'];
    addressLat = json['address_lat'];
    addressLong = json['address_long'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    status = json['status'];
    delFlag = json['del_flag'];
    createdBy = json['created_by'];
    createdByIp = json['created_by_ip'];
    updatedBy = json['updated_by'];
    updatedByIp = json['updated_by_ip'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['pharmacy_id'] = pharmacyId;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['address'] = address;
    data['address_lat'] = addressLat;
    data['address_long'] = addressLong;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['status'] = status;
    data['del_flag'] = delFlag;
    data['created_by'] = createdBy;
    data['created_by_ip'] = createdByIp;
    data['updated_by'] = updatedBy;
    data['updated_by_ip'] = updatedByIp;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}