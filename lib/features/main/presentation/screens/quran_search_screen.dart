import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart' show AppStrings;
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:quran_app/features/essential_moshaf_feature/data/models/fihris_models.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/search_cubit.dart'
    show SearchCubit, SearchResultsFoundState, SearchState, StartSearchState;
import 'package:quran_app/features/main/data/search_word_index_getter.dart';
import 'package:quran_app/l10n/localization_context.dart';

class QuranSearch extends StatefulWidget {
  const QuranSearch({Key? key}) : super(key: key);

  @override
  State<QuranSearch> createState() => _QuranSearchState();
}

class _QuranSearchState extends State<QuranSearch> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    SearchCubit.get(context).getLastSearch();
    _searchController.text = SearchCubit.get(context).lastSearch;
    FirebaseAnalytics.instance
        .logScreenView(screenName: AppStrings.analytcsScreenSearchScreen);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchCubit, SearchState>(
      listener: (context, state) {},
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            appBar: AppBar(
              leading: AppConstants.customBackButton(context),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    image: context.isDarkMode
                        ? null
                        : const DecorationImage(
                            image: AssetImage(AppAssets.pattern),
                            fit: BoxFit.cover)),
              ),
              title: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ThemeData().colorScheme.copyWith(
                        primary: Colors.black,
                      ),
                ),
                child: TextFormField(
                  controller: _searchController,
                  textInputAction: TextInputAction.done,
                  onChanged: (searchWord) {
                    if (searchWord.length >= 3) {
                      SearchCubit.get(context).searchFor(searchWord);
                    } else {
                      SearchCubit.get(context).clearSearch();
                    }
                  },
                  autofocus: true,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).unfocus();
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: context.theme.brightness == Brightness.dark
                        ? context.theme.cardColor
                        : AppColors.backgroundColor,
                    contentPadding: const EdgeInsets.all(10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: context.theme.cardColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: context.theme.cardColor)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: context.isDarkMode
                              ? AppColors.white
                              : AppColors.primary,
                          width: 2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: IconButton(
                      icon: Icon(
                        Icons.search,
                        size: 22,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      onPressed: () {
                        SearchCubit.get(context)
                            .searchFor(_searchController.text);
                      },
                    ),
                    hintText: context.translate.enter_search_word,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 18,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      onPressed: () {
                        SearchCubit.get(context).clearSearch();
                        _searchController.clear();
                      },
                    ),
                  ),
                ),
              ),
              toolbarHeight: 80,
            ),
            body: const SearchResultsBody(),
          ),
        );
      },
    );
  }
}

class SearchResultsBody extends StatelessWidget {
  const SearchResultsBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(builder: (context, state) {
      if (state is StartSearchState) {
        return const NoSearchResultsFoundWidget();
      }
      if (state is SearchResultsFoundState) {
        return Padding(
          padding: EdgeInsets.all(context.width * 0.02),
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwarSearchReslutsList(
                      swarSearchResults: state.swarSearchResults),
                  const SizedBox(
                    height: 10,
                  ),
                  AyatSearchResultsList(
                      ayatSearchResults: state.ayatSearchResults),
                ]),
          ),
        );
      }
      return const NoSearchResultsFoundWidget();
    });
  }
}

class NoSearchResultsFoundWidget extends StatelessWidget {
  const NoSearchResultsFoundWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                AppAssets.noSearchResultsIcon,
                color: context.isDarkMode ? AppColors.white : null,
                height: 70,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(context.translate.there_are_no_current_search_results,
                  style: context.textTheme.bodyMedium!
                      .copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(
                height: 8,
              ),
              Text(
                  context.translate
                      .you_can_search_by_surah_name_or_by_word_within_a_surah,
                  style: context.textTheme.bodySmall!
                      .copyWith(fontSize: 16, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

class AyatSearchResultsList extends StatelessWidget {
  const AyatSearchResultsList({super.key, required this.ayatSearchResults});
  final List<AyahModel> ayatSearchResults;

  @override
  Widget build(BuildContext context) {
    return ayatSearchResults.isNotEmpty
        ? Column(
            children: [
              Container(
                alignment: context.translate.localeName == AppStrings.arabicCode
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                ),
                width: context.width,
                decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text(
                  '${context.translate.ayat} (${ayatSearchResults.length})',
                  style: context.textTheme.bodySmall!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  //todo: pass an ayahModel from the results List  to this widget
                  // todo: modify the state to contain both search results {ayat,swar} then build the complete results list
                  children: [
                    for (AyahModel ayahsearchResult in ayatSearchResults)
                      AyahSeearchResultTile(
                        ayahModel: ayahsearchResult,
                      )
                  ],
                ),
              )
            ],
          )
        : const SizedBox();
  }
}

class SwarSearchReslutsList extends StatelessWidget {
  const SwarSearchReslutsList({
    Key? key,
    required this.swarSearchResults,
  }) : super(key: key);
  final List<SurahFihrisModel> swarSearchResults;

  @override
  Widget build(BuildContext context) {
    return swarSearchResults.isNotEmpty
        ? Column(
            children: [
              //todo put swar here after title
              Container(
                alignment: Alignment.centerRight,
                height: 40,
                padding: const EdgeInsets.only(right: 20),
                width: context.width,
                decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text(
                  '${context.translate.swar} (${swarSearchResults.length})',
                  style: context.textTheme.bodySmall!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              for (SurahFihrisModel surahModel in swarSearchResults)
                SurahSearchResultTile(surahModel: surahModel),
            ],
          )
        : const SizedBox();
  }
}

class SurahSearchResultTile extends StatelessWidget {
  const SurahSearchResultTile({
    Key? key,
    required this.surahModel,
  }) : super(key: key);
  final SurahFihrisModel surahModel;

  @override
  Widget build(BuildContext context) {
    String lastSearch = SearchCubit.get(context).lastSearch;
    String surahNameLocale =
        context.translate.localeName == AppStrings.arabicCode
            ? surahModel.name.toString()
            : surahModel.englishName.toString();
    var beforeMatchPortion = getStringPortions(lastSearch, surahNameLocale)[0];
    var matchPortion = getStringPortions(lastSearch, surahNameLocale)[1];
    var afterMatchPortion = getStringPortions(lastSearch, surahNameLocale)[2];
    return InkWell(
      onTap: () => _goToSurahResult(context, surahModel),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            // Text(
            //   context.loc.localeName == AppStrings.arabicCode
            //       ? surahModel.name.toString()
            //       : surahModel.englishName.toString(),
            //   style: const TextStyle(
            //       fontSize: 18,
            //       height: 1.4,
            //       color: Colors.black,
            //       fontFamily: AppStrings.cairoFontFamily,
            //       fontWeight: FontWeight.w600),
            // ),
            RichText(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              text: TextSpan(children: [
                TextSpan(
                  text: beforeMatchPortion,
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 16, height: 1.9, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: matchPortion,
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 16, height: 1.9, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: afterMatchPortion,
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 16, height: 1.9, fontWeight: FontWeight.w400),
                ),
              ]),
            ),
            const Spacer(),
            Text(
              '${context.translate.the_page} (${surahModel.page})',
              style: context.textTheme.bodySmall!
                  .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    );
  }

  _goToSurahResult(BuildContext context, SurahFihrisModel surahModel) {
    context.read<EssentialMoshafCubit>().navigateToPage(surahModel.page!);
    context.read<EssentialMoshafCubit>().hideFlyingLayers();
    context.read<EssentialMoshafCubit>().hidePagesPopUp();
    context.read<AyatHighlightCubit>().highlightAyah(AyahModel(
          surahNumber: surahModel.number!,
          numberInSurah: 1,
        ));
    Navigator.pop(context);
  }
}

class AyahSeearchResultTile extends StatelessWidget {
  const AyahSeearchResultTile({
    Key? key,
    required this.ayahModel,
  }) : super(key: key);
  final AyahModel ayahModel;

  @override
  Widget build(BuildContext context) {
    String lastSearch = SearchCubit.get(context).lastSearch;
    var beforeMatchPortion =
        getStringPortions(lastSearch, ayahModel.text.toString())[0];
    var matchPortion =
        getStringPortions(lastSearch, ayahModel.text.toString())[1];
    var afterMatchPortion =
        getStringPortions(lastSearch, ayahModel.text.toString())[2];
    return InkWell(
      onTap: () => _goToAyahResult(context, ayahModel),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "${(context.translate.localeName == AppStrings.arabicCode ? ayahModel.surah.toString() : ayahModel.surahEnglish.toString()).replaceAll(RegExp(r"سورة"), '')} - ",
                  style: context.textTheme.bodyMedium!.copyWith(
                      fontSize: 18, height: 1.4, fontWeight: FontWeight.w600),
                ),
                Text(
                  "${context.translate.the_ayah} ${ayahModel.numberInSurah}",
                  style: context.textTheme.bodyMedium!
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  "${context.translate.the_page} (${ayahModel.page})",
                  style: context.textTheme.bodySmall!
                      .copyWith(fontSize: 14, fontWeight: FontWeight.w400),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                // color: Colors.blue,
                child: RichText(
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  text: TextSpan(children: [
                    TextSpan(
                      text: beforeMatchPortion,
                      style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          height: 1.9,
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: matchPortion,
                      style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          height: 1.9,
                          fontWeight: FontWeight.w400),
                    ),
                    TextSpan(
                      text: afterMatchPortion,
                      style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 16,
                          height: 1.9,
                          fontWeight: FontWeight.w400),
                    ),
                  ]),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  _goToAyahResult(BuildContext context, AyahModel ayahModel) {
    context.read<EssentialMoshafCubit>().navigateToPage(ayahModel.page!);
    context.read<EssentialMoshafCubit>().hideFlyingLayers();
    context.read<EssentialMoshafCubit>().hidePagesPopUp();
    Navigator.pop(context);
    context.read<AyatHighlightCubit>().highlightAyah(ayahModel);
  }
}
