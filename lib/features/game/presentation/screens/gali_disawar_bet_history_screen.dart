import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kalyanboss/features/game/domain/entity/bet_history_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart'; // For Date Formatting

class GaliDisawarBetHistoryScreen extends StatelessWidget {
  const GaliDisawarBetHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    const darkSurface = Color(0xFF0B0B0F);
    const deepSurface = Color(0xFF08080C);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 12, 11),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [deepSurface, darkSurface],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            'Bet History',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: Colors.white60,
            tabs: const [
              Tab(text: "ALL HISTORY"),
              Tab(text: "WINNINGS"),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [deepSurface, darkSurface],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Date Filter Section
              _buildDateFilterHeader(context),

              Expanded(
                child: TabBarView(
                  children: [
                    _HistoryList(isWinningOnly: false), // All bets
                    _HistoryList(isWinningOnly: true),  // Winners only
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateFilterHeader(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        // Assuming your state has fromDate and toDate
        final fromDate = state.fromDate;
        final toDate = state.toDate;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _dateControl(
                      context,
                      label: "From Date",
                      date: fromDate,
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dateControl(
                      context,
                      label: "To Date",
                      date: toDate,
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                    onPressed: () {
                    if (fromDate == null || toDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select date range")));
                    return;
                    }
                    // No formatting needed in UI! The Bloc does it now.
                    context.read<GameBloc>().add(FetchGaliDesawarBetHistory());
                    },
                  child: const Text("SEARCH RECORDS",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dateControl(BuildContext context, {required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: Colors.white54, size: 18),
            const SizedBox(width: 8),
            Text(
              date == null ? label : DateFormat('dd-MM-yyyy').format(date),
              style: TextStyle(color: date == null ? Colors.white38 : Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      context.read<GameBloc>().add(SelectHistoryDate(date: picked, isFromDate: isFromDate));
    }
  }
}

class _HistoryList extends StatelessWidget {
  final bool isWinningOnly;
  const _HistoryList({required this.isWinningOnly});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      builder: (context, state) {
        final betState = state.galiDesawarBetHistory;

        if (betState == null) return const Center(child: CircularProgressIndicator());

        return betState.when(
          initial: () => const SizedBox(),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (msg, _) => Center(child: Text(msg, style: const TextStyle(color: Colors.red))),
          refreshing: (data) => _buildList(context, data?.data?.betList ?? []),
          success: (entity) => _buildList(context, entity.data?.betList ?? []),
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<BetItemEntity> allBets) {
    // Filter logic
    final displayList = isWinningOnly
        ? allBets.where((e) => e.win == "true").toList()
        : allBets;

    if (displayList.isEmpty) {
      return Center(
        child: Text(isWinningOnly ? "No winning bets found" : "No records found",
            style: const TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final bet = displayList[index];
        return _BetCard(bet: bet);
      },
    );
  }
}

class _BetCard extends StatelessWidget {
  final BetItemEntity bet;
  const _BetCard({required this.bet});

  @override
  Widget build(BuildContext context) {
    final isWin = bet.win == "true";
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141720),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWin ? Colors.green.withOpacity(0.3) : Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(bet.marketName ?? '',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWin ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isWin ? "WINNER" : "PENDING",
                    style: TextStyle(color: isWin ? Colors.green : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _info(context, "Amount", "₹${bet.points}"),
              _info(context, "Digit", "${bet.openDigit ?? ''}${bet.closeDigit ?? ''}"),
              // _info(context, "Win", "₹${bet.winningAmount ?? '0'}", isHighlight: isWin),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(BuildContext context, String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        Text(value, style: TextStyle(
            color: isHighlight ? Colors.green : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14)
        ),
      ],
    );
  }
}