// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'listening_cubit.dart';

abstract class ListeningState extends Equatable {
  const ListeningState();

  @override
  List<Object> get props => [];
}

class ListeningInitial extends ListeningState {}

class ChangeCurrentPageState extends ListeningState {
  int newPage;
  ChangeCurrentPageState(this.newPage);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentPageState && other.newPage == newPage;
  }

  @override
  int get hashCode => newPage.hashCode;
}

class PlayerPlayingState extends ListeningState {
  bool isPlaying = false;
  PlayerPlayingState(this.isPlaying);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PlayerPlayingState && other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => isPlaying.hashCode;
}

class PlayerProcessingState extends ListeningState {
  bool isProcessing = true;
  PlayerProcessingState(this.isProcessing);
}

class ShowShiekhViewState extends ListeningState {}

class AudioDownloading extends ListeningState {
  final String value;
  const AudioDownloading({this.value = '0%'});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AudioDownloading && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class AudioDownloadSuccess extends ListeningState {
  final String msg;

  AudioDownloadSuccess({this.msg = ''});

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is AudioDownloadSuccess && other.msg == msg;
  }

  @override
  int get hashCode => msg.hashCode;
}

class AudioDownloadError extends ListeningState {}

class ChangeCurrentReciterState extends ListeningState {
  final ReciterModel currentReciter;
  const ChangeCurrentReciterState(this.currentReciter);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentReciterState &&
        other.currentReciter == currentReciter;
  }

  @override
  int get hashCode => currentReciter.hashCode;
}

class ChangeHighlightedAyah extends ListeningState {
  final AyahModel currentlyPlayedAyah;
  const ChangeHighlightedAyah(this.currentlyPlayedAyah);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is ChangeHighlightedAyah &&
        other.currentlyPlayedAyah == currentlyPlayedAyah;
  }

  @override
  int get hashCode => currentlyPlayedAyah.hashCode;
}

class PlayerStopped extends ListeningState {}

class ReciterFilesDeletedSuccessfully extends ListeningState {
  final String reciterFolderPath;

  const ReciterFilesDeletedSuccessfully({required this.reciterFolderPath});

  @override
  bool operator ==(covariant other) {
    if (identical(this, other)) return true;

    return other is ReciterFilesDeletedSuccessfully &&
        other.reciterFolderPath == reciterFolderPath;
  }

  @override
  int get hashCode => reciterFolderPath.hashCode;
}

class ReciterFilesDeleteError extends ListeningState {}

class NavigateToCurrentAyahPageState extends ListeningState {
  final int page;

  const NavigateToCurrentAyahPageState({required this.page});
}

class ChangeEnablePlayInBackgroundState extends ListeningState {
  bool enabled;
  ChangeEnablePlayInBackgroundState({this.enabled = true});

  @override
  bool operator ==(covariant other) {
    if (identical(this, other)) return true;

    return other is ChangeEnablePlayInBackgroundState &&
        other.enabled == enabled;
  }

  @override
  int get hashCode => enabled.hashCode;
}

class CheckYourNetworkConnectionState extends ListeningState {}

class ShiekhMp3PageDownloadCounterChanged extends ListeningState {
  final int page;

  ShiekhMp3PageDownloadCounterChanged(this.page);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is ShiekhMp3PageDownloadCounterChanged && other.page == page;
  }

  @override
  int get hashCode => page.hashCode;
}

class WaitUntilDownloadFininsh extends ListeningState {}
