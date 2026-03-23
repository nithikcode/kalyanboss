// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:woodenstreet/config/constants.dart';
// import 'package:woodenstreet/utils/helpers/helpers.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// import '../../features/detail/domain/entities/review_entity.dart';
// import './custom_inline_youtube_player.dart';
//
// class ImageAndVideoPlayer extends StatefulWidget {
//   final List<Map<String, dynamic>> media;
//   final int initialIndex;
//   final VoidCallback? onClose;
//
//   final bool isReview;
//   final List<ReviewEntity>? reviewList;
//
//   const ImageAndVideoPlayer({
//     super.key,
//     required this.media,
//     this.initialIndex = 0,
//     this.onClose,
//     this.isReview = false,
//     this.reviewList,
//   });
//
//   @override
//   State<ImageAndVideoPlayer> createState() => _ImageAndVideoPlayerState();
// }
//
// class _ImageAndVideoPlayerState extends State<ImageAndVideoPlayer> {
//   late int _currentIndex;
//   late PageController _pageController;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: _currentIndex);
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   void _onPageChanged(int index) {
//     setState(() => _currentIndex = index);
//   }
//
//   String _constructUrl(String path) {
//
//     if (path.startsWith('http')) return path;
//     return widget.isReview ? '${AppStrings.baseImages}$path' : '${AppStrings.baseImagesStatic}$path';
//
//   }
//   @override
//   Widget build(BuildContext context) {
//     final isReview = widget.isReview;
//     final reviewList = widget.reviewList ?? [];
//
//     return Scaffold(
//       backgroundColor: isReview ? Colors.white : Colors.black.withOpacity(0.85),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // ----- Review Mode -----
//             if (isReview)
//               PageView.builder(
//                 controller: _pageController,
//                 onPageChanged: _onPageChanged,
//                 itemCount: reviewList.length,
//                 itemBuilder: (context, index) {
//                   final review = reviewList[index];
//                   final images = (review.productImages) ?? [];
//                   return SingleChildScrollView(
//                     padding: const EdgeInsets.only(bottom: 24),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Image Carousel for each review
//                         SizedBox(
//                           height: 350,
//                           child: PageView.builder(
//                             itemCount: images.length,
//                             itemBuilder: (context, i) {
//                               final imageUrl = _constructUrl(images[i].encodeSegments());
//                               return CachedNetworkImage(
//                                 imageUrl: imageUrl,
//                                 fit: BoxFit.contain,
//                                 placeholder: (context, url) =>
//                                     Center(child: Image.asset(AppLogos.imgPlaceHolder, fit: BoxFit.cover,width: double.infinity,)),
//                                 errorWidget: (context, url, error) =>
//                                  Center(child: Image.asset(AppLogos.imgPlaceHolder, fit: BoxFit.cover,width: double.infinity,)),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Product Info + Review Text
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 30),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (review.author != null &&( review.author?.isNotEmpty ?? false))
//                                 Text(
//                                   review.author ?? '',
//                                   style:  TextStyle(
//                                     fontSize: 16.sp,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               const SizedBox(height: 8),
//                               if (review.rating != null)
//                                 Row(
//                                   children: List.generate(
//                                     5,
//                                         (i) => Icon(
//                                       i < (review.rating ?? 0)
//                                           ? Icons.star
//                                           : Icons.star_border,
//                                       color: Colors.amber,
//                                     ),
//                                   ),
//                                 ),
//                               const SizedBox(height: 10),
//                               if (review.text != null)
//                                 Text(
//                                   review.text ?? '',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.black87,
//                                     height: 1.4,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//
//             // ----- Normal Mode (images/videos) -----
//             if (!isReview)
//               Column(
//                 children: [
//                   const SizedBox(height: 50),
//                   Expanded(
//                     child: PageView.builder(
//                       controller: _pageController,
//                       onPageChanged: _onPageChanged,
//                       itemCount: widget.media.length,
//                       itemBuilder: (context, index) {
//                         final item = widget.media[index];
//                         final isYoutube = item['youtube'] == true;
//                         final mediaUrl = _constructUrl(item['src']);
//
//                         if (isYoutube) {
//                           final videoId =
//                               YoutubePlayer.convertUrlToId(item['href']) ?? '';
//                           return Center(
//                             child: InlineYouTubePlayer(
//                               thumbnailUrl: mediaUrl,
//                               videoId: videoId,
//                             ),
//                           );
//                         } else {
//                           return InteractiveViewer(
//                             child: CachedNetworkImage(
//                               imageUrl: mediaUrl,
//                               fit: BoxFit.contain,
//                               placeholder: (context, url) =>
//                                   Center(child: Image.asset(AppLogos.imgPlaceHolder, fit: BoxFit.cover,width: double.infinity,)),
//                               errorWidget: (context, url, error) =>
//                               const Icon(Icons.error, color: Colors.red),
//                             ),
//                           );
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//             // ----- Arrows -----
//             if (_currentIndex > 0)
//               Positioned(
//                 left: 0,
//                 top: 0,
//                 bottom: 0,
//                 child: Center(
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: isReview ? Colors.black : Colors.white,
//                     ),
//                     onPressed: () {
//                       _pageController.previousPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             if (_currentIndex < (isReview ? reviewList.length : widget.media.length) - 1)
//               Positioned(
//                 right: 0,
//                 top: 0,
//                 bottom: 0,
//                 child: Center(
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.arrow_forward_ios,
//                       color: isReview ? Colors.black : Colors.white,
//                     ),
//                     onPressed: () {
//                       _pageController.nextPage(
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//
//             // ----- Close Button -----
//             Positioned(
//               top: 10,
//               right: 10,
//               child: IconButton(
//                 icon: Icon(
//                   Icons.close,
//                   color: isReview ? Colors.black : Colors.white,
//                   size: 28,
//                 ),
//                 onPressed: widget.onClose,
//               ),
//             ),
//
//             // ----- Counter (normal only) -----
//             if (!isReview)
//               Positioned(
//                 top: 12,
//                 left: 16,
//                 child: Text(
//                   '${_currentIndex + 1} / ${widget.media.length}',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }
//
//
