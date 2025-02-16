import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/features/terms_and_conditions/presentation/cubit/terms_and_conditions_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/content_item.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() =>
      _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  _getTermsAndConditions() =>
      BlocProvider.of<TermsAndConditionsCubit>(context).getTermsAndConditions();

  @override
  void initState() {
    super.initState();
    _getTermsAndConditions();
  }

  Widget _buildBodyContent() {
    return BlocBuilder<TermsAndConditionsCubit, TermsAndConditionsState>(
        builder: (context, state) {
      if (state is TermsAndConditionsError) {
        return ValueListenableBuilder(
          valueListenable: Hive.box(AppStrings.termsAndConditions).listenable(),
          builder: (context, Box box, widget) {
            var content = box.get(AppStrings.termsAndConditionsBoxKey);
            log(content.toString(), name: 'terms from hive');
            return ListView.builder(
              itemCount: content.length,
              itemBuilder: (context, index) {
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
      if (state is TermsAndConditionstIsLoading) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        );
      }
      return ListView.builder(
        itemCount: context.read<TermsAndConditionsCubit>().content.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(5.0),
            child: ContentItem(
              title: context
                  .read<TermsAndConditionsCubit>()
                  .content[index]
                  .value
                  .title,
              body: context
                  .read<TermsAndConditionsCubit>()
                  .content[index]
                  .value
                  .body,
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.terms_of_use),
        leading: AppConstants.customBackButton(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getTermsAndConditions(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _buildBodyContent(),
        ),
      ),
    );
  }
}
