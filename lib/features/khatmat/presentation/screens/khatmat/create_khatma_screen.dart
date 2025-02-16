import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/widgets/app_button.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/constants.dart';
import '../../cubit/khatmat_cubit.dart';

class CreateKhatmaScreen extends StatefulWidget {
  const CreateKhatmaScreen({Key? key}) : super(key: key);

  @override
  State<CreateKhatmaScreen> createState() => _CreateKhatmaScreenState();
}

class _CreateKhatmaScreenState extends State<CreateKhatmaScreen> {
  final TextEditingController _khatmahNameController = TextEditingController();
  int _selectedDaysNumber = 30;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.translate.quarn_khatmah),
          leading: AppConstants.customBackButton(context),
        ),
        //todo create khatma button goes here
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: AppButton(
              text: context.translate.create_khatma,
              height: 50,
              textColor: context.theme.elevatedButtonTheme.style!.textStyle!
                  .resolve({})!.color,
              color: context.theme.elevatedButtonTheme.style!.backgroundColor!
                  .resolve({})!,
              borderRadius: 15,
              width: MediaQuery.of(context).size.width - 50,
              onPressed: () {
                if (_khatmahNameController.text.isEmpty) {
                  AppConstants.showToast(context,
                      msg: context.translate
                          .make_sure_to_assign_a_name_to_the_new_khatmah,
                      color: Colors.red);
                } else {
                  context.read<KhatmatCubit>().createKhatmah(
                      days: _selectedDaysNumber,
                      name: _khatmahNameController.text);
                  Navigator.pop(context);
                  log("awrad number= ${(604 / _selectedDaysNumber).round()}");
                }
              }),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 39, horizontal: 17),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate.new_khatmah,
                style: context.textTheme.bodyMedium!
                    .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 25,
              ),
              Text(
                context.translate.suggested_khatmat,
                style: context.textTheme.bodyMedium!
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              //todo Ready-to-use khatmat go here
              for (int index = 0;
                  index < _readyToUseKhatmatList(context).length;
                  index++)
                InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDaysNumber =
                          _readyToUseKhatmatList(context)[index]["days"];
                    });
                  },
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      clipBehavior: Clip.antiAlias,
                      color: _selectedDaysNumber ==
                              _readyToUseKhatmatList(context)[index]["days"]
                          ? (context.theme.brightness == Brightness.dark
                              ? AppColors.innerSelectedOptionDark
                              : AppColors.inactiveColor)
                          : context.theme.brightness == Brightness.dark
                              ? context.theme.cardColor
                              : AppColors.lightGrey,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Container(
                        width: context.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "${_readyToUseKhatmatList(context)[index]["title"]} (${_readyToUseKhatmatList(context)[index]["days"]} ${context.translate.day_single_in_arabic})",
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: _selectedDaysNumber ==
                                          _readyToUseKhatmatList(context)[index]
                                              ["days"]
                                      ? AppColors.white
                                      : (context.theme.brightness ==
                                              Brightness.dark
                                          ? AppColors.border
                                          : AppColors.inactiveColor),
                                  fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 5,
                              width: context.width,
                            ),
                            SizedBox(
                              width: context.width,
                              child: Text(
                                '${context.translate.daily_werd}: ${_readyToUseKhatmatList(context)[index]["daily_werd"]} ${_readyToUseKhatmatList(context)[index]["daily_werd_arabic"]} ${context.translate.about}',
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: _selectedDaysNumber ==
                                            _readyToUseKhatmatList(
                                                context)[index]["days"]
                                        ? AppColors.white
                                        : (context.theme.brightness ==
                                                Brightness.dark
                                            ? AppColors.border
                                            : AppColors.inactiveColor),
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(
                height: 20,
              ),
              Text(
                context.translate.custom_khatmah,
                style: context.textTheme.bodyMedium!
                    .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Text(
                    context.translate.khatmah_duration,
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  ...ssss(context,
                      isReversed:
                          context.translate.localeName != AppStrings.arabicCode)
                ],
              ),
              const SizedBox(
                height: 10,
              ),

              const SizedBox(
                height: 10,
              ),
              //todo Khatma name goes here
              Row(
                children: [
                  Text(
                    context.translate.khatma_name,
                    style: context.textTheme.bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Container(
                        // width: MediaQuery.of(context).size.width / 1.8,
                        margin: const EdgeInsets.all(5),
                        child: TextField(
                          controller: _khatmahNameController,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : AppColors.inactiveColor,
                                    width: 2)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            hintText: context.translate.enter_khatma_name,
                            // labelText: 'اكتب هنا اسم الختمة',
                          ),
                        )),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> ssss(BuildContext context, {required bool isReversed}) {
    List<Widget> daysCountControls = [
      IconButton(
          onPressed: () {
            setState(() {
              _selectedDaysNumber++;
            });
          },
          icon: Icon(
            Icons.add,
            color: context.theme.primaryIconTheme.color,
          )),
      Expanded(
        child: Center(
          child: Text(
            "$_selectedDaysNumber ${_selectedDaysNumber <= 10 ? context.translate.days : context.translate.day_single_in_arabic}",
            style: context.textTheme.bodyMedium!
                .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
          ),
        ),
      ),
      IconButton(
          onPressed: () {
            setState(() {
              if (_selectedDaysNumber != 0) _selectedDaysNumber--;
            });
          },
          icon: Icon(
            Icons.remove,
            color: context.theme.primaryIconTheme.color,
          )),
    ];
    if (isReversed) {
      return daysCountControls.reversed.toList();
    }
    return daysCountControls;
  }

  List<Map<String, dynamic>> _readyToUseKhatmatList(BuildContext context) {
    return [
      {
        "title": context.translate.khatma_juz,
        "days": 30,
        "daily_werd": "21",
        "daily_werd_arabic": context.translate.page,
      },
      {
        "title": context.translate.khatma_hizb,
        "days": 60,
        "daily_werd": "10",
        "daily_werd_arabic": context.translate.pages,
      },
      {
        "title": context.translate.khatma_half_hizb,
        "days": 120,
        "daily_werd": "5",
        "daily_werd_arabic": context.translate.pages,
      },
    ];
  }
}
