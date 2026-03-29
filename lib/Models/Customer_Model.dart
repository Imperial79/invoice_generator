import 'dart:convert';

class CustomerModel {
  final int? id;
  final String name;
  final String phone;
  final String address;
  final String gst;
  final String pan;
  final String aadhaar;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.address = "",
    this.gst = "",
    this.pan = "",
    this.aadhaar = "",
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'gst': gst,
      'pan': pan,
      'aadhaar': aadhaar,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      gst: map['gst'] ?? '',
      pan: map['pan'] ?? '',
      aadhaar: map['aadhaar'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CustomerModel.fromJson(String source) =>
      CustomerModel.fromMap(json.decode(source));

  CustomerModel copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    String? gst,
    String? pan,
    String? aadhaar,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gst: gst ?? this.gst,
      pan: pan ?? this.pan,
      aadhaar: aadhaar ?? this.aadhaar,
    );
  }
}
