// import 'package:badges/badges.dart' as badges;
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:woodenstreet/features/search/presentation/widgets/search_bar_with_overlay.dart';
// import 'package:woodenstreet/utils/widgets/keep_alive_wrapper.dart';
// import '../../config/routes/route_names.dart';
// import '../../config/theme/theme.dart';
// import '../../features/base/presentation/bloc/base_bloc.dart';
// import '../../features/base/presentation/pages/base_page.dart';
// import '../../features/search/presentation/bloc/search_bloc.dart';
// import '../../services/session_manager.dart';
// import '../helpers/helpers.dart';
//
// class LogoAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool showBackButton;
//   final bool drawer;
//   final bool searchIcon;
//   final bool showSearchBar;
//   final FocusNode? searchFocusNode;
//   final TextEditingController? textEditingController;
//   final bool showWishlist;
//   final bool showCart;
//   final Color searchBarBg;
//
//   const LogoAppBar({
//     super.key,
//     this.drawer = false,
//     this.showSearchBar = false,
//     this.searchIcon = true,
//     this.searchFocusNode,
//     this.showBackButton = false,
//     this.textEditingController,
//     this.showWishlist = true,
//     this.showCart = true,
//     this.searchBarBg = AppColors.white
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Count visible actions
//     int visibleActions = 0;
//     if (searchIcon) visibleActions++;
//     if (showWishlist) visibleActions++;
//     if (showCart) visibleActions++;
//
//     // Adjust horizontal padding dynamically
//     double horizontalPadding = 10.0;
//     if (visibleActions == 1) {
//       horizontalPadding = 20.0;
//     } else if (visibleActions == 2){
//       horizontalPadding = 15.0;
//     }
//
//     return Material(
//       elevation: showSearchBar ? 2.0 : 0.0,
//       child: AppBar(
//         key: const ValueKey('logoAppBar'),
//         leading: drawer
//             ? IconButton(
//           splashColor: Colors.transparent,
//           icon: SvgPicture.asset(
//             'assets/images/svgicons/menuicon.svg',
//             height: 24,
//           ),
//           onPressed: () {
//             openHomeDrawer(context);
//           },
//         )
//             : (showBackButton
//             ? BackButton(
//           onPressed: () {
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.read<BaseBloc>().add(TabIndexChanged(tabIndex: 0));
//           },
//         )
//             : null),
//         surfaceTintColor: Colors.transparent,
//         centerTitle: false,
//         backgroundColor: searchBarBg == AppColors.gray ? AppColors.white :  AppColors.gray,
//         titleSpacing: -10.0,
//         title: showSearchBar
//             ? Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: SizedBox(
//             height: 45,
//             child: SearchBarWithOverlay(
//               color: searchBarBg,
//               textEditingController: textEditingController,
//             ),
//           ),
//         )
//             : InkWell(
//           splashColor: Colors.transparent,
//           highlightColor: Colors.transparent,
//           hoverColor: Colors.transparent,
//           focusColor: Colors.transparent,
//           splashFactory: NoSplash.splashFactory,
//           onTap: () {
//             Navigator.of(context).popUntil((route) => route.isFirst);
//             context.read<BaseBloc>().add(TabIndexChanged(tabIndex: 0));
//           },
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 5, left: 5),
//             height: 30,
//             width: 125,
//             child: KeepAlivePage(
//               child: Image.asset('assets/images/pngicons/ic_header_logo.png'),
//             ),
//           ),
//         )
//         ,
//         actionsPadding: EdgeInsets.symmetric(horizontal: horizontalPadding),
//         actions: [
//           Row(
//             spacing: 15.0,
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               if (searchIcon)
//                 BlocBuilder<BaseBloc, BaseState>(
//                   builder: (context, state) {
//                     return InkWell(
//                       child: SvgPicture.asset(
//                         'assets/images/svgicons/header_search.svg',
//                         width: 26.0,
//                         height: 26.0,
//                       ),
//                       onTap: () {
//                         final currentRoute = ModalRoute.of(context)?.settings.name;
//
//                         if (currentRoute == RouteNames.searchCategory) {
//                           // Already on searchCategory, just pop
//                           Navigator.popAndPushNamed(
//                             context,
//                             RouteNames.searchView,
//                             arguments: {
//                               'searchBloc': context.read<SearchBloc>(),
//                               'search': '',
//                             },
//                           );
//                         } else {
//                           // Otherwise, push the searchView
//                           Navigator.pushNamed(
//                             context,
//                             RouteNames.searchView,
//                             arguments: {
//                               'searchBloc': context.read<SearchBloc>(),
//                               'search': '',
//                             },
//                           );
//                         }
//                       },
//                     );
//                   },
//                 ),
//               if (showWishlist)
//                 BlocBuilder<BaseBloc, BaseState>(builder: (context, state) {
//                   return InkWell(
//                     child: (state.wishListProducts?.isEmpty ?? true)
//                         ? SvgPicture.asset(
//                       'assets/images/svgicons/header_wishlist.svg',
//                       width: 26.0,
//                       height: 26.0,
//                     )
//                         : badges.Badge(
//                       badgeStyle: badges.BadgeStyle(
//                         badgeColor: AppColors.colorPrimary,
//                         borderRadius: BorderRadius.circular(2),
//                         elevation: 0,
//                       ),
//                       position: badges.BadgePosition.topEnd(top: -8, end: -6),
//                       badgeContent: Text(
//                         state.wishListProducts!.length.toString(),
//                         style: const TextStyle(
//                           color: AppColors.white,
//                           fontSize: 10.0,
//                           fontFamily: "PanagramRegular",
//                         ),
//                       ),
//                       child: SvgPicture.asset(
//                         'assets/images/svgicons/header_wishlist.svg',
//                         width: 26.0,
//                         height: 26.0,
//                       ),
//                     ),
//                     onTap: () {
//                       if (SessionManager.instance.getAccessToken?.isNotEmpty ?? false) {
//                         Navigator.pushNamed(context, RouteNames.wishListScreen);
//                       } else {
//                         showLoginBottomSheet(context);
//                       }
//                     },
//                   );
//                 }),
//               if (showCart)
//                 BlocBuilder<BaseBloc, BaseState>(builder: (context, state) {
//                   return InkWell(
//                     child: (state.cartProducts?.isEmpty ?? true)
//                         ? SvgPicture.asset(
//                       'assets/images/svgicons/header_cart.svg',
//                       width: 26.0,
//                       height: 26.0,
//                     )
//                         : badges.Badge(
//                       badgeStyle: badges.BadgeStyle(
//                         badgeColor: AppColors.colorPrimary,
//                         borderRadius: BorderRadius.circular(2),
//                         elevation: 0,
//                       ),
//                       position: badges.BadgePosition.topEnd(top: -8, end: -6),
//                       badgeContent: Text(
//                         state.cartProducts!.length.toString(),
//                         style: const TextStyle(
//                           color: AppColors.white,
//                           fontSize: 10.0,
//                           fontFamily: "PanagramRegular",
//                         ),
//                       ),
//                       child: SvgPicture.asset(
//                         'assets/images/svgicons/header_cart.svg',
//                         width: 26.0,
//                         height: 26.0,
//                       ),
//                     ),
//                     onTap: () => Navigator.pushNamed(context, RouteNames.cartScreen),
//                   );
//                 }),
//             ],
//           ),
//         ],
//         elevation: 5.0,
//       ),
//     );
//   }
//
//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }
//
//
