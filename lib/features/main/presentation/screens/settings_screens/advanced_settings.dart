import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_switch_list_tile.dart';

class AdvancedSettingScreen extends StatelessWidget {
  const AdvancedSettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.advanced_settings),
          leading: AppConstants.customBackButton(context),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          AdvancedsettingWidgetList(
                            groupTitle: context.translate.advanced_settings,
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

class AdvancedsettingWidgetList extends StatefulWidget {
  AdvancedsettingWidgetList({
    required this.groupTitle,
    Key? key,
  }) : super(key: key);

  String groupTitle;

  @override
  State<AdvancedsettingWidgetList> createState() =>
      _AdvancedsettingWidgetListState();
}

class _AdvancedsettingWidgetListState extends State<AdvancedsettingWidgetList> {
  bool isSwitched = false;

  @override
  void initState() {
    isSwitched = context.read<BookmarksCubit>().showBookmarksOnStartEnabled;
    super.initState();
  }

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
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              BlocBuilder<ListeningCubit, ListeningState>(
                buildWhen: (_, cur) => cur is ChangeEnablePlayInBackgroundState,
                builder: (context, state) {
                  return CustomSwitchListTile(
                      title: context.translate.listen_in_background,
                      value:
                          context.read<ListeningCubit>().enablePlayInBackground,
                      onChanged: (value) {
                        context
                            .read<ListeningCubit>()
                            .setEnablePlayInBackground(value);
                      });
                },
              ),
              AppConstants.appDivider(context, endIndent: 20, indent: 20),
              BlocBuilder<BookmarksCubit, BookmarksState>(
                builder: (context, state) {
                  var cubit = context.read<BookmarksCubit>();
                  return CustomSwitchListTile(
                      title: context.translate.show_bookmarks_at_start,
                      subTitle: cubit.bookmarksBox.isEmpty
                          ? context
                              .translate.add_abookmark_to_unlock_this_option
                          : null,
                      enabled: cubit.bookmarksBox.isNotEmpty,
                      value: isSwitched,
                      onChanged: (value) {
                        setState(() {
                          isSwitched = value;
                          print("isSwitched=$isSwitched");
                        });
                        context
                            .read<BookmarksCubit>()
                            .setShowBookmarksOnStart(value);
                      });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
