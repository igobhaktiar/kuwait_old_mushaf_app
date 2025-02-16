import 'package:flutter/material.dart';
import 'package:quran_app/config/themes/theme_context.dart';

import 'switchButton.dart';

class CustomSwitchListTile extends StatelessWidget {
  const CustomSwitchListTile({
    required this.title,
    required this.value,
    this.enabled = true,
    required this.onChanged,
    this.subTitle,
    this.fontSize = 14,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final String title;
  final String? subTitle;
  final bool value;
  final bool enabled;
  final double fontSize;
  final void Function()? onTap;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 3, 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium!
                          .copyWith(fontSize: fontSize),
                    ),
                    if (subTitle != null)
                      const SizedBox(
                        height: 4,
                      ),
                    if (subTitle != null)
                      Text(
                        subTitle!,
                        style: context.textTheme.bodySmall!.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w300),
                      ),
                  ],
                ),
              ),
            ),
            // const Spacer(),

            SwitchButton(
              switchState: value,
              onChanged: onChanged,
              enabled: enabled,
            ),
            const SizedBox(
              width: 12,
            ),
          ],
        ),
      ),
    );
  }
}
