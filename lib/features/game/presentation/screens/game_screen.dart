import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kalyanboss/config/routes/route_names.dart';
import 'package:kalyanboss/config/theme/theme.dart';
import 'package:kalyanboss/features/game/data/model/market_model.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/market_entity.dart';
import 'package:kalyanboss/features/game/presentation/screens/game_screen.dart';
import 'package:marquee/marquee.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    _fetchMarkets();
  }

  void _fetchMarkets() {
    context.read<GameBloc>().add(FetchAllMarkets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Markets"),
        actions: [
          IconButton(
            onPressed: _fetchMarkets,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {



          // .when ensures all ApiStates are handled
          return state.marketResponseEntity?.when(
            initial: () => const Center(child: Text("Initializing...")),
            loading: () => const Center(child: CircularProgressIndicator()),
            refreshing: (data) => _buildMarketList(data),
            success: (entity) => RefreshIndicator(
              onRefresh: () async => _fetchMarkets(),
              child: _buildMarketList(entity),
            ),
            error: (message, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text("Error: $message", style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchMarkets,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),
          ) ??
              const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMarketList(MarketResponseEntity? entity) {
    final markets = entity?.data ?? [];

    if (markets.isEmpty) {
      return const Center(child: Text("No Markets Available"));
    }

    return ListView.builder(
      itemCount: markets.length,
      padding: const EdgeInsets.all(10),
      physics: const AlwaysScrollableScrollPhysics(), // Ensures RefreshIndicator works even with few items
      itemBuilder: (context, index) {
        return buildMarketCard(context,markets[index]);
      },
    );
  }
}
Widget buildMarketCard(BuildContext context, MarketEntity market) {
  if (market.tag == 'starline' || market.status == false) {
    return const SizedBox.shrink();
  }

  final theme = Theme.of(context);
  final primary = theme.primaryColor;
  final cardBg = theme.cardColor;

  final bool timePassed = isTimePassed(market.closeTime);
  final bool isHoliday = market.marketStatus == false || isHolidayToday(market.marketOffDay);
  final bool isClosed = isHoliday || timePassed;

  bool isPressed = false;

  return Hero(
    tag: 'market_${market.id}',
    child: Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: StatefulBuilder(
          builder: (context, setState) {
            return GestureDetector(
              onTapDown: (_) => setState(() => isPressed = true),
              onTapCancel: () => setState(() => isPressed = false),
              onTapUp: (_) {
                setState(() => isPressed = false);
                if (isHoliday) {
                  Fluttertoast.showToast(msg: 'Holiday!!!, Market is close.');
                  return;
                }
                if (timePassed) {
                  Fluttertoast.showToast(msg: 'Market is closed for the day.');
                  return;
                }
                HapticFeedback.selectionClick();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: Color.alphaBlend(Colors.black.withOpacity(0.6), primary),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: EdgeInsets.only(
                    top: isPressed ? 6.0 : 0.0,
                    left: isPressed ? 4.0 : 0.0,
                    bottom: isPressed ? 0.0 : 6.0,
                    right: isPressed ? 0.0 : 4.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black87, width: 2.0),
                    color: cardBg,
                  ),
                  child: Column(
                    children: [
                      // Header Section
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildStatusIcon(isClosed, context,market),
                            const SizedBox(width: 15),
                            Expanded(
                              flex: 3,
                              child: _buildMarketInfo(market),
                            ),
                            _buildChartAction(context, market.id ?? '', market.name ?? ''),
                          ],
                        ),
                      ),

                      // BOTTOM BAR WITH MARQUEE
                      _buildBottomBarWithMarquee(market, isClosed, primary),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

// 1. BOTTOM BAR WITH MARQUEE TIMES
Widget _buildBottomBarWithMarquee(MarketEntity market, bool isClosed, Color primary) {
  final String marqueeText = "OPEN TIME: ${formatTime(market.openTime)} | CLOSE TIME: ${formatTime(market.closeTime)} • ";

  return Container(
    height: 50,
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.2),
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(14),
        bottomRight: Radius.circular(14),
      ),
      border: const Border(top: BorderSide(color: Colors.black38, width: 1.5)),
    ),
    child: Row(
      children: [
        // Marquee Section
        Expanded(
          child: SizedBox(
            height: 20,
            child: Marquee(
              text: marqueeText,
              style: AppTextStyles.bodySmallBold(color: primary.withOpacity(0.8)),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 20.0,
              velocity: 30.0,
              pauseAfterRound: const Duration(seconds: 1),
              accelerationDuration: const Duration(seconds: 1),
              accelerationCurve: Curves.linear,
            ),
          ),
        ),

        // RUNNING STATUS WITH ANIMATED DOT BORDER
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: isClosed
              ? _buildStaticClosedStatus()
              : const AnimatedRunningStatus(),
        ),
      ],
    ),
  );
}

// 2. ANIMATED DOT BORDER WIDGET
class AnimatedRunningStatus extends StatefulWidget {
  const AnimatedRunningStatus({super.key});

  @override
  State<AnimatedRunningStatus> createState() => _AnimatedRunningStatusState();
}

class _AnimatedRunningStatusState extends State<AnimatedRunningStatus> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DotBorderPainter(_controller),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          'RUNNING TODAY',
          style: AppTextStyles.bodySmallBold(color: Colors.green),
        ),
      ),
    );
  }
}

// 3. THE DOT BORDER PAINTER
class DotBorderPainter extends CustomPainter {
  final Animation<double> animation;
  DotBorderPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final RRect rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));

    // Draw the static base border
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, paint);

    // Draw the running dot
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final length = metrics.length;
    final dashOffset = length * animation.value;

    final dotPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Use dash path effect or compute point manually for a simple dot
    final tangent = metrics.getTangentForOffset(dashOffset);
    if (tangent != null) {
      canvas.drawCircle(tangent.position, 3.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(DotBorderPainter oldDelegate) => true;
}

// Helper for static status when closed
Widget _buildStaticClosedStatus() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.red.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.withOpacity(0.4)),
    ),
    child: Text('CLOSE FOR TODAY', style: AppTextStyles.bodySmallBold(color: Colors.red)),
  );
}

// Helper to format time strings from 24h to 12h for the Marquee
String formatTime(String? time) {
  if (time == null || !time.contains(':')) return "--:--";
  try {
    final parts = time.split(':');
    final hr = int.parse(parts[0]);
    final min = parts[1];
    final period = hr >= 12 ? 'PM' : 'AM';
    final formattedHr = hr > 12 ? hr - 12 : (hr == 0 ? 12 : hr);
    return "$formattedHr:$min $period";
  } catch (_) { return time; }
}
// --- Separated UI Components for Cleanliness ---

Widget _buildStatusIcon(bool isClosed, BuildContext context, MarketEntity market) {
  return GestureDetector(
    onTap: isClosed ? null :  () {
      context.pushNamed(
        RouteNames.gameList,
        extra: {
          'market': market,
        },
      );
    },
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isClosed ? Colors.red : Colors.green).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Image.asset(
        isClosed ? 'assets/images/pause.png' : 'assets/images/play.png',
        width: 46, height: 35,
      ),
    ),
  );
}

Widget _buildMarketInfo(MarketEntity market) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        (market.name ?? 'MARKET').toUpperCase(),
        style: AppTextStyles.h3(color: Colors.teal, weight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          "${market.openPanna}-${market.openDigit}${market.closeDigit}-${market.closePanna}",
          style: AppTextStyles.bodyLargeBold(color: const Color(0xFFFFD700)).copyWith(
              shadows: [const Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 2)]
          ),
        ),
      ),
    ],
  );
}

// Handles 24-hour format (e.g., "14:30") to avoid FormatException
bool isTimePassed(String? timeString) {
  try {
    if (timeString == null || timeString.isEmpty || timeString == "-") return false;

    final now = DateTime.now();
    final parts = timeString.split(':');
    if (parts.length < 2) return false;

    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final marketTimeToday = DateTime(now.year, now.month, now.day, hour, minute);

    return now.isAfter(marketTimeToday);
  } catch (e) {
    debugPrint("Error parsing 24h time: $e");
    return false;
  }
}

// Checks if today is marked 'false' in the market_off_day map
bool isHolidayToday(MarketOffDayEntity? offDay) {
  if (offDay == null) return false;

  final String today = DateFormat('EEEE').toString().toLowerCase(); // e.g., "monday"

  final Map<String, bool?> days = {
    'monday': offDay.monday,
    'tuesday': offDay.tuesday,
    'wednesday': offDay.wednesday,
    'thursday': offDay.thursday,
    'friday': offDay.friday,
    'saturday': offDay.saturday,
    'sunday': offDay.sunday,
  };

  // If the day is explicitly set to false, it is a holiday
  return days[today] == false;
}

// 1. Chart Action Button (On the right of the card)
Widget _buildChartAction(BuildContext context, String id, String name) {
  return InkWell(
    onTap: () {
      HapticFeedback.mediumImpact();
      context.pushNamed(RouteNames.chartScreen, extra: {
        'marketId' : id,
        'marketName' : name
      });
    },
    child: Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(
        'assets/images/chart.png',
        width: 40,
        height: 35,
      ),
    ),
  );
}

