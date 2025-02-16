import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/tafseer/data/models/tafseer_model.dart';
import 'package:quran_app/features/tafseer/presentation/cubit/tafseer_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/assets_manager.dart';

class TafseerListView extends StatelessWidget {
  const TafseerListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<TafseerCubit, TafseerState>(
        builder: (context, state) {
          if (state is PageTafseersLoaded && state.tafseers.isNotEmpty) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  for (AyahTafseerModel ayahTafseer in state.tafseers)
                    TafseerAyahWidget(
                      tafseerModel: ayahTafseer,
                    )
                ],
              ),
            );
          } else {
            return Center(
              child: Text(context.translate.tafseer_not_available_currently),
            );
          }
        },
      ),
    );
  }
}

class TafseerAyahWidget extends StatelessWidget {
  const TafseerAyahWidget({Key? key, required this.tafseerModel})
      : super(key: key);
  final AyahTafseerModel tafseerModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  tafseerModel.text.toString(),
                  strutStyle: const StrutStyle(
                    height: 2.5,
                    forceStrutHeight: true,
                  ),
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontSize: 22,
                    // fontFamily: findProperFontForPage(page: tafseerModel.page!),
                    fontFamily: AppStrings.uthmanyHafsV20fontFamily,
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    var shareText =
                        "{${tafseerModel.text}} [${tafseerModel.surah}:${tafseerModel.numberInSurah}]\n${tafseerModel.tafseer}";
                    Share.share(shareText);
                  },
                  icon: SvgPicture.asset(
                    AppAssets.shareIcon,
                    color: context.theme.primaryIconTheme.color,
                    width: 18,
                  ))
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              tafseerModel.tafseer.toString(),
              style: context.textTheme.bodyMedium!
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
              strutStyle: const StrutStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
