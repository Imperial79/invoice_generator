import 'package:intl/intl.dart';

const double kPadding = 15;
const String kIconPath = "assets/icons";
const String kImagePath = "assets/images";

String kCurrencyFormat(dynamic number,
    {String symbol = "₹", int decimalDigits = 0}) {
  var f = NumberFormat.currency(
    symbol: symbol,
    locale: 'en_US',
    decimalDigits: decimalDigits,
  );
  return decimalDigits == 0
      ? f.format(double.parse("$number").round())
      : f.format(double.parse("$number"));
}

double parseToDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0; // Default fallback if the value is of an unexpected type
}

String thousandToK(dynamic number) {
  final num = parseToDouble(number);
  if (num < 1000) return num.toStringAsFixed(0);
  return "${(num / 1000).toStringAsFixed(1)}K";
}

String calculateDiscount(dynamic mrp, dynamic salePrice) {
  return (((parseToDouble(mrp) - parseToDouble(salePrice)) /
              parseToDouble(mrp)) *
          100)
      .round()
      .toString();
}

String kDateFormat(String date, {bool showTime = false, String? format}) {
  String formatter = "dd MMM, yyyy";
  if (showTime) {
    formatter += " - hh:mm a";
  }
  return DateFormat(format ?? formatter).format(DateTime.parse(date));
}
