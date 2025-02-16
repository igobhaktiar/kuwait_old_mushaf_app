import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  double get topPadding => MediaQuery.of(this).viewPadding.top;
  double get bottom => MediaQuery.of(this).viewPadding.bottom;
  bool get isLandscape =>
      MediaQuery.of(this).orientation == Orientation.landscape;
}
