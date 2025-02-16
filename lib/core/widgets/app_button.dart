import 'package:flutter/material.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';

class AppButton extends StatelessWidget {
  String text;
  Widget icon;
  double width;
  double height;
  Color color;
  Color? textColor;
  dynamic onPressed;
  BorderSide? side;
  bool hasSide;
  double borderRadius;
  bool isSmall = false;
  AppButton({
    this.hasSide = false,
    this.color = AppColors.primary,
    this.side,
    this.textColor = AppColors.white,
    required this.text,
    this.borderRadius = 30.0,
    this.icon = const SizedBox(),
    required this.height,
    this.width = double.infinity,
    required this.onPressed,
    // this.callback = callback ?? (() {})
    Key? key,
  }) : super(key: key);

  AppButton.small({
    super.key,
    this.hasSide = false,
    this.color = AppColors.primary,
    this.side = const BorderSide(),
    required this.text,
    this.borderRadius = 30.0,
    required this.onPressed,
    this.height = 10,
    this.width = 60,
    this.icon = const SizedBox(),
  }) {
    isSmall = true;
  }

  @override
  Widget build(BuildContext context) {
    return isSmall
        ? InkWell(
            onTap: onPressed,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                text,
                style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.activeButtonColor,
                    fontFamily: AppStrings.cairoFontFamily,
                    fontWeight: FontWeight.w600),
              ),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      color: textColor,
                      fontFamily: AppStrings.cairoFontFamily,
                      fontWeight: FontWeight.w700),
                )),
            style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                fixedSize: Size(width, height),
                side: side,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius))),
          );
  }
}
