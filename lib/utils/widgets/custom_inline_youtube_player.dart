// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class InlineYouTubePlayer extends StatefulWidget {
//   final String thumbnailUrl;
//   final String videoId;
//
//   const InlineYouTubePlayer({
//     super.key,
//     required this.thumbnailUrl,
//     required this.videoId,
//   });
//
//   @override
//   State<InlineYouTubePlayer> createState() => _InlineYouTubePlayerState();
// }
//
// class _InlineYouTubePlayerState extends State<InlineYouTubePlayer> {
//   bool _isPlaying = false;
//   late YoutubePlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: const YoutubePlayerFlags(
//         autoPlay: false,
//         mute: false,
//         showLiveFullscreenButton: false,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _showFullscreen() async {
//     // Get current position before navigating
//     final currentPosition = _controller.value.position;
//
//     // Pause the current player
//     _controller.pause();
//
//     // Navigate to fullscreen
//     await Navigator.of(context).push(
//       MaterialPageRoute(
//         builder: (context) => _FullscreenPlayer(
//           videoId: widget.videoId,
//           startPosition: currentPosition,
//         ),
//       ),
//     );
//
//     // After returning, simply ensure the local player is ready to play.
//     if (mounted) {
//       // Set the flag to true to immediately show the player UI
//       setState(() {
//         _isPlaying = true;
//       });
//
//       _controller.play();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isPlaying) {
//       return Stack(
//         children: [
//           YoutubePlayer(
//             controller: _controller,
//             showVideoProgressIndicator: true,
//           ),
//           Positioned(
//             bottom: 8,
//             right: 8,
//             child: IconButton(
//               icon: const Icon(Icons.fullscreen, color: Colors.white),
//               onPressed: _showFullscreen,
//             ),
//           ),
//         ],
//       );
//     }
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _isPlaying = true;
//         });
//         _controller.play();
//       },
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           CachedNetworkImage(
//             imageUrl: widget.thumbnailUrl,
//             fit: BoxFit.cover,
//           ),
//           SvgPicture.asset(
//             'assets/images/svgicons/ic_play_youtube.svg',
//             height: 50,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// class _FullscreenPlayer extends StatefulWidget {
//   final String videoId;
//   final Duration startPosition;
//
//   const _FullscreenPlayer({
//     required this.videoId,
//     required this.startPosition,
//   });
//
//   @override
//   State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
// }
//
// class _FullscreenPlayerState extends State<_FullscreenPlayer> {
//   late YoutubePlayerController _controller;
//
//   @override
//   void initState() {
//     super.initState();
//
//
//     _controller = YoutubePlayerController(
//       initialVideoId: widget.videoId,
//       flags: YoutubePlayerFlags(
//         autoPlay: true,
//         mute: false,
//         startAt: widget.startPosition.inSeconds,
//       ),
//     );
//
//
//
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     SystemChrome.setPreferredOrientations([
//       DeviceOrientation.portraitUp,
//     ]);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Center(
//               child: YoutubePlayer(
//                 controller: _controller,
//                 showVideoProgressIndicator: true,
//                 onEnded: (metaData) {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ),
//             Positioned(
//               top: 16,
//               right: 16,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }