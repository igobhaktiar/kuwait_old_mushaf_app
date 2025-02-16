// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

abstract class ExternalLibrariesState extends Equatable {
  const ExternalLibrariesState();

  @override
  List<Object> get props => [];
}

class ExternalLibrariesInitial extends ExternalLibrariesState {}

class ChangeCurrentPageState extends ExternalLibrariesState {
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

class CheckYourNetworkConnectionState extends ExternalLibrariesState {}

class ExternalLibraryDownloadingAssets extends ExternalLibrariesState {
  String title;
  ExternalLibraryDownloadingAssets(this.title);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExternalLibraryDownloadingAssets && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}

class ExternalLibraryFinishDownload extends ExternalLibrariesState {
  String title;
  ExternalLibraryFinishDownload(this.title);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ExternalLibraryFinishDownload && other.title == title;
  }

  @override
  int get hashCode => title.hashCode;
}

class ExternalLibraryFileExists extends ExternalLibrariesState {}

class ExternalLibraryInitialized extends ExternalLibrariesState {}

class ExternalLibraryItemDeleted extends ExternalLibrariesState {}

class ExternalLibraryDownloadingFile extends ExternalLibrariesState {
  final String percentage;

  ExternalLibraryDownloadingFile(this.percentage);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is ExternalLibraryDownloadingFile &&
        other.percentage == percentage;
  }

  @override
  int get hashCode => percentage.hashCode;
}
