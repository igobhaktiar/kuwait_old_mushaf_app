import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';

class SwitchButton extends StatefulWidget {
  SwitchButton(
      {super.key,
      this.switchState = false,
      required this.onChanged,
      this.enabled = true});
  bool switchState;
  bool enabled;
  void Function(bool)? onChanged;
  @override
  _SwitchButtonState createState() => _SwitchButtonState();
}

class _SwitchButtonState extends State<SwitchButton> {
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1,
      child: CupertinoSwitch(
        // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        // splashRadius: 90,
        value: widget.enabled ? widget.switchState : false,
        onChanged: widget.onChanged,
        activeColor: context.isDarkMode ? Colors.grey : AppColors.inactiveColor,
        trackColor:
            context.isDarkMode ? AppColors.scaffoldBgDark : AppColors.border,
      ),
    );
  }
}
