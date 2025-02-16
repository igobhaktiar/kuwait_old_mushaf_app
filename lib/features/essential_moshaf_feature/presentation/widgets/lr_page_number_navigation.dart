import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/encode_arabic_digits.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;

class RightAndLeftPageIndicator extends StatelessWidget {
  const RightAndLeftPageIndicator({
    Key? key,
    required this.rightPage,
  }) : super(key: key);
  final int rightPage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (context, state) {
        int currantPage = EssentialMoshafCubit.get(context).currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            width: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 37,
                  width: 64,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: context.isDarkMode
                        ? AppColors.scaffoldBgDark
                        : AppColors.lightBrown,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //* page widget
                      for (int c in [rightPage, rightPage + 1])
                        InkWell(
                          onTap: () {
                            EssentialMoshafCubit.get(context).navigateToPage(c);
                          },
                          child: Container(
                            width: 20,
                            height: 30,
                            decoration: BoxDecoration(
                                color: currantPage == c - 1
                                    ? context.isDarkMode
                                        ? AppColors.white
                                        : AppColors.inactiveColor
                                    : context.isDarkMode
                                        ? Color(0xff423E3E)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color: context.isDarkMode
                                        ? AppColors.white
                                        : AppColors.border,
                                    width: 1)),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 1; i <= 3; i++)
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      height: 1.5,
                                      width: 12,
                                      color: currantPage == c - 1
                                          ? context.isDarkMode
                                              ? AppColors.activeButtonColor
                                              : AppColors.border
                                          : context.isDarkMode
                                              ? AppColors.white
                                              : AppColors.border,
                                    )
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),

                //*the two numbers
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    for (int page in [rightPage, rightPage + 1])
                      Text(
                        encodeToArabicNumbers(inputInteger: page),
                        // encodeToArabicNumbers(inputInteger: page),
                        style: context.textTheme.bodySmall!.copyWith(
                            color: (page ==
                                    EssentialMoshafCubit.get(context)
                                            .currentPage +
                                        1)
                                ? (context.isDarkMode
                                    ? Colors.white
                                    : AppColors.inactiveColor)
                                : (context.isDarkMode
                                    ? Colors.grey
                                    : AppColors.hintColor),
                            fontSize: 16,
                            fontFamily: AppStrings.uthmanyFontFamily),
                      ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
