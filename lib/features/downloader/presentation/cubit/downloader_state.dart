part of 'downloader_cubit.dart';

abstract class DownloaderState extends Equatable {
  const DownloaderState();

  @override
  List<Object> get props => [];
}

class DownloaderInitial extends DownloaderState {}

class DownloadStarted extends DownloaderState {}

class DownloadStoped extends DownloaderState {}

class DownloadingState extends DownloaderState {
  final String value;
  const DownloadingState({required this.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DownloadingState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}
