// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'essential_moshaf_cubit.dart';

abstract class EssentialMoshafState extends Equatable {
  const EssentialMoshafState();

  @override
  List<Object> get props => [];
}

class EssentialMoshafInitial extends EssentialMoshafState {}

class ChangeMoshafType extends EssentialMoshafState {
  final MoshafTypes moshafType;
  const ChangeMoshafType(this.moshafType);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeMoshafType && other.moshafType == moshafType;
  }

  @override
  int get hashCode => moshafType.hashCode;
}

class FlyingWidgetsVisibleState extends EssentialMoshafState {
  bool value;
  FlyingWidgetsVisibleState(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FlyingWidgetsVisibleState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class BottomSheetVisibleState extends EssentialMoshafState {
  bool value;
  BottomSheetVisibleState(this.value);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BottomSheetVisibleState && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class FlyingWidgetsHiddenState extends EssentialMoshafState {}

class ChangeBottomNavState extends EssentialMoshafState {}

class ChangeBottomSheetContentViewState extends EssentialMoshafState {}

class ChangecheckButtonState extends EssentialMoshafState {}

class ChangeCollapseIconState extends EssentialMoshafState {}

class ChangeCurrentSurah extends EssentialMoshafState {
  final int currentSurah;
  const ChangeCurrentSurah({required this.currentSurah});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentSurah && other.currentSurah == currentSurah;
  }

  @override
  int get hashCode => currentSurah.hashCode;
}

class ChangeCurrentPage extends EssentialMoshafState {
  final int currentPage;
  final int newQuarter;
  final bool hasSajda;
  const ChangeCurrentPage(
      {required this.currentPage, this.newQuarter = -1, this.hasSajda = false});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChangeCurrentPage && other.currentPage == currentPage;
  }

  @override
  int get hashCode => currentPage.hashCode;
}

class ShowNavigationListViewsState extends EssentialMoshafState {
  final bool isVisible;
  const ShowNavigationListViewsState(this.isVisible);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShowNavigationListViewsState &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode => isVisible.hashCode;
}

class HidePagesPopUpState extends EssentialMoshafState {}

class ToggleRootView extends EssentialMoshafState {
  final bool isShownValue;
  const ToggleRootView(this.isShownValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ToggleRootView && other.isShownValue == isShownValue;
  }

  @override
  int get hashCode => isShownValue.hashCode;
}

class SelectedKhatmahPayloadFromNotification extends EssentialMoshafState {
  final String payload;
  const SelectedKhatmahPayloadFromNotification({required this.payload});
}

class OrientationChanged extends EssentialMoshafState {
  final Orientation orientation;

  const OrientationChanged(this.orientation);

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is OrientationChanged && other.orientation == orientation;
  }

  @override
  int get hashCode => orientation.hashCode;
}

class StartListeningToTheNewPage extends EssentialMoshafState {}

class ChangeFihrisIndex extends EssentialMoshafState {
  final int viewIndex;
  const ChangeFihrisIndex({
    this.viewIndex = 0,
  });

  @override
  bool operator ==(covariant Object other) {
    if (identical(this, other)) return true;

    return other is ChangeFihrisIndex && other.viewIndex == viewIndex;
  }

  @override
  int get hashCode => viewIndex.hashCode;
}
