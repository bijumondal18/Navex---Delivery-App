class Pharmacy {
  int? id;
  String? name;
  String? pharmacyKey;

  Pharmacy({this.id, this.name, this.pharmacyKey});

  Pharmacy.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    pharmacyKey = json['pharmacy_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['pharmacy_key'] = pharmacyKey;
    return data;
  }
}