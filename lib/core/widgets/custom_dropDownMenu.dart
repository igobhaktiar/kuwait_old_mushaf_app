import 'package:flutter/material.dart';

import 'package:quran_app/config/themes/theme_context.dart';

import '../utils/app_colors.dart';

class CustomDropDownMenu extends StatefulWidget {
  CustomDropDownMenu(
      {Key? key,
      required this.value,
      required this.items,
      required this.onChanged,
      this.hintText})
      : super(key: key);

  String value;
  final List<String> items;
  final String? hintText;
  final void Function(dynamic)? onChanged;

  @override
  State<CustomDropDownMenu> createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
                border: Border.all(color: AppColors.lightGrey, width: 1),
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(
                      offset: Offset(0, 1),
                      color: AppColors.shadowColor,
                      blurRadius: 2)
                ]),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                isExpanded: false,
                hint: widget.hintText != null
                    ? Text(
                        widget.hintText.toString(),
                        style: context.textTheme.bodyMedium,
                      )
                    : null,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: context.theme.primaryIconTheme.color,
                ),
                value: widget.value,
                items: widget.items.map(_buiilDropDownMenuItem).toList(),
                onChanged: widget.onChanged,
                borderRadius: BorderRadius.circular(5),
                dropdownColor: context.theme.cardColor,
                menuMaxHeight: MediaQuery.of(context).size.hashCode * 0.9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<dynamic> _buiilDropDownMenuItem(String item) =>
      DropdownMenuItem(
        value: item,
        onTap: () {
          setState(() {
            widget.value = item;
          });
        },
        child: Text(item),
      );
}

// /// method to return a list of ayat icluded in the selected surah
