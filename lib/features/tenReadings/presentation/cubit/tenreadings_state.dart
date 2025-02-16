// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'tenreadings_cubit.dart';

abstract class TenReadingsState extends Equatable {
  const TenReadingsState();

  @override
  List<Object> get props => [];
}

class TenreadingsInitial extends TenReadingsState {}

class TenreadingsStartedDownloadingAssets extends TenReadingsState {}

class TenreadingLoading extends TenReadingsState {}

class TenreadingError extends TenReadingsState {}

class TenreadingsFilesMustBeDownloadedFirstPromptState
    extends TenReadingsState {}

class TenReadingsChangeCurrentPage extends TenReadingsState {
  int newPage;
  TenReadingsChangeCurrentPage(this.newPage);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is TenReadingsChangeCurrentPage && other.newPage == newPage;
  }

  @override
  int get hashCode => newPage.hashCode;
}

class TenreadingsDownloading extends TenReadingsState {
  String progress;
  TenreadingsDownloading(this.progress);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is TenreadingsDownloading && other.progress == progress;
  }

  @override
  int get hashCode => progress.hashCode;
}

class TenreadingsDownloadComplete extends TenReadingsState {}

class TenreadingsAllFilesDownloadedState extends TenReadingsState {}

class TenreadingsDownloadError extends TenReadingsState {}

class TenreadingsServicesLoaded extends TenReadingsState {
  List<KhelafiaWordModel>? khelfiaWords;
  List<KhelafiaWordModel>? clickedWord;
  List<OsoulModel>? osoul;
  List<ShwahidDalalatGroupModel>? shwahidDalalatGroups;
  List<HwamishModel>? hwamishModel;
  File? coloredImageFile;
  DateTime? now;

  TenreadingsServicesLoaded(
      {this.khelfiaWords,
      this.osoul,
      this.shwahidDalalatGroups,
      this.hwamishModel,
      this.coloredImageFile,
      this.clickedWord,
      this.now});

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    if (other is TenreadingsServicesLoaded) {
      return listEquals(other.khelfiaWords, khelfiaWords) &&
          listEquals(other.clickedWord, clickedWord) &&
          listEquals(other.osoul, osoul) &&
          listEquals(other.shwahidDalalatGroups, shwahidDalalatGroups) &&
          listEquals(other.coloredImageFile, coloredImageFile) &&
          listEquals(other.now, now) &&
          listEquals(other.hwamishModel, hwamishModel);
    } else {
      return false;
    }
  }

  @override
  int get hashCode {
    return khelfiaWords.hashCode ^
        osoul.hashCode ^
        shwahidDalalatGroups.hashCode ^
        hwamishModel.hashCode;
  }
}

class TenreadingsServicesError extends TenReadingsState {}

class ChangeCurrentPlayingQeraaFileState extends TenReadingsState {
  SingleQeraaModel? qeraaBeingPlayed;
  ChangeCurrentPlayingQeraaFileState(this.qeraaBeingPlayed);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentPlayingQeraaFileState &&
        other.qeraaBeingPlayed == qeraaBeingPlayed;
  }

  @override
  int get hashCode => qeraaBeingPlayed.hashCode;
}

class TimerTickState extends TenReadingsState {
  int maxWait;
  TimerTickState(this.maxWait);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is TimerTickState && other.maxWait == maxWait;
  }

  @override
  int get hashCode => maxWait.hashCode;
}

class TenReadingsFilesDeletedSuccessfully extends TenReadingsState {}

class TenReadingsFilesDeleteError extends TenReadingsState {}

class TenReadingCheckingForUpdates extends TenReadingsState {}

class TenReadingCheckingForUpdatesError extends TenReadingsState {}

class CheckYourInternetConnection extends TenReadingsState {
  final bool showAlertDialog;

  CheckYourInternetConnection({this.showAlertDialog = false});
}

class ContentNotAvailableState extends TenReadingsState {}

class UpdateAppToBenefitFromNewFeatursState extends TenReadingsState {}

class SetIsNeedUpdateDialogShownState extends TenReadingsState {}

class ResetIsNeedUpdateDialogShownState extends TenReadingsState {}
