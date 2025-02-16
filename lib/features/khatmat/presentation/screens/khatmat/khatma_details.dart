import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/core/utils/slide_pagee_transition.dart';
import 'package:quran_app/core/widgets/app_button.dart';
import 'package:quran_app/core/widgets/custom_switch_list_tile.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/khatmat/data/models/khatmah_model.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/utils/encode_arabic_digits.dart';
import '../../../../../notification_service.dart';
import '../../cubit/khatmat_cubit.dart';
import 'khatma_awrad_screen.dart';

class KhatmaDetails extends StatefulWidget {
  const KhatmaDetails({Key? key, required this.khatmahModel}) : super(key: key);
  final KhatmahModel khatmahModel;

  @override
  State<KhatmaDetails> createState() => _KhatmaDetailsState();
}

class _KhatmaDetailsState extends State<KhatmaDetails> {
  Box<WerdModel>? khatmahAwradBox;

  @override
  void initState() {
    super.initState();
    Hive.openBox<WerdModel>(encodeArabbicCharToEn(widget.khatmahModel.title))
        .then((openedBox) {
      setState(() {
        khatmahAwradBox = openedBox;
      });
    });
  }

  //*notifications methods started
  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestExactAlarmsPermission();
      setState(() {});
    }
  }

  //! show notifications

  Future<void> _zonedScheduleNotification() async {
    var selectedTime = await _selectTime();
    if (selectedTime == null) {
      KhatmatCubit.get(context)
          .enableNotification(widget.khatmahModel, value: false);
      _cancelNotificationsForThisKhatmah();
      _logPendingNotificationsRequestList();
      return;
    } else {
      _cancelNotificationsForThisKhatmah();
      KhatmatCubit.get(context).enableNotification(widget.khatmahModel,
          value: true, time: DateTime(selectedTime.hour, selectedTime.minute));
      _requestPermissions();
      await flutterLocalNotificationsPlugin.zonedSchedule(
        widget.khatmahModel.dateCreated.microsecond,
        context.translate.quarn_khatmah,
        '${context.translate.its_time_to_read_your_daily_werd_from}${widget.khatmahModel.title}',
        _scheduleDaily(DateTime(selectedTime.hour, selectedTime.minute)),
        // tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
                'schedduled notification', 'schedduled werd notification',
                channelDescription:
                    'schedduled werd notification channel description')),
        payload: "kh_${widget.khatmahModel.dateCreated.toLocal()}",
        matchDateTimeComponents: DateTimeComponents
            .time, //solution for repeat the scheduled notifications
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exact,
      );
      _logPendingNotificationsRequestList();
    }
  }

  tz.TZDateTime _scheduleDaily(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day,
        time.hour, time.minute, time.second);
    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  Future<TimeOfDay?> _selectTime() async {
    return await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            DateTime.now().add(const Duration(minutes: 1))));
  }

  _cancelNotificationsForThisKhatmah() async {
    await flutterLocalNotificationsPlugin.cancel(
      widget.khatmahModel.dateCreated.microsecond,
    );
    _logPendingNotificationsRequestList();
    log("cancelled notification ${widget.khatmahModel.title}");
  }

  Future<void>? _scheduleKhatmahDailyWerdNotification() {
    return null;
  }

  //*notifications methods ended

  @override
  void dispose() {
    khatmahAwradBox!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.quarn_khatmah),
        leading: AppConstants.customBackButton(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 39, horizontal: 17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //todo: khatma title goes here
            Text(
              widget.khatmahModel.title,
              style: context.textTheme.bodyMedium!
                  .copyWith(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(
              height: 25,
            ),
            if (khatmahAwradBox != null)
              ValueListenableBuilder(
                  valueListenable: khatmahAwradBox!.listenable(),
                  builder: (context, Box box, widget2) {
                    List<WerdModel> allAwrad = khatmahAwradBox!.values.toList();
                    var currentWerd = allAwrad
                        .firstWhere((werd) => !werd.isCompleted, orElse: () {
                      return allAwrad.last;
                    });

                    return CurrentWerdWidget(
                      currentWerd: currentWerd,
                      awradBox: khatmahAwradBox!,
                      currentKhatmah: widget.khatmahModel,
                    );
                  }),
            const SizedBox(
              height: 20,
            ),
            //todo: khatma notification switch goes here
            Text(
              context.translate.notify,
              style: context.textTheme.bodySmall!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 12,
            ),
            Card(
              elevation: 0,
              margin: const EdgeInsets.all(10),
              clipBehavior: Clip.antiAlias,
              color: context.theme.cardColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: ValueListenableBuilder(
                  valueListenable:
                      KhatmatCubit.get(context).khatmatBoxListenable,
                  builder: (context, Box box, widget2) {
                    var availableKhatmat = KhatmatCubit.get(context)
                        .khatmatBox
                        .values
                        .toList()
                        .where((element) =>
                            element.dateCreated ==
                            widget.khatmahModel.dateCreated)
                        .toList();
                    KhatmahModel? realtimeKhatmah = availableKhatmat.isNotEmpty
                        ? availableKhatmat.first
                        : null;
                    String? timeFormatted;
                    if (realtimeKhatmah != null &&
                        realtimeKhatmah.timeForDailyWerdNotification != null) {
                      var rawTime = realtimeKhatmah
                          .timeForDailyWerdNotification!
                          .split(":")
                          .toList();
                      var hours = int.parse(rawTime[0]);
                      var minutes = int.parse(rawTime[1]);
                      var minutesFormatted = minutes.toString().length == 1
                          ? "0$minutes"
                          : minutes.toString();
                      var isPM = hours > 12;
                      var hoursFormatted = hours == 0
                          ? 12
                          : isPM
                              ? hours - 12
                              : hours;
                      timeFormatted =
                          "$hoursFormatted:$minutesFormatted ${isPM ? context.translate.pm : context.translate.am}";
                    }
                    return realtimeKhatmah == null
                        ? const SizedBox()
                        : CustomSwitchListTile(
                            title: context.translate.daily_werd,
                            fontSize: 16,
                            subTitle: realtimeKhatmah.notificationStatus &&
                                    realtimeKhatmah
                                            .timeForDailyWerdNotification !=
                                        null
                                ? timeFormatted
                                : null,
                            value: realtimeKhatmah.notificationStatus,
                            onChanged: (value) {
                              if (value) {
                                // showInstantNotification();
                                _zonedScheduleNotification();
                              } else {
                                KhatmatCubit.get(context).enableNotification(
                                    widget.khatmahModel,
                                    value: false);
                                _cancelNotificationsForThisKhatmah();
                              }
                            },
                            onTap: () {
                              _zonedScheduleNotification();
                            },
                          );
                  }),
            ),
            const SizedBox(
              height: 12,
            ),
            const SizedBox(
              height: 20,
            ),
            //todo: khatma awrad list button goes here
            Text(
              context.translate.awrad_fihris,
              style: context.textTheme.bodySmall!
                  .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 12,
            ),
            InkWell(
              onTap: () => pushSlide(context,
                  screen: KhatmahAwradScreen(
                      khatmahAwradBoxName: widget.khatmahModel.title)),
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                color: context.theme.cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        context.translate.total_werds,
                        style: context.textTheme.bodyMedium!.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${widget.khatmahModel.totalAwradCount}",
                            style: context.textTheme.bodyMedium!.copyWith(
                                fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: context.theme.brightness == Brightness.dark
                                ? AppColors.white
                                : Colors.black,
                            size: 20,
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
            //todo: Delete khatma button goes here
            InkWell(
              onTap: () {
                AppConstants.showConfirmationDialog(context,
                    confirmMsg: context.translate
                        .are_you_sure_to_delete_this_khatmah, okCallback: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  context
                      .read<KhatmatCubit>()
                      .deleteKhatmah(widget.khatmahModel);
                });
              },
              child: Card(
                elevation: 0,
                margin: const EdgeInsets.all(10),
                clipBehavior: Clip.antiAlias,
                color: context.theme.brightness == Brightness.dark
                    ? AppColors.redBgDark
                    : AppColors.redBg,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.translate.delete_khatma,
                        style: const TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.red,
                            fontWeight: FontWeight.w500),
                      ),
                      SvgPicture.asset(AppAssets.delete)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logPendingNotificationsRequestList() {
    flutterLocalNotificationsPlugin
        .pendingNotificationRequests()
        .then((pendingNotificationsList) {
      log("pendig notifications requests length =${pendingNotificationsList.length}");
      if (pendingNotificationsList.isNotEmpty) {
        log("pending[0]=${pendingNotificationsList.first.payload}");
      }
    });
  }
}

class CurrentWerdWidget extends StatelessWidget {
  const CurrentWerdWidget({
    Key? key,
    required this.currentWerd,
    required this.awradBox,
    required this.currentKhatmah,
  }) : super(key: key);
  final WerdModel currentWerd;
  final KhatmahModel currentKhatmah;
  final Box<WerdModel> awradBox;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //todo: current werd goes here
        Opacity(
          opacity: currentWerd.isCompleted ? 0.5 : 1,
          child: Text(
            '${context.translate.todays_werd} (${context.translate.the_werd} ${currentWerd.id})',
            style: context.textTheme.bodySmall!
                .copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        //todo: current werd from and to goes here
        for (int i = 0; i < 2; i++)
          Opacity(
            opacity: currentWerd.isCompleted ? 0.5 : 1,
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    i == 0
                        ? context.translate.from
                        : context.translate.localeName == AppStrings.englishCode
                            ? '${context.translate.to}  '
                            : context.translate.to,
                    style: context.textTheme.bodySmall!
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w400),
                  ),
                ),
                Expanded(
                  child: Card(
                    elevation: 0,
                    margin: const EdgeInsets.all(10),
                    clipBehavior: Clip.antiAlias,
                    color: context.theme.cardColor,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            i == 0
                                ? '${context.translate.localeName == AppStrings.arabicCode ? currentWerd.fromSurahArabic : currentWerd.fromSurahEnglish} - ${context.translate.the_ayah} ${currentWerd.fromAyah}'
                                    .replaceAll(RegExp(r"سورة"), '')
                                : '${context.translate.localeName == AppStrings.arabicCode ? currentWerd.toSurahArabic : currentWerd.toSurahEnglish} - ${context.translate.the_ayah} ${currentWerd.toAyah}'
                                    .replaceAll(RegExp(r"سورة"), ''),
                            style: context.textTheme.bodyMedium!.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            i == 0
                                ? '${context.translate.the_page} ${currentWerd.fromPage}'
                                : '${context.translate.the_page} ${currentWerd.toPage}',
                            style: context.textTheme.bodyMedium!.copyWith(
                                fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(
          height: 12,
        ),
        //todo: when the khatmah is completed this restart button appears
        if (currentWerd.isCompleted)
          AppButton(
              text: context.translate.restart_khatmah,
              textColor: context.theme.brightness == Brightness.dark
                  ? AppColors.activeButtonColor
                  : AppColors.white,
              height: 55,
              width: context.width,
              color: context.theme.brightness == Brightness.dark
                  ? AppColors.white
                  : AppColors.activeButtonColor,
              side: const BorderSide(
                  color: AppColors.activeButtonDark, width: 1.5),
              borderRadius: 10,
              onPressed: () => _onRestartKhatmahClicked(context)),
        //todo: read or sign as completed current werd buttons go here
        if (!currentWerd.isCompleted)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                    text: context.translate.werd_completed,
                    height: 55,
                    color: AppColors.white,
                    textColor: AppColors.activeButtonColor,
                    hasSide: true,
                    side: const BorderSide(
                        color: AppColors.activeButtonColor, width: 1.5),
                    borderRadius: 10,
                    width: MediaQuery.of(context).size.width / 2.3,
                    onPressed: () => _onCompleteWerdClicked(context)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                    text: context.translate.read_the_werd,
                    textColor: AppColors.white,
                    height: 55,
                    color: context.isDarkMode
                        ? context.theme.scaffoldBackgroundColor
                        : AppColors.activeButtonColor,
                    side: BorderSide(
                        color: context.isDarkMode
                            ? AppColors.white
                            : AppColors.activeButtonDark,
                        width: 1.5),
                    borderRadius: 10,
                    onPressed: () => _onReadTheWerdClicked(context)),
              ),
              const SizedBox(width: 16),
            ],
          ),
      ],
    );
  }

  _onRestartKhatmahClicked(BuildContext context) {
    List<WerdModel> awradList = awradBox.values.toList();
    for (int index = 0; index < awradList.length; index++) {
      awradBox.putAt(index, awradList[index]..isCompleted = false);
    }
    context.read<KhatmatCubit>().restartKhatmah(currentKhatmah);
  }

  _onCompleteWerdClicked(BuildContext context) {
    awradBox.putAt(currentWerd.id - 1, currentWerd..isCompleted = true);
    context.read<KhatmatCubit>().addAcompletedWerd(currentKhatmah);
  }

  _onReadTheWerdClicked(BuildContext context) {
    context.read<EssentialMoshafCubit>().navigateToPage(currentWerd.fromPage);
    Navigator.pop(context);
    context.read<EssentialMoshafCubit>().toggleRootView();
  }
}
