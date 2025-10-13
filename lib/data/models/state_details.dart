class StateDetails {
  int? id;
  String? country;
  String? countryCode;
  String? state;
  String? stateCode;

  StateDetails(
      {this.id, this.country, this.countryCode, this.state, this.stateCode});

  StateDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    countryCode = json['country_code'];
    state = json['state'];
    stateCode = json['state_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['state'] = state;
    data['state_code'] = stateCode;
    return data;
  }
}