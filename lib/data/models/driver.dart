class Driver {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? bio;
  String? address;
  String? addressLat;
  String? addressLong;
  String? city;
  String? state;
  String? zip;
  String? location;
  String? locationLat;
  String? locationLong;

  Driver({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.address,
    this.addressLat,
    this.addressLong,
    this.city,
    this.state,
    this.zip,
    this.location,
    this.locationLat,
    this.locationLong,
  });

  Driver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    bio = json['bio'];
    address = json['address'];
    addressLat = json['address_lat'];
    addressLong = json['address_long'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    location = json['location'];
    locationLat = json['location_lat'];
    locationLong = json['location_long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['bio'] = this.bio;
    data['address'] = this.address;
    data['address_lat'] = this.addressLat;
    data['address_long'] = this.addressLong;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    data['location'] = this.location;
    data['location_lat'] = this.locationLat;
    data['location_long'] = this.locationLong;
    return data;
  }
}
