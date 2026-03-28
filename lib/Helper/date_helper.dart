import 'package:flutter/material.dart';
import 'package:prime_invoice/Resources/commons.dart';

class DateHelper {
  static Future<DateTime?> pickDate(
    BuildContext context, {
    DateTime? currentDate,
  }) async {
    return await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
      currentDate: currentDate,
      builder: (context, child) => DatePickerTheme(
        data: DatePickerThemeData(
          shape: RoundedRectangleBorder(borderRadius: kRadius(15)),
          elevation: 0,
        ),
        child: child!,
      ),
    );
  }

  static Future<DateTimeRange?> pickDateRange(
    BuildContext context, {
    DateTimeRange? initialDateRange,
  }) async {
    return await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: initialDateRange,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: DatePickerThemeData(
            shape: RoundedRectangleBorder(borderRadius: kRadius(15)),
            elevation: 0,
          ),
        ),
        child: child!,
      ),
    );
  }
}
