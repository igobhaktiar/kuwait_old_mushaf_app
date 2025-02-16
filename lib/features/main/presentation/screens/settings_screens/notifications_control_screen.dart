import 'package:flutter/material.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/widgets/custom_switch_list_tile.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';

class NotificationsControlScreen extends StatelessWidget {
  const NotificationsControlScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.notifications_and_reminders),
          leading: AppConstants.customBackButton(context),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          NotificatiesWidgetList(
                            groupTitle: context.translate.notifications,
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]));
  }
}

class NotificatiesWidgetList extends StatefulWidget {
  NotificatiesWidgetList({
    required this.groupTitle,
    Key? key,
  }) : super(key: key);
  String groupTitle;

  @override
  State<NotificatiesWidgetList> createState() => _NotificatiesWidgetListState();
}

class _NotificatiesWidgetListState extends State<NotificatiesWidgetList> {
  bool isNotificationsEnabled = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            widget.groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
            child: InkWell(
              onTap: () {},
              child: CustomSwitchListTile(
                  title: context.translate.khatmah_daily_werd,
                  value: isNotificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      isNotificationsEnabled = value;
                    });
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
