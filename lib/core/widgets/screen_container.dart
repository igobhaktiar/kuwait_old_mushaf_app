import 'package:flutter/material.dart';

class ScreenContainer extends StatelessWidget {
  final Widget child;
  const ScreenContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: child,
          ),
        ));
  }
}
