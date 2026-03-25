import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kalyanboss/features/game/domain/entity/result_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';

class ChartScreen extends StatefulWidget {
  final String marketId;
  final String marketName;

  const ChartScreen({
    super.key,
    required this.marketId,
    required this.marketName,
  });

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  DateTime _selectedMonth = DateTime.now();

  static const Color borderColor = Colors.black;
  static const Color textColor = Colors.black;

  @override
  void initState() {
    super.initState();
    _fetchMarketResults();
  }

  void _fetchMarketResults() {
    context.read<GameBloc>().add(
      FetchMarketResult(marketId: widget.marketId),
    );
  }

  List<DateTime> _generateDateRange() {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    List<DateTime> dates = [];
    for (DateTime date = startDate;
    date.isBefore(endDate.add(const Duration(days: 1)));
    date = date.add(const Duration(days: 1))) {
      dates.add(date);
    }
    return dates;
  }

  void _changeMonth(int direction) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + direction,
        1,
      );
    });
  }

  String _getMonthYearString() {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[_selectedMonth.month - 1]} ${_selectedMonth.year}';
  }

  // Updated to use MarketResultItem and safely parse the non-nullable 'from' String
  MarketResultItem? _getResultForDate(DateTime date, List<MarketResultItem> data) {
    final targetDate = DateTime(date.year, date.month, date.day);
    try {
      return data.firstWhere((result) {
        if (result.from.isEmpty) return false;
        try {
          final apiDate = DateTime.parse(result.from);
          final apiDateOnly = DateTime(apiDate.year, apiDate.month, apiDate.day);
          return targetDate.isAtSameMomentAs(apiDateOnly);
        } catch (_) {
          return false;
        }
      });
    } catch (_) { // firstWhere throws a StateError if no match is found
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.marketName.toUpperCase(),
          // style: GoogleFonts.poppins(
          //   color: Colors.black,
          //   fontWeight: FontWeight.bold,
          //   fontSize: 20,
          // ),
        ),
        actions: [
          BlocBuilder<GameBloc, GameState>(
            buildWhen: (prev, curr) =>
            prev.marketResponseResultEntity != curr.marketResponseResultEntity,
            builder: (context, state) {
              final isLoading = state.marketResponseResultEntity?.whenOrNull(loading: () => true) ?? false;
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.black),
                onPressed: isLoading ? null : _fetchMarketResults,
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<GameBloc, GameState>(
        buildWhen: (prev, curr) =>
        prev.marketResponseResultEntity != curr.marketResponseResultEntity,
        builder: (context, state) {
          return state.marketResponseResultEntity?.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (message,_) => _buildErrorView(message),
            success: (MarketResponse data) => _buildContent(data),
            initial: () => Container(),
            refreshing: (MarketResponse? oldData)=>  _buildContent(oldData!),
          ) ?? SizedBox.shrink();
        },
      ),
    );
  }

  // ─────────────────────────── Error State ───────────────────────────

  Widget _buildErrorView(String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              message ?? "Something went wrong",
              textAlign: TextAlign.center,
              // style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchMarketResults,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── Main Content ───────────────────────────

  Widget _buildContent(MarketResponse response) {
    // Access the new .data property instead of .results
    final List<MarketResultItem> results = response.data;

    return Column(
      children: [
        _buildMonthNavigator(),
        const SizedBox(height: 10),
        Expanded(child: _buildCalendarGrid(results)),
      ],
    );
  }

  // ─────────────────────────── Month Navigator ───────────────────────────

  Widget _buildMonthNavigator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
            color: Colors.black,
          ),
          Text(
            _getMonthYearString(),
            // style: GoogleFonts.poppins(
            //   color: Colors.black,
            //   fontSize: 18,
            //   fontWeight: FontWeight.bold,
            // ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Weekday Header ───────────────────────────

  Widget _buildWeekdayHeader() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
          left: BorderSide(color: borderColor, width: 1),
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
            .map((day) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: Text(
              day,
              textAlign: TextAlign.center,
              // style: GoogleFonts.inter(
              //   color: textColor,
              //   fontWeight: FontWeight.bold,
              //   fontSize: 12,
              // ),
            ),
          ),
        ))
            .toList(),
      ),
    );
  }

  // ─────────────────────────── Calendar Grid ───────────────────────────

  Widget _buildCalendarGrid(List<MarketResultItem> results) {
    final dates = _generateDateRange();
    final startWeekday = dates.first.weekday % 7; // 0 = Sunday

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildWeekdayHeader(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.55,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
            ),
            itemCount: dates.length + startWeekday,
            itemBuilder: (context, index) {
              if (index < startWeekday) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                );
              }

              final dateIndex = index - startWeekday;
              if (dateIndex >= dates.length) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                );
              }

              final date = dates[dateIndex];
              final result = _getResultForDate(date, results);
              final isToday = date.day == DateTime.now().day &&
                  date.month == DateTime.now().month &&
                  date.year == DateTime.now().year;

              return _buildTableCell(date, result, isToday);
            },
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── Table Cell ───────────────────────────

  Widget _buildTableCell(DateTime date, MarketResultItem? result, bool isToday) {
    return Container(
      decoration: BoxDecoration(
        color: isToday ? Colors.yellow.withOpacity(0.1) : Colors.white,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor, width: 0.5)),
            ),
            child: Text(
              date.day.toString(),
              // style: GoogleFonts.roboto(
              //   fontSize: 10,
              //   fontWeight: FontWeight.bold,
              //   color: textColor,
              // ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _buildTableMarketData(result),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── Market Data Cell ───────────────────────────

  Widget _buildTableMarketData(MarketResultItem? result) {
    List<String> getPannaDigits(String? panna) {
      // Treat null, empty, or placeholder '-' as a default state
      if (panna == null || panna.isEmpty || panna == '-') return ['*', '*', '*'];
      if (panna.contains('*')) return ['*', '*', '*'];

      final clean = panna.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.isEmpty) return ['*', '*', '*'];
      return clean.split('').take(3).toList();
    }

    final openDigits = getPannaDigits(result?.openPanna);
    final closeDigits = getPannaDigits(result?.closePanna);

    // Safely fallback if digit is empty or '-' (based on your mapping extension)
    final openJodi = (result?.openDigit == null || result!.openDigit.isEmpty || result.openDigit == '-') ? '*' : result.openDigit;
    final closeJodi = (result?.closeDigit == null || result!.closeDigit.isEmpty || result.closeDigit == '-') ? '*' : result.closeDigit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 0.0, 4.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Open Panna — vertical
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: openDigits
                .map((d) => Text(
              d,
              // style: GoogleFonts.roboto(
              //   fontSize: 9,
              //   fontWeight: FontWeight.w500,
              //   color: textColor,
              // ),
            ))
                .toList(),
          ),
          // Jodi (centre)
          Expanded(
            child: Text(
              "$openJodi$closeJodi",
              textAlign: TextAlign.center,
              // style: GoogleFonts.roboto(
              //   fontSize: 14,
              //   fontWeight: FontWeight.w900,
              //   color: textColor,
              // ),
            ),
          ),
          // Close Panna — vertical
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: closeDigits
                .map((d) => Text(
              d,
              // style: GoogleFonts.roboto(
              //   fontSize: 9,
              //   fontWeight: FontWeight.w500,
              //   color: textColor,
              // ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}