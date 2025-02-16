import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/core/utils/assets_manager.dart';
import 'package:quran_app/core/utils/constants.dart';
import 'package:quran_app/core/utils/mediaquery_values.dart';
import 'package:quran_app/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:quran_app/features/externalLibraries/data/models/external_library_model.dart';
import 'package:quran_app/features/externalLibraries/presentation/cubit/external_libraries_cubit.dart';
import 'package:quran_app/features/externalLibraries/presentation/cubit/external_libraries_state.dart';
import 'package:quran_app/l10n/localization_context.dart';

class ExternalLibrariesScreen extends StatefulWidget {
  const ExternalLibrariesScreen({super.key});

  @override
  State<ExternalLibrariesScreen> createState() =>
      _ExternalLibrariesScreenState();
}

class _ExternalLibrariesScreenState extends State<ExternalLibrariesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(context.translate.external_library_title),
          ],
        ),
        leading: AppConstants.customBackButton(context,
            onPressed: () =>
                EssentialMoshafCubit.get(context).toggleRootView()),
      ),
      body: BlocConsumer<ExternalLibrariesCubit, ExternalLibrariesState>(
        listener: (BuildContext context, state) {
          if (state is ExternalLibraryDownloadingAssets) {
            AppConstants.showToast(context,
                msg: context.translate.downloading_files_in_the_background);
          }

          if (state is ExternalLibraryFinishDownload) {
            AppConstants.showToast(context, msg: context.translate.downloading);
          }

          if (state is ExternalLibraryFinishDownload) {
            AppConstants.showToast(context,
                msg: context.translate.finish_downloading);
          }
        },
        builder: (BuildContext context, ExternalLibrariesState state) {
          return context.read<ExternalLibrariesCubit>().externalLibrary == null
              ? const SizedBox()
              : StreamBuilder<InternetConnectionStatus>(
                  stream: context
                      .read<ExternalLibrariesCubit>()
                      .checkConnection()
                      .asStream(),
                  builder: (context,
                      AsyncSnapshot<InternetConnectionStatus> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final externalLibrary =
                        context.read<ExternalLibrariesCubit>().externalLibrary;

                    if ((externalLibrary is ExternalLibrary &&
                            snapshot.data ==
                                InternetConnectionStatus.disconnected) ||
                        (externalLibrary is List<String> &&
                            snapshot.data ==
                                InternetConnectionStatus.connected)) {
                      context
                          .read<ExternalLibrariesCubit>()
                          .initExternalLibrariesCubit()
                          .then((value) => setState(() {}));
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: snapshot.data ==
                                InternetConnectionStatus.connected
                            ? externalLibrary.results![0].resources!
                                .map<Widget>((libraryResource) {
                                return GestureDetector(
                                  onTap: () async => await context
                                      .read<ExternalLibrariesCubit>()
                                      .openFileExternal(libraryResource.title!),
                                  child: Slidable(
                                    key: Key(libraryResource.title!),
                                    closeOnScroll: true,
                                    endActionPane: ActionPane(
                                      motion: const ScrollMotion(),
                                      children: [
                                        Expanded(
                                          child: Container(
                                            color: context.theme.brightness ==
                                                    Brightness.dark
                                                ? context.theme
                                                    .scaffoldBackgroundColor
                                                : const Color(0xFFFEF2F2),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Builder(
                                                builder: (ctx) {
                                                  return InkWell(
                                                    onTap: () {
                                                      context
                                                          .read<
                                                              ExternalLibrariesCubit>()
                                                          .deletePdf(
                                                              libraryResource
                                                                  .title!);
                                                    },
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          SvgPicture.asset(
                                                              AppAssets.delete,
                                                              color:
                                                                  Colors.red),
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                            context.translate
                                                                .delete,
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                height: 1.4,
                                                                color: AppColors
                                                                    .red,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 12),
                                          ClipOval(
                                            child: Container(
                                              height: 40,
                                              width: 40,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color:
                                                    context.theme.brightness ==
                                                            Brightness.dark
                                                        ? AppColors.dialogBgDark
                                                        : AppColors.lightGrey,
                                              ),
                                              child: SvgPicture.asset(
                                                AppAssets.tenReadingsIcon,
                                                color:
                                                    context.theme.brightness ==
                                                            Brightness.dark
                                                        ? AppColors.white
                                                        : null,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 15),
                                          Expanded(
                                            child: Text(libraryResource.title!,
                                                style: context
                                                    .textTheme.bodyMedium!
                                                    .copyWith(fontSize: 14)),
                                          ),
                                          const SizedBox(width: 10),
                                          StreamBuilder(
                                            stream: context
                                                .read<ExternalLibrariesCubit>()
                                                .pdfFileIsDownloaded(
                                                    libraryResource.title!)
                                                .asStream(),
                                            builder: (BuildContext ctx,
                                                AsyncSnapshot f) {
                                              final isDownloading = context
                                                          .read<
                                                              ExternalLibrariesCubit>()
                                                          .isDownloadingPdfMap[
                                                      libraryResource.title!] ==
                                                  true;
                                              String percentage = context
                                                  .read<
                                                      ExternalLibrariesCubit>()
                                                  .downloadingPdfProgressMap[
                                                      libraryResource.title!]
                                                  .toString();

                                              if (isDownloading) {
                                                return Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          height: 20,
                                                          width: 20,
                                                          child: Center(
                                                            child:
                                                                CircularProgressIndicator(),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
                                                        Container(
                                                          height: 20,
                                                          child: Center(
                                                            child: Text(
                                                              "$percentage %",
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                  fontSize:
                                                                      12.0),
                                                            ),
                                                          ),
                                                        ),

                                                        ///******************* */
                                                      ].reversed.toList(),
                                                    ));
                                              } else {
                                                return StreamBuilder(
                                                    stream: context
                                                        .read<
                                                            ExternalLibrariesCubit>()
                                                        .isFileNeedsUpdatte(
                                                            libraryResource)
                                                        .asStream(),
                                                    builder: (BuildContext ctx2,
                                                        AsyncSnapshot ff) {
                                                      if (ff.data == true) {
                                                        return InkWell(
                                                          onTap: () =>
                                                              _onUpdateResourcePressed(
                                                                  context,
                                                                  libraryResource),
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical:
                                                                        5),
                                                            decoration: BoxDecoration(
                                                                color: context
                                                                    .theme
                                                                    .appBarTheme
                                                                    .backgroundColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5)),
                                                            child: Text(
                                                              context.translate
                                                                  .update,
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        if (f.data != true) {
                                                          return InkWell(
                                                              child: SvgPicture
                                                                  .asset(
                                                                AppAssets
                                                                    .downloadDisabled,
                                                                color: context
                                                                        .isDarkMode
                                                                    ? Colors
                                                                        .white
                                                                    : null,
                                                              ),
                                                              onTap: () async => await ctx
                                                                  .read<
                                                                      ExternalLibrariesCubit>()
                                                                  .downloadExternalLibrary(
                                                                      libraryResource));
                                                        } else {
                                                          return InkWell(
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                SvgPicture.asset(
                                                                    AppAssets
                                                                        .checkBlack),
                                                                StreamBuilder(
                                                                    stream: context
                                                                        .read<
                                                                            ExternalLibrariesCubit>()
                                                                        .getFileSizeInMB(libraryResource
                                                                            .title!)
                                                                        .asStream(),
                                                                    builder: (BuildContext
                                                                            ctx,
                                                                        AsyncSnapshot
                                                                            fff) {
                                                                      final String
                                                                          fileSize =
                                                                          fff.data ??
                                                                              '';

                                                                      if (fileSize !=
                                                                          '') {
                                                                        return Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: 12),
                                                                          child:
                                                                              Text(
                                                                            fileSize,
                                                                            textDirection:
                                                                                TextDirection.ltr,
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.normal, fontSize: 12.0),
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        return const SizedBox();
                                                                      }
                                                                    })
                                                              ]
                                                                  .reversed
                                                                  .toList(),
                                                            ),
                                                            onTap: () async => await ctx
                                                                .read<
                                                                    ExternalLibrariesCubit>()
                                                                .openFileExternal(
                                                                    libraryResource
                                                                        .title!),
                                                          );
                                                        }
                                                      }
                                                    });
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList()
                            : context
                                        .read<ExternalLibrariesCubit>()
                                        .externalLibrary
                                        .length ==
                                    0
                                ? [
                                    Container(
                                      height: context.height - 80,
                                      width: context.width,
                                      child: Center(
                                        child: Text(
                                          context.translate.no_rewayat,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ]
                                : context
                                    .read<ExternalLibrariesCubit>()
                                    .externalLibrary
                                    .map<Widget>(
                                    (libraryElement) {
                                      return GestureDetector(
                                        onTap: () async => await context
                                            .read<ExternalLibrariesCubit>()
                                            .openFileExternal(libraryElement!),
                                        child: Slidable(
                                          closeOnScroll: true,
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  color: context.theme
                                                              .brightness ==
                                                          Brightness.dark
                                                      ? context.theme
                                                          .scaffoldBackgroundColor
                                                      : const Color(0xFFFEF2F2),
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    child: Builder(
                                                      builder: (ctx) {
                                                        return InkWell(
                                                          onTap: () {
                                                            context
                                                                .read<
                                                                    ExternalLibrariesCubit>()
                                                                .deletePdf(
                                                                    libraryElement);
                                                          },
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <Widget>[
                                                                SvgPicture.asset(
                                                                    AppAssets
                                                                        .delete,
                                                                    color: Colors
                                                                        .red),
                                                                const SizedBox(
                                                                    width: 10),
                                                                Text(
                                                                  context
                                                                      .translate
                                                                      .delete,
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      height:
                                                                          1.4,
                                                                      color: AppColors
                                                                          .red,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 12),
                                                ClipOval(
                                                  child: Container(
                                                    height: 40,
                                                    width: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: context.theme
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? AppColors
                                                              .dialogBgDark
                                                          : AppColors.lightGrey,
                                                    ),
                                                    child: SvgPicture.asset(
                                                      AppAssets.tenReadingsIcon,
                                                      color: context.theme
                                                                  .brightness ==
                                                              Brightness.dark
                                                          ? AppColors.white
                                                          : null,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Text(libraryElement,
                                                      style: context
                                                          .textTheme.bodyMedium!
                                                          .copyWith(
                                                              fontSize: 14)),
                                                ),
                                                InkWell(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                          AppAssets.checkBlack),
                                                      StreamBuilder(
                                                          stream: context
                                                              .read<
                                                                  ExternalLibrariesCubit>()
                                                              .getFileSizeInMB(
                                                                  libraryElement)
                                                              .asStream(),
                                                          builder:
                                                              (BuildContext ctx,
                                                                  AsyncSnapshot
                                                                      fff) {
                                                            final String
                                                                fileSize =
                                                                fff.data ?? '';

                                                            if (fileSize !=
                                                                '') {
                                                              return Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            12),
                                                                child: Text(
                                                                  fileSize,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .ltr,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          12.0),
                                                                ),
                                                              );
                                                            } else {
                                                              return const SizedBox();
                                                            }
                                                          })
                                                    ].reversed.toList(),
                                                  ),
                                                  onTap: () async => await context
                                                      .read<
                                                          ExternalLibrariesCubit>()
                                                      .openFileExternal(
                                                          libraryElement),
                                                ),
                                                const SizedBox(width: 14),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).toList(),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }

  _onUpdateResourcePressed(BuildContext context, Resource libraryResource) {
    context
        .read<ExternalLibrariesCubit>()
        .deleteAndDownloadUpdatedFile(libraryResource);
  }
}
