import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/data_sources/all_ayat_with_tashkeel.dart';
import 'package:quran_app/core/default_dialog.dart';
import 'package:quran_app/core/utils/app_colors.dart' show AppColors;
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/assets_manager.dart' show AppAssets;
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/cubit/bookmarks_cubit.dart';
import 'package:quran_app/features/bookmarks/presentation/widgets/add_bookmark_dialog.dart';
import 'package:quran_app/features/bookmarks/presentation/widgets/share_ayah_as_image.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/bottom_sheet_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:share_plus/share_plus.dart';

showAyahOptionsDialog(BuildContext context, AyahModel ayah) async {
  context
      .read<AyatHighlightCubit>()
      .highlightAyah(ayah, releaseAfterPeriod: false);
  await Future.delayed(const Duration(milliseconds: 500));
  // ignore: use_build_context_synchronously
  showDefaultDialog(context,
      withSaveButton: false,
      title:
          "${context.translate.localeName == AppStrings.arabicCode ? ayah.surah : ayah.surahEnglish} - ${context.translate.the_ayah} ${ayah.numberInSurah}"
              .replaceAll(RegExp(r"سورة"), ''),
      content: Column(
        children: [
          DialogTile(
              title: context.translate.listen_to_ayah,
              svgIcon: AppAssets.play,
              onTap: () {
                context.read<ListeningCubit>().listenToAyah(ayah: ayah);
                context.read<BottomSheetCubit>().changeViewIndex(1);
                context.read<EssentialMoshafCubit>().showBottomSheetSections();

                Navigator.pop(context);
              }),
          DialogTile(
              title: context.translate.listen_from_this_ayah,
              svgIcon: AppAssets.play,
              onTap: () {
                context.read<ListeningCubit>().startListenFromAyah(ayah: ayah);
                context.read<BottomSheetCubit>().changeViewIndex(1);
                context.read<EssentialMoshafCubit>().showBottomSheetSections();
                Navigator.pop(context);
              }),
          DialogTile(
              title: context.translate.tafseer,
              svgIcon: AppAssets.tafseerActive,
              onTap: () {
                context.read<EssentialMoshafCubit>().showBottomSheetSections();
                context.read<BottomSheetCubit>().changeViewIndex(0);
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                Navigator.pop(context);
                FirebaseAnalytics.instance.logEvent(
                    name: AppStrings.analytcsEventShowTafseerForAyah,
                    parameters: {
                      "ayah": "${ayah.surah}-${ayah.numberInSurah}"
                    });
              }),
          DialogTile(
              title: context.translate.add_to_favs,
              svgIcon: AppAssets.starFilled,
              onTap: () {
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                BookmarksCubit.get(context).addFavourite(ayah: ayah);
                Navigator.pop(context);
              }),
          DialogTile(
              title: context.translate.add_to_bookmarks,
              svgIcon: AppAssets.bookmarkFilled,
              onTap: () {
                Navigator.pop(context);
                showAddBookmarkDialog(context, ayah);
              }),
          DialogTile(
              title: context.translate.show_khatmat_list,
              svgIcon: AppAssets.khatmahActive,
              onTap: () {
                Navigator.pop(context);
                context.read<EssentialMoshafCubit>().toggleRootView();
                context.read<EssentialMoshafCubit>().changeBottomNavBar(1);
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
              }),
          DialogTile(
              title: context.translate.share_ayah,
              svgIcon: AppAssets.shareIcon,
              onTap: () {
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                Navigator.pop(context);
                final shareAyahString =
                    '${allAyatWithTashkeel[ayah.number! - 1]['text']} \n آية رقم ${ayah.numberInSurah} \n ${ayah.surah} \n  مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}';
                Share.share(shareAyahString);
                FirebaseAnalytics.instance.logEvent(
                    name: AppStrings.analytcsEventShareAyahText,
                    parameters: {"ayah": "${ayah.number}"});
              }),
          DialogTile(
              title: context.translate.share_ayah_as_image,
              svgIcon: AppAssets.shareIcon,
              iconData: Icons.image,
              onTap: () {
                context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
                Navigator.pop(context);
                shareAyahAsImage(context, ayah: ayah);
              }),
        ],
      ), onDialogDismissed: () async {
    context.read<AyatHighlightCubit>().loadCurrentPageAyatSeg();
    log("dialog dissmissed");
    return true;
  });
}

class DialogTile extends StatelessWidget {
  const DialogTile({
    Key? key,
    required this.onTap,
    required this.title,
    required this.svgIcon,
    this.iconSize,
    this.iconData,
  }) : super(key: key);
  final String svgIcon;
  final VoidCallback onTap;
  final String title;
  final double? iconSize;
  final IconData? iconData;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: context.theme.brightness == Brightness.dark
          ? AppColors.cardBgDark
          : AppColors.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(children: [
            if (iconData == null)
              SvgPicture.asset(
                svgIcon,
                height: iconSize ?? 17,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.inactiveColor,
              ),
            if (iconData != null)
              Icon(
                iconData!,
                size: iconSize ?? 20,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.inactiveColor,
              ),
            const SizedBox(width: 12),
            Text(
              title,
              style: context.textTheme.bodyMedium!
                  .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
            ),
          ]),
        ),
      ),
    );
  }
}
