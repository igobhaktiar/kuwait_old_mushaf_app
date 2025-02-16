import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_app/core/enums/moshaf_type_enum.dart';

import 'package:quran_app/features/listening/presentation/screens/listen_view.dart'
    show ListenView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart'
    show BookmarksView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/margins_view.dart'
    show MarginsView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/osoul_view.dart'
    show OsoulView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/qeraat_view.dart'
    show QeraaatView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart'
    show ShwahidView;
import 'package:quran_app/features/main/presentation/screens/bottom_sheet_views/tafseer_view.dart'
    show TafseerListView;

part 'bottom_sheet_state.dart';

class BottomSheetCubit extends Cubit<BottomSheetState> {
  BottomSheetCubit() : super(const BottomSheetOrdinaryState(0));
  static BottomSheetCubit get(context) => BlocProvider.of(context);

  //*VALIABLES
  Widget currentBottomSheetView = const TafseerListView();

  //* LISTS
  //* These lists are for the bottom sheet which contains [التفسير،الاستماع،العلاملات المرجعية] in ordinary qeaah mode, and [الأصول،،الهوامش،القراءات،الشواهد] in ten qerraaat mode
  // List<Widget> currentBottomSheetViews = [SizedBox()];

  List<Widget> ordinaryQeraatBottomSheetViews = [
    const TafseerListView(),
    const ListenView(),
    const BookmarksView(),
  ];
  List<Widget> tenQeraatBottomSheetViews = [
    const QeraaatView(),
    const OsoulView(),
    const ShwahidView(),
    const MarginsView(),
  ];

  //*METHODS

  changeViewsType(MoshafTypes moshafType) {
    if (moshafType == MoshafTypes.ORDINARY) {
      currentBottomSheetView = ordinaryQeraatBottomSheetViews[1];
      emit(const BottomSheetOrdinaryState(1));
    } else {
      currentBottomSheetView = tenQeraatBottomSheetViews[0];
      emit(const BottomSheetTenQeraatState(0));
    }
  }

  changeViewIndex(int newIndex) {
    if (state is BottomSheetOrdinaryState) {
      currentBottomSheetView = ordinaryQeraatBottomSheetViews[newIndex];
      emit(BottomSheetOrdinaryState(newIndex));
    } else {
      currentBottomSheetView = tenQeraatBottomSheetViews[newIndex];
      emit(BottomSheetTenQeraatState(newIndex));
    }
    log("currentBottomSheetView: ${currentBottomSheetView.toString()}");
  }
}
