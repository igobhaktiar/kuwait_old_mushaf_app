part of 'bottom_sheet_cubit.dart';

abstract class BottomSheetState extends Equatable {
  final int currentViewIndex;
  const BottomSheetState(this.currentViewIndex);

  @override
  List<Object> get props => [currentViewIndex];
}

class BottomSheetOrdinaryState extends BottomSheetState {
  const BottomSheetOrdinaryState(int currentViewIndex)
      : super(currentViewIndex);
}

class BottomSheetTenQeraatState extends BottomSheetState {
  const BottomSheetTenQeraatState(int currentViewIndex)
      : super(currentViewIndex);
}
