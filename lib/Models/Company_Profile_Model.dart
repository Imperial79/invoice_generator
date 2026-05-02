import 'dart:convert';

class CompanyProfileModel {
  final String name;
  final String phone;
  final String email;
  final String gst;
  final String address;
  final String state;
  final String bankDetails;
  final String terms;
  final String declaration;
  final String bannerPath;
  final String watermarkPath;
  final double metalGst;
  final double serviceGst;
  final String securityPin;

  const CompanyProfileModel({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.gst = '',
    this.address = '',
    this.state = '',
    this.bankDetails = '',
    this.terms = '',
    this.declaration = '',
    this.bannerPath = '',
    this.watermarkPath = '',
    this.metalGst = 3.0,
    this.serviceGst = 18.0,
    this.securityPin = '12345',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': 1, // Always a single row
      'name': name,
      'phone': phone,
      'email': email,
      'gst': gst,
      'address': address,
      'state': state,
      'bank_details': bankDetails,
      'terms': terms,
      'declaration': declaration,
      'banner_path': bannerPath,
      'watermark_path': watermarkPath,
      'metal_gst': metalGst,
      'service_gst': serviceGst,
      'security_pin': securityPin,
    };
  }

  factory CompanyProfileModel.fromMap(Map<String, dynamic> map) {
    return CompanyProfileModel(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      gst: map['gst'] ?? '',
      address: map['address'] ?? '',
      state: map['state'] ?? '',
      bankDetails: map['bank_details'] ?? '',
      terms: map['terms'] ?? '',
      declaration: map['declaration'] ?? '',
      bannerPath: map['banner_path'] ?? '',
      watermarkPath: map['watermark_path'] ?? '',
      metalGst: (map['metal_gst'] ?? 3.0).toDouble(),
      serviceGst: (map['service_gst'] ?? 18.0).toDouble(),
      securityPin: map['security_pin'] ?? '12345',
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyProfileModel.fromJson(String source) =>
      CompanyProfileModel.fromMap(json.decode(source));

  CompanyProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? gst,
    String? address,
    String? state,
    String? bankDetails,
    String? terms,
    String? declaration,
    String? bannerPath,
    String? watermarkPath,
    double? metalGst,
    double? serviceGst,
    String? securityPin,
  }) {
    return CompanyProfileModel(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      gst: gst ?? this.gst,
      address: address ?? this.address,
      state: state ?? this.state,
      bankDetails: bankDetails ?? this.bankDetails,
      terms: terms ?? this.terms,
      declaration: declaration ?? this.declaration,
      bannerPath: bannerPath ?? this.bannerPath,
      watermarkPath: watermarkPath ?? this.watermarkPath,
      metalGst: metalGst ?? this.metalGst,
      serviceGst: serviceGst ?? this.serviceGst,
      securityPin: securityPin ?? this.securityPin,
    );
  }
}
