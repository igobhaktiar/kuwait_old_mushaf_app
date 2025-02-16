import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/content_item.dart';
import '../cubit/privacy_policy_cubit.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  _getPrivacyPolicy() =>
      BlocProvider.of<PrivacyPolicyCubit>(context).getPrivacyPolicy();

  @override
  void initState() {
    super.initState();
    _getPrivacyPolicy();
  }

  Widget _buildBodyContent() {
    return BlocBuilder<PrivacyPolicyCubit, PrivacyPolicyState>(
      builder: (context, state) {
        if (state is PrivacyPolicyStateError) {
          return ValueListenableBuilder(
            valueListenable: Hive.box(AppStrings.privacyPolicy).listenable(),
            builder: (context, Box box, widget) {
              var content = box.get(AppStrings.privacyPolicyBoxKey);
              log(content.toString(), name: 'privacy from hive');
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
        if (state is PrivacyPolicyStateIsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }
        return ListView.builder(
          itemCount: context.read<PrivacyPolicyCubit>().content.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(5.0),
              child: ContentItem(
                title: context
                    .read<PrivacyPolicyCubit>()
                    .content[index]
                    .value
                    .title,
                body: context
                    .read<PrivacyPolicyCubit>()
                    .content[index]
                    .value
                    .body,
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
        title: Text(context.translate.privacy_policy),
        leading: AppConstants.customBackButton(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => _getPrivacyPolicy(),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: _buildBodyContent(),
        ),
      ),
    );
  }
}
