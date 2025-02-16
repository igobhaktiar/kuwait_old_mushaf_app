import 'dart:io';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/listening/data/models/reciter_model.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'package:quran_app/l10n/localization_context.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/utils/constants.dart';

class StorageScreen extends StatelessWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.translate.storage),
        leading: AppConstants.customBackButton(context),
      ),
      body: const StorageListBody(),
    );
  }
}

class StorageListBody extends StatefulWidget {
  const StorageListBody({
    Key? key,
  }) : super(key: key);

  @override
  State<StorageListBody> createState() => _StorageListBodyState();
}

class _StorageListBodyState extends State<StorageListBody>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Directory? tenReadingsFolder;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    context
        .read<TenReadingsCubit>()
        .getTenReadingsFolder
        .then((value) => setState(() => tenReadingsFolder = value));
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    _controller.addListener(() {});
    FirebaseAnalytics.instance
        .logScreenView(screenName: AppStrings.analytcsScreenStorageScreen);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _controller,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        width: context.width,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  context.translate.audio_files,
                  style: context.textTheme.displayMedium,
                )),
            BlocConsumer<ListeningCubit, ListeningState>(
              listener: (context, state) {
                if (state is ReciterFilesDeletedSuccessfully) {
                  AppConstants.showToast(
                    context,
                    msg: context
                        .translate.reciter_files_have_been_deleted_successfully,
                  );
                } else if (state is ReciterFilesDeleteError) {
                  AppConstants.showToast(
                    context,
                    msg: context.translate.error_while_deleting,
                  );
                } else if (state is WaitUntilDownloadFininsh) {
                  AppConstants.showToast(context,
                      msg: context
                          .translate.please_wait_while_other_downloads_finish);
                } else if (state is CheckYourNetworkConnectionState) {
                  AppConstants.showToast(context,
                      msg: context.translate.check_your_internet_connection);
                }
              },
              builder: (context, state) {
                final cubit = ListeningCubit.get(context);
                return SlidableAutoCloseBehavior(
                  closeWhenTapped: true,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    for (final reciter in cubit.recitersList)
                      ReciterStorageTile(
                        reciterModel: reciter,
                        controller: _controller,
                        index: cubit.recitersList.indexOf(
                          reciter,
                        ),
                      )
                  ]),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  context.translate.ten_readings,
                  style: context.textTheme.displayMedium,
                )),
            BlocConsumer<TenReadingsCubit, TenReadingsState>(
              listener: (context, state) {
                if (state is TenReadingsFilesDeletedSuccessfully) {
                  AppConstants.showToast(context,
                      msg: context.translate.files_deleted_successfully);
                } else if (state is TenReadingsFilesDeleteError) {
                  AppConstants.showToast(
                    context,
                    msg: context.translate.error_while_deleting,
                  );
                } else if (state is TenreadingsStartedDownloadingAssets) {
                  AppConstants.showToast(context,
                      msg: context
                          .translate.downloading_files_in_the_background);
                }
              },
              builder: (context, state) {
                return Builder(builder: (context) {
                  bool isTenFolderExists = tenReadingsFolder == null
                      ? false
                      : tenReadingsFolder!.existsSync();
                  int size = 0;

                  if (isTenFolderExists) {
                    tenReadingsFolder!.listSync().forEach((systemFile) {
                      if (systemFile is Directory) {
                        systemFile.listSync().forEach((innerFile) {
                          if (innerFile is File) {
                            size += innerFile.lengthSync();
                          }
                        });
                      }
                      if (systemFile is File) {
                        size += systemFile.lengthSync();
                      }
                    });
                  }
                  return Slidable(
                    closeOnScroll: true,
                    key: const Key("10-R"),
                    endActionPane: ActionPane(
                      motion: const ScrollMotion(),
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: isTenFolderExists ? 1.0 : 0.5,
                            child: Container(
                              color: context.theme.brightness == Brightness.dark
                                  ? context.theme.scaffoldBackgroundColor
                                  : const Color(0xFFFEF2F2),
                              child: Container(
                                alignment: Alignment.center,
                                child: Builder(builder: (ctx) {
                                  return Center(
                                    child: InkWell(
                                      onTap: !isTenFolderExists
                                          ? null
                                          : () =>
                                              _onTenReadingsFilesDeletePressed(
                                                  context, isTenFolderExists),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SvgPicture.asset(
                                            AppAssets.delete,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            context.translate.delete,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                height: 1.4,
                                                color: AppColors.red,
                                                fontWeight: FontWeight.w500),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                                // alignment: Alignment.,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    child: InkWell(
                      child: Container(
                        // color: Colors.red,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // ignore: prefer_const_literals_to_create_immutables
                          children: [
                            const SizedBox(
                              width: 12,
                            ),
                            ClipOval(
                                child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    context.theme.brightness == Brightness.dark
                                        ? AppColors.dialogBgDark
                                        : AppColors.lightGrey,
                              ),
                              child: SvgPicture.asset(
                                AppAssets.tenReadingsIcon,
                                color:
                                    context.theme.brightness == Brightness.dark
                                        ? AppColors.white
                                        : null,

                                // fit: BoxFit.fitHeight,
                              ),
                            )),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              context.translate.ten_readings_files,
                              style: context.textTheme.bodyMedium!
                                  .copyWith(fontSize: 14),
                            ),
                            const Spacer(),
                            if (size > 0)
                              Text(
                                '${(size / 1000000).toStringAsFixed(2)} MB ',
                                textDirection: TextDirection.ltr,
                                style: context.textTheme.bodyMedium!.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            const SizedBox(width: 14),
                            if (context
                                .read<TenReadingsCubit>()
                                .isDownloadingAssets)
                              const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            )
          ],
        ),
      ),
    );
  }

  _onTenReadingsFilesDeletePressed(
      BuildContext context, bool isTenFolderExists) {
    if (isTenFolderExists) {
      AppConstants.showConfirmationDialog(
        context,
        confirmMsg: context.translate.do_you_want_to_delete_this_item(
            context.translate.ten_readings_files),
        okCallback: () {
          context.read<TenReadingsCubit>().deleteAllTenFilesFiles();
          context
              .read<EssentialMoshafCubit>()
              .changeMoshafType(MoshafTypes.ORDINARY);
          _controller.animateTo(Random().nextDouble(),
              duration: const Duration(microseconds: 1), curve: Curves.ease);

          Navigator.pop(context);
        },
        cancelCallback: () => Navigator.pop(context),
      );
    }
  }

  _onDownloadAllTenPagesTapped(BuildContext context) {
    AppConstants.showConfirmationDialog(
      context,
      confirmMsg: context
          .translate.do_you_want_to_download_all_Quran_Ten_readings_files,
      okCallback: () {
        context.read<TenReadingsCubit>().downloadFullQuranTenReadingsFiles();
        Navigator.pop(context);
      },
      cancelCallback: () => Navigator.pop(context),
    );
  }

  _onCheckForUpdatesClicked(BuildContext context) {
    context.read<TenReadingsCubit>().checkForContentUpdates();
  }
}

class DownloadPercentageIndicator extends StatelessWidget {
  const DownloadPercentageIndicator({
    Key? key,
    required this.value,
  }) : super(key: key);
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        value: value,
        strokeWidth: 5,
        color: context.theme.brightness == Brightness.dark
            ? AppColors.backgroundColor
            : AppColors.activeButtonColor,
        backgroundColor: context.theme.brightness != Brightness.dark
            ? AppColors.backgroundColor
            : AppColors.activeButtonColor,
      ),
    );
  }
}

class ReciterStorageTile extends StatelessWidget {
  final int index;
  final ReciterModel reciterModel;
  final ScrollController controller;

  const ReciterStorageTile(
      {Key? key,
      required this.index,
      required this.reciterModel,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListeningCubit, ListeningState>(
        builder: (context, state) {
      return InkWell(
        onTap: () => _onReciterTapped(context, reciterModel),
        child: Builder(builder: (BuildContext context) {
          String reciterFolderPath =
              context.read<ListeningCubit>().getReciterFolderPath(reciterModel);
          bool isReciterFolderExists =
              Directory(reciterFolderPath).existsSync();
          int size = 0;
          int mp3FilesNumber = 0;
          int swarFolderNumber = 0;
          double downloadPercentage = 0.0;
          if (isReciterFolderExists) {
            Directory(reciterFolderPath).listSync().forEach((file) {
              if (file is Directory) {
                swarFolderNumber++;
                var filesInSurahFolder = file.listSync();
                for (var ayahFile in filesInSurahFolder) {
                  if (ayahFile is File) {
                    size += ayahFile.lengthSync();
                    mp3FilesNumber++;
                  }
                }
              }
            });
          }
          downloadPercentage = min(1.0, mp3FilesNumber / 6236);
          return Slidable(
            closeOnScroll: true,
            key: Key(reciterFolderPath),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                Expanded(
                  child: Opacity(
                    opacity: isReciterFolderExists && size > 0 ? 1.0 : .5,
                    child: Container(
                      color: context.theme.brightness == Brightness.dark
                          ? context.theme.scaffoldBackgroundColor
                          : const Color(0xFFFEF2F2),
                      child: Container(
                        alignment: Alignment.center,
                        child: Builder(builder: (ctx) {
                          return Center(
                            child: InkWell(
                              onTap: !isReciterFolderExists || size == 0
                                  ? null
                                  : () => _onDeletePressed(context,
                                      reciterFolderPath, isReciterFolderExists),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    AppAssets.delete,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    context.translate.delete,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.4,
                                        color: AppColors.red,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        // alignment: Alignment.,
                      ),
                    ),
                  ),
                )
              ],
            ),
            child: InkWell(
              onTap: () async {
                if (mp3FilesNumber >= 6236) {
                  return;
                }
                SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                int page = sharedPreferences
                        .getInt((reciterModel?.id ?? "0").toString()) ??
                    0;
                if (page == 0) {
                  AppConstants.showConfirmationDialog(
                    context,
                    confirmMsg: context.translate
                        .do_you_want_download_full_quran_sound_for_this_reciter,
                    okCallback: () {
                      context
                          .read<ListeningCubit>()
                          .downloadReciterMp3sPageByPage(
                            reciterModel,
                            reciterFolderPath,
                          );

                      Navigator.pop(context);
                    },
                    cancelCallback: () => Navigator.pop(context),
                  );
                } else {
                  AppConstants.showConfirmationDialog(
                    context,
                    confirmMsg: context.translate
                        .do_you_want_continue_download_full_quran_sound_for_this_reciter,
                    okCallback: () {
                      context
                          .read<ListeningCubit>()
                          .downloadReciterMp3sPageByPage(
                            reciterModel,
                            reciterFolderPath,
                          );

                      Navigator.pop(context);
                    },
                    cancelCallback: () => Navigator.pop(context),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    ClipOval(
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: Image.asset(reciterModel.photo.toString()),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      reciterModel.nameArabic.toString(),
                      style:
                          context.textTheme.bodyMedium!.copyWith(fontSize: 14),
                    ),
                    const Spacer(),
                    if (size > 0)
                      Text(
                        '${(size / 1000000).toStringAsFixed(2)} MB ',
                        textDirection: TextDirection.ltr,
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(width: 14),
                    BlocBuilder<ListeningCubit, ListeningState>(
                      builder: (context, state) {
                        final cubit = context.read<ListeningCubit>();
                        if (cubit.downloadingZipFilesListForSheikh
                            .contains(reciterModel.id)) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator()),
                              const SizedBox(width: 12.0),
                              Container(
                                alignment: Alignment.center,
                                height: 20,
                                child: Text(
                                  '(${cubit.downloadingZipFilesListForSheikh.isEmpty || cubit.zipFilesDownloadProgress.isEmpty ? "" : cubit.zipFilesDownloadProgress[cubit.downloadingZipFilesListForSheikh.indexOf(reciterModel.id!)]} / 604)',
                                  textDirection: TextDirection.ltr,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 12.0),
                                ),
                              ),
                            ].reversed.toList(),
                          );
                        } else if (size == 0) {
                          return SvgPicture.asset(
                            AppAssets.downloadDisabled,
                            color: context.isDarkMode ? Colors.white : null,
                          );
                        } else {
                          return swarFolderNumber != 114
                              ? DownloadPercentageIndicator(
                                  value: downloadPercentage)
                              : SvgPicture.asset(AppAssets.checkBlack);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  _onDeletePressed(BuildContext context, String reciterFolderPath,
      bool isReciterFolderExists) {
    if (isReciterFolderExists) {
      AppConstants.showConfirmationDialog(
        context,
        confirmMsg: context.translate.do_you_want_to_delete_this_item(
            context.translate.this_reciter_files),
        okCallback: () {
          context.read<ListeningCubit>().deleteAllFilesForReciter(
              reciterModel: reciterModel, reciterFolderPath: reciterFolderPath);
          controller.animateTo(Random().nextDouble(),
              duration: const Duration(microseconds: 1), curve: Curves.ease);

          Navigator.pop(context);
        },
        cancelCallback: () => Navigator.pop(context),
      );
    }
  }

  _onReciterTapped(BuildContext context, ReciterModel reciterModel) {
    // AppConstants.showConfirmationDialog(
    //   context,
    //   confirmMsg: context.translate
    //       .do_you_wannt_to_download_the_full_quran_for_reciter(
    //           context.translate.localeName == AppStrings.arabicCode
    //               ? reciterModel.nameArabic!
    //               : reciterModel.nameEnglish!),
    //   okCallback: () {
    //     context
    //         .read<ListeningCubit>()
    //         .downloadFullQuranForReciter(reciterModel);
    //   },
    //   cancelCallback: () => Navigator.pop(context),
    // );
  }
}
