import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/app_strings.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/widgets/content_item.dart';
import 'package:quran_app/features/about_app/presentation/cubit/about_app_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
  _getAboutAppContent() =>
      BlocProvider.of<AboutAppCubit>(context).getContentOfAboutApp();

  @override
  void initState() {
    super.initState();
    _getAboutAppContent();
  }

  Widget _buildBodyContent() {
    return BlocBuilder<AboutAppCubit, AboutAppState>(
      builder: (context, state) {
        if (state is AboutAppError) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(AppStrings.aboutApp).listenable(),
            builder: (context, Box box, widget) {
              final content = box.get(AppStrings.aboutApp);
              log(content.toString(), name: 'aboutApp from hive');
              return ListView.builder(
                itemCount: content.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: ContentItem(
                      title: content[index].value.title,
                      body: content[index].value.body,
                    ),
                  );
                },
              );
            },
          );
        }
        if (state is AboutAppContentIsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }
        return ListView.builder(
          itemCount: context.read<AboutAppCubit>().content.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ContentItem(
                title: context.read<AboutAppCubit>().content[index].value.title,
                body: context.read<AboutAppCubit>().content[index].value.body,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.about_app),
        leading: AppConstants.customBackButton(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getAboutAppContent(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _buildBodyContent(),
        ),
      ),
    );
  }
}
