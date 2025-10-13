import 'package:navex/data/models/pharmacy.dart';
import 'package:navex/data/models/state_details.dart';

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
  StateDetails? stateDetails;
  Pharmacy? pharmacy;

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
    this.stateDetails,
    this.pharmacy
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
    stateDetails = json['state_details'] != null
        ?  StateDetails.fromJson(json['state_details'])
        : null;
    pharmacy = json['pharmacy'] != null
        ?  Pharmacy.fromJson(json['pharmacy'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['phone'] = phone;
    data['bio'] = bio;
    data['address'] = address;
    data['address_lat'] = addressLat;
    data['address_long'] = addressLong;
    data['city'] = city;
    data['state'] = state;
    data['zip'] = zip;
    data['location'] = location;
    data['location_lat'] = locationLat;
    data['location_long'] = locationLong;
    if (stateDetails != null) {
      data['state_details'] = stateDetails!.toJson();
    }
    if (pharmacy != null) {
      data['pharmacy'] = pharmacy!.toJson();
    }
    return data;
  }
}
