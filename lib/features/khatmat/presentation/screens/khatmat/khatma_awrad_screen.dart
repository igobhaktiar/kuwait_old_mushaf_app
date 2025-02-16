import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/features/khatmat/data/models/khatmah_model.dart';
import 'package:quran_app/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/encode_arabic_digits.dart';

class KhatmahAwradScreen extends StatefulWidget {
  const KhatmahAwradScreen({Key? key, required this.khatmahAwradBoxName})
      : super(key: key);
  final String khatmahAwradBoxName;

  @override
  State<KhatmahAwradScreen> createState() => _KhatmahAwradScreenState();
}

class _KhatmahAwradScreenState extends State<KhatmahAwradScreen> {
  Box<WerdModel>? khatmahAwradBox;
  @override
  void initState() {
    super.initState();
    Hive.openBox<WerdModel>(encodeArabbicCharToEn(widget.khatmahAwradBoxName))
        .then((openedBox) {
      setState(() {
        khatmahAwradBox = openedBox;
      });
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.khatmahAwradBoxName),
        leading: AppConstants.customBackButton(ctx),
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                ctx.translate.khatmah_awrad,
                style: ctx.textTheme.bodyMedium!.copyWith(fontSize: 24),
              ),
            ),
            Expanded(
                child: khatmahAwradBox == null
                    ? const CircularProgressIndicator()
                    : ValueListenableBuilder(
                        valueListenable: khatmahAwradBox!.listenable(),
                        builder: (context, Box box, widget) {
                          return ListView.separated(
                            separatorBuilder: ((context, index) => Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: const Divider(
                                    color: AppColors.border,
                                  ),
                                )),
                            physics: const ClampingScrollPhysics(),
                            itemCount: box.length,
                            itemBuilder: ((context, index) {
                              return WerdListTile(
                                  werdModel: box.getAt(index) as WerdModel);
                            }),
                          );
                        })),
          ],
        ),
      ),
    );
  }
}

class WerdListTile extends StatelessWidget {
  const WerdListTile({
    required this.werdModel,
    Key? key,
  }) : super(key: key);
  final WerdModel werdModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: SizedBox(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "${context.translate.the_werd} ${werdModel.id}",
                style: werdModel.isCompleted
                    ? context.textTheme.bodyMedium!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.bold)
                    : context.textTheme.bodySmall!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: context.theme.brightness == Brightness.dark
                            ? Colors.grey
                            : AppColors.hintColor),
              ),
              const Spacer(),
              if (werdModel.isCompleted) SvgPicture.asset(AppAssets.checkGreen)
            ],
          ),
        ),
      ),
    );
  }
}
