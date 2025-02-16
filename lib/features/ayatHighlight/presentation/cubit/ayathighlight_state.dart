// ignore_for_file: public_member_api_docs, sort_constructors_first

part of 'ayathighlight_cubit.dart';

abstract class AyatHighlightState extends Equatable {
  final List<AyahSegsModel> highlights;
  final AyahModel? currentlyHighlight;

  const AyatHighlightState(this.highlights, this.currentlyHighlight);

  @override
  List get props => [highlights, currentlyHighlight];
}

class PageHighlightsChanged extends AyatHighlightState {
  @override
  List<AyahSegsModel> highlights;
  @override
  AyahModel? currentlyHighlight;
  PageHighlightsChanged(this.highlights, {this.currentlyHighlight})
      : super(highlights, currentlyHighlight);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is PageHighlightsChanged &&
        listEquals(other.highlights, highlights) &&
        other.currentlyHighlight == currentlyHighlight;
  }

  @override
  int get hashCode => highlights.hashCode ^ currentlyHighlight.hashCode;
}

class HighlightTarget extends AyatHighlightState {
  @override
  List<AyahSegsModel> highlights;
  @override
  AyahModel? currentlyHighlight;
  HighlightTarget(this.highlights, {this.currentlyHighlight})
      : super(highlights, currentlyHighlight);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is HighlightTarget &&
        listEquals(other.highlights, highlights) &&
        other.currentlyHighlight == currentlyHighlight;
  }

  @override
  int get hashCode => highlights.hashCode ^ currentlyHighlight.hashCode;
}
