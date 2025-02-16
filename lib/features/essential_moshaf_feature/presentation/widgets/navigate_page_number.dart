import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;
import 'package:quran_app/features/essential_moshaf_feature/presentation/widgets/lr_page_number_navigation.dart';

///* This Widget is reponsible for builing and handling the bottom navigation scrollable listView
///* which navigates over the Quran by selecting page number directly inside reading mode without going to the Index screen
///
class NavigateByPageNumberListView extends StatelessWidget {
  const NavigateByPageNumberListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
        builder: (BuildContext context, EssentialMoshafState state) {
          final cubit = EssentialMoshafCubit.get(context);
          return AnimatedContainer(
            duration: AppConstants.enteringAnimationDuration,
            curve: Curves.easeOut,
            height: cubit.isShowNavigateByPage ? 100.0 : 0,
            width: context.width,
            padding: const EdgeInsets.symmetric(vertical: 15),
            color:
                context.isDarkMode ? AppColors.cardBgDark : AppColors.lightGrey,
            child: ListView.builder(
              itemCount: 302,
              scrollDirection: Axis.horizontal,
              controller: EssentialMoshafCubit.get(context)
                  .navigateByPageNumberController,
              itemBuilder: (BuildContext context, int index) {
                final rightPage = index * 2 + 1;
                return RightAndLeftPageIndicator(rightPage: rightPage);
              },
            ),
          );
        },
      ),
    );
  }
}
