import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';

class RootApp extends StatelessWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EssentialMoshafCubit, EssentialMoshafState>(
      listener: (context, state) {},
      builder: (context, state) {
        final cubit = EssentialMoshafCubit.get(context);

        return Scaffold(
          body: cubit.mainViewbottomScreens[cubit.homeViewBottomNavIndex],
          bottomNavigationBar: Container(
            height: MediaQuery.of(context).orientation == Orientation.landscape
                ? context.height * 0.16
                : null,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).orientation == Orientation.portrait
                  ? context.height * 0.02
                  : 0,
            ),
            decoration: BoxDecoration(
                border:
                    Border.all(color: context.theme.dividerColor, width: 2)),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: BottomNavigationBar(
                onTap: (final int index) => cubit.changeBottomNavBar(index),
                type: BottomNavigationBarType.fixed,
                backgroundColor:
                    context.theme.bottomNavigationBarTheme.backgroundColor,
                currentIndex: cubit.homeViewBottomNavIndex,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.black,
                elevation: 10,
                items: [
                  BottomNavigationBarItem(
                      activeIcon: SvgPicture.asset(
                        AppAssets.fihrisActive,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      icon: SvgPicture.asset(
                        AppAssets.fihris,
                        color: context.theme.iconTheme.color,
                      ),
                      label: ''),
                  BottomNavigationBarItem(
                      activeIcon: SvgPicture.asset(
                        AppAssets.khatmahActive,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      icon: SvgPicture.asset(
                        AppAssets.khatmah,
                        color: context.theme.iconTheme.color,
                      ),
                      label: ''),
                  BottomNavigationBarItem(
                      activeIcon: SvgPicture.asset(
                        AppAssets.starActive,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      icon: SvgPicture.asset(
                        AppAssets.star,
                        color: context.theme.iconTheme.color,
                      ),
                      label: ''),
                  BottomNavigationBarItem(
                      activeIcon: SvgPicture.asset(
                        AppAssets.booksActive,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      icon: SvgPicture.asset(
                        AppAssets.booksDisabled,
                        color: context.theme.iconTheme.color,
                      ),
                      label: ''),
                  BottomNavigationBarItem(
                      activeIcon: SvgPicture.asset(
                        AppAssets.gearActive,
                        color: context.theme.primaryIconTheme.color,
                      ),
                      icon: SvgPicture.asset(
                        AppAssets.gear,
                        color: context.theme.iconTheme.color,
                      ),
                      label: ''),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
