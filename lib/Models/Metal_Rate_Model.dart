import 'dart:convert';

class MetalRateModel {
  final String metalType; // Gold, Silver, Platinum
  final String purity; // 24K, 22K, 18K, 14K or 'Base' for Silver/Platinum
  final double ratePer10g;

  MetalRateModel({
    required this.metalType,
    required this.purity,
    required this.ratePer10g,
  });

  Map<String, dynamic> toMap() {
    return {
      'metalType': metalType,
      'purity': purity,
      'ratePer10g': ratePer10g,
    };
  }

  factory MetalRateModel.fromMap(Map<String, dynamic> map) {
    return MetalRateModel(
      metalType: map['metalType'] ?? '',
      purity: map['purity'] ?? '',
      ratePer10g: (map['ratePer10g'] ?? 0.0).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory MetalRateModel.fromJson(String source) =>
      MetalRateModel.fromMap(json.decode(source));
}
