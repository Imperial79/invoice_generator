import 'package:flutter/material.dart';
import 'package:invoice_generator/Resources/commons.dart';

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
            shape: RoundedRectangleBorder(
              borderRadius: kRadius(15),
            ),
            elevation: 0,
          ),
          child: child!),
    );
  }
}
