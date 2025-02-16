import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/core/widgets/app_button.dart';
import 'package:quran_app/features/khatmat/presentation/cubit/khatmat_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/constants.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../data/models/khatmah_model.dart';
import 'create_khatma_screen.dart';
import 'khatma_details.dart';

class KhatmatScreen extends StatefulWidget {
  const KhatmatScreen({
    Key? key,
    //  this.payload
  }) : super(key: key);
  // String? payload;

  @override
  State<KhatmatScreen> createState() => _KhatmatScreenState();
}

class _KhatmatScreenState extends State<KhatmatScreen> {
  @override
  void initState() {
    super.initState();
  }

  _navigateToNotifiedKhatmah(String payload) {
    if (payload.contains("kh_")) {
      var extractedDateCreatedString = payload.split("_").toList().last;
      var extractedDateCreatedObject =
          DateTime.tryParse(extractedDateCreatedString);
      if (extractedDateCreatedObject != null) {
        List<KhatmahModel> availableKhatmatList = KhatmatCubit.get(context)
            .khatmatBox
            .values
            .toList()
            .where(
                (element) => element.dateCreated == extractedDateCreatedObject)
            .toList();
        var fetchedKhatmahModel =
            availableKhatmatList.isNotEmpty ? availableKhatmatList.first : null;

        Future.delayed(const Duration(seconds: 1), () {
          if (fetchedKhatmahModel != null) {
            pushSlide(context,
                screen: KhatmaDetails(khatmahModel: fetchedKhatmahModel));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
      listener: (context, state) {
        if (state is SelectedKhatmahPayloadFromNotification) {
          _navigateToNotifiedKhatmah(state.payload);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.translate.quarn_khatmah),
            leading: AppConstants.customBackButton(context, onPressed: () {
              EssentialMoshafCubit.get(context).toggleRootView();
            }),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                  image: context.isDarkMode
                      ? null
                      : const DecorationImage(
                          image: AssetImage(AppAssets.pattern),
                          fit: BoxFit.cover)),
            ),
          ),
          body: SafeArea(
            child: BlocBuilder<KhatmatCubit, KhatmatState>(
              builder: (context, state) {
                var cubit = KhatmatCubit.get(context);
                return ValueListenableBuilder(
                  valueListenable: cubit.khatmatBoxListenable,
                  builder: (context, Box box, widget) {
                    return box.isEmpty
                        ? const NoKhatmatAvailableView()
                        : SingleChildScrollView(
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    for (int i = 0; i < box.length; i++)
                                      KhatmaListTile(
                                          context, box.getAt(i) as KhatmahModel,
                                          index: i),
                                  ],
                                ),
                              ],
                            ),
                          );
                  },
                );
              },
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(15.0),
            child: AppButton(
                text: context.translate.create_khatma,
                textColor: context.theme.elevatedButtonTheme.style!.textStyle!
                    .resolve({})!.color,
                color: context.theme.elevatedButtonTheme.style!.backgroundColor!
                    .resolve({})!,
                height: 50,
                borderRadius: 15,
                width: MediaQuery.of(context).size.width - 50,
                onPressed: () {
                  pushSlide(context, screen: const CreateKhatmaScreen());
                }),
          ),
        );
      },
    );
  }
}

class KhatmaListTile extends StatelessWidget {
  const KhatmaListTile(
    BuildContext context,
    this.khatmahModel, {
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;
  final KhatmahModel khatmahModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(6),
      clipBehavior: Clip.antiAlias,
      color: context.theme.cardColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: InkWell(
          onTap: () => pushSlide(context,
              screen: KhatmaDetails(khatmahModel: khatmahModel)),
          child: Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    AppAssets.mushafIcon,
                    fit: BoxFit.contain,
                    height: 20,
                    width: 25,
                    color: context.isDarkMode ? Colors.white : null,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Text(
                      khatmahModel.title,
                      style: context.textTheme.bodyMedium!
                          .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.translate.date_created,
                    style: context.textTheme.bodySmall!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    khatmahModel.dateCreated
                        .toLocal()
                        .toString()
                        .split(" ")
                        .first
                        .split("-")
                        .toList()
                        .reversed
                        .toList()
                        .toString()
                        .replaceAll(RegExp(r"\[|\]"), "")
                        .replaceAll(", ", "/"),
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  // const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: context.theme.primaryIconTheme.color,
                    size: 16,
                  ),
                  // const SizedBox(
                  //   width: 12,
                  // ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.translate.completed_awrad,
                    style: context.textTheme.bodySmall!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "${khatmahModel.completedAwradCount} ${context.translate.of_from} ${khatmahModel.totalAwradCount}",
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoKhatmatAvailableView extends StatelessWidget {
  const NoKhatmatAvailableView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              AppAssets.mushafIcon,
              color: context.isDarkMode ? Colors.white : null,
            ),
            const SizedBox(
              height: 18,
            ),
            Text(context.translate.no_khatmat,
                style: context.textTheme.bodyMedium!
                    .copyWith(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(
              height: 8,
            ),
            Text(context.translate.no_khatmat_msg,
                style: context.textTheme.bodySmall!
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w400)),
          ]),
    );
  }
}
