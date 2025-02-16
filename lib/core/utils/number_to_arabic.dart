import 'package:flutter/material.dart';

String convertToArabicNumber(final String number) {
  String result = '';

  final arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  for (var element in number.characters) {
    result += arabics[int.parse(element)];
  }
  return result;
}
