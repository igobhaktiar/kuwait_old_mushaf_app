import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran_app/config/themes/theme_context.dart';
import 'package:quran_app/core/utils/app_colors.dart';
import 'package:quran_app/features/listening/presentation/cubit/listening_cubit.dart';
import 'package:quran_app/features/listening/presentation/screens/section_repeat_enum%7B.dart';

import '../../../../core/utils/assets_manager.dart';

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.
        BlocBuilder<ListeningCubit, ListeningState>(
      builder: (context, state) {
        final cubit = context.read<ListeningCubit>();
        return StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering ||
                cubit.isDownloading) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 30.0,
                height: 30.0,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                ),
              );
            } else if (playing != true ||
                processingState == ProcessingState.idle) {
              return IconButton(
                icon: SvgPicture.asset(
                  AppAssets.play,
                  height: 30,
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : null,
                ),
                onPressed: () async {
                  if (processingState == ProcessingState.idle) {
                    context.read<ListeningCubit>().listenToCurrentPage(
                        repeatType: SectionRepeatType.continuous);
                    // context.read<ListeningCubit>().showChooseRepeat();
                  } else {
                    player.play();
                  }
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: SvgPicture.asset(
                      AppAssets.pause,
                      height: 30,
                      width: 30,
                      fit: BoxFit.cover,
                      color: context.theme.brightness == Brightness.dark
                          ? Colors.white
                          : null,
                    ),
                    onPressed: () async => await player.pause(),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    child: Icon(
                      Icons.stop,
                      size: 35,
                      color: context.theme.brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.activeButtonColor,
                    ),
                    onTap: () async {
                      context.read<ListeningCubit>().forceStopPlayer();
                    },
                  ),
                ],
              );
            } else {
              return IconButton(
                icon: Icon(
                  Icons.replay,
                  color: context.theme.brightness == Brightness.dark
                      ? Colors.white
                      : AppColors.activeButtonColor,
                ),
                iconSize: 40.0,
                onPressed: () => player.setAudioSource(player.audioSource!),
              );
            }
          },
        );
      },
    );
  }
}
