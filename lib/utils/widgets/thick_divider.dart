import 'package:flutter/material.dart';

import '../../config/theme/theme.dart';

class ThickDivider extends StatelessWidget {
  const ThickDivider({super.key});

  @override
  Widget build(BuildContext context) {

      return Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.white, boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.4),
                blurRadius: 2,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ]),),
          Container(
            height: 20,
            decoration: BoxDecoration(color: AppColors.gray.withOpacity(0.9)),
          ),
        ],
      );

  }
}



// class ThickDivider extends StatelessWidget {
//   const ThickDivider({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 20,
//       decoration: BoxDecoration(
//         color: AppColors.gray.withValues(alpha:0.9),
//         boxShadow: [
//           // soft shadow below
//           BoxShadow(
//             color: Colors.black.withValues(alpha:0.15),
//             offset: const Offset(0, 2),
//             blurRadius: 4,
//             spreadRadius: 1,
//           ),
//           // subtle highlight above
//           BoxShadow(
//             color: Colors.white.withValues(alpha:0.2),
//             offset: const Offset(0, -1),
//             blurRadius: 2,
//           ),
//         ],
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           stops: [0.0, 0.1, 0.2, 0.3, 0.4],
//           colors: [
//             AppColors.secondaryText.withValues(alpha:0.2),  // faint bottom shadow
//             AppColors.gray.withValues(alpha: 0.9),  // faint bottom shadow
//             AppColors.gray.withValues(alpha: 0.9),  // faint bottom shadow
//             AppColors.gray.withValues(alpha: 0.9),  // faint bottom shadow
//             AppColors.gray.withValues(alpha: 0.9),  // faint bottom shadow
//             // AppColors.gray.withValues(alpha: 0.2),  // faint bottom shadow
//             // AppColors.gray.withValues(alpha: 0.2),  // faint bottom shadow
//
//             // Colors.grey.withValues(alpha:0.2),  // faint bottom shadow
//             // Colors.grey.withValues(alpha:0.2),  // faint bottom shadow
//             // Colors.white.withValues(alpha:0.2),  // subtle top highlight
//
//
//           ],
//         ),
//       ),
//     );
//   }
// }