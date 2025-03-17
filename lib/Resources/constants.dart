import 'package:intl/intl.dart';

const double kPadding = 15;
const String kIconPath = "assets/icons";
const String kImagePath = "assets/images";

String kCurrencyFormat(dynamic number,
    {String symbol = "INR ", int decimalDigits = 2}) {
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

String amountInWords(int amount) {
  if (amount == 0) return "Zero";

  final List<String> units = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine"
  ];
  final List<String> teens = [
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen"
  ];
  final List<String> tens = [
    "",
    "Ten",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety"
  ];
  final List<String> thousands = ["", "Thousand", "Million", "Billion"];

  String convertChunk(int number) {
    String result = "";

    if (number >= 100) {
      result += "${units[number ~/ 100]} Hundred ";
      number %= 100;
    }

    if (number >= 11 && number <= 19) {
      result += "${teens[number - 11]} ";
    } else {
      if (number >= 10) {
        result += "${tens[number ~/ 10]} ";
        number %= 10;
      }
      if (number > 0) {
        result += "${units[number]} ";
      }
    }

    return result.trim();
  }

  String result = "";
  int chunkCount = 0;

  while (amount > 0) {
    int chunk = amount % 1000;
    if (chunk > 0) {
      String chunkInWords = convertChunk(chunk);
      result = "$chunkInWords ${thousands[chunkCount]} $result".trim();
    }
    amount ~/= 1000;
    chunkCount++;
  }

  return result.trim();
}
