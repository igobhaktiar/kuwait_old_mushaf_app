// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:hive_demo/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart';

// class QuranHighlightScreen extends StatelessWidget {
//   const QuranHighlightScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double scaleFactor = MediaQuery.of(context).size.width / 290;
//     log("scaleFactor=$scaleFactor");
//     return BlocBuilder<AyatHighlightCubit, AyatHighlightState>(
//       builder: (context, state) {
//         if (state is PageHighlightsState) {
//           return Padding(
//             padding: EdgeInsets.only(top: context.topPadding),
//             child: Stack(
//               children: [
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                       color: Colors.white,
//                       width: context.width,
//                       height: context.height,
//                       child: Image.asset(
//                         "assets/imgs/P_003.png",
//                         errorBuilder: (context, object, stackTrace) {
//                           return Center(
//                             child: Text(
//                               'asset error',
//                               style: const TextStyle(
//                                   color: Colors.black, fontSize: 33),
//                             ),
//                           );
//                         },
//                         fit: BoxFit.fill,
//                       )),
//                 ),
//                 //todo: highlights are here🤲🤲
//                 ..._buildHighlights(state.lineHighlights,
//                     scaleFactor: scaleFactor)
//               ],
//             ),
//           );
//         } else {
//           return SizedBox();
//         }
//       },
//     );
//   }

//   List<Widget> _buildHighlights(List<AyahSegsModel> lineHighlights,
//       {double scaleFactor = 1.0}) {
//     List<Widget> outputList = [];
//     for (var highlight in lineHighlights) {
//       for (var seg in highlight.segs!) {
//         outputList.add(Positioned(
//             top: seg.y!.toDouble() * scaleFactor + 40, //todo top
//             left: seg.x!.toDouble() * scaleFactor, //todo left
//             child: SizedBox(
//               width:
//                   seg.w!.toDouble() * scaleFactor, // *scaleFactor  //todo width
//               height: seg.h!.toDouble(), // *scaleFactor //todo height
//               child: Container(
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.4),
//                     border: Border.all(width: 2)),
//                 child: Text(
//                   "${highlight.ayaId}-${highlight.suraId}",
//                   style: const TextStyle(
//                       color: Colors.black,
//                       fontSize: 13,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             )));
//       }
//     }
//     log("outputList.length= ${outputList.length}");
//     return outputList;
//   }

//   Padding _buildBookmarkButton(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(top: context.topPadding),
//       child: Material(
//         color: Colors.transparent,
//         child: IconButton(
//             onPressed: () => _addBookmark(context),
//             icon: Icon(
//               Icons.bookmark_add,
//               size: 28,
//             )),
//       ),
//     );
//   }

//   _addBookmark(BuildContext context) {}
// }
