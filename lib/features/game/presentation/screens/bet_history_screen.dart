import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/game/domain/entity/bet_history_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:intl/intl.dart'; // For cleaner date formatting

class BetHistoryScreen extends StatefulWidget {
  const BetHistoryScreen({super.key});

  @override
  State<BetHistoryScreen> createState() => _BetHistoryScreenState();
}

class _BetHistoryScreenState extends State<BetHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GameBloc>().add(FetchBetHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      appBar: AppBar(
        title: const Text("Bet History", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return state.betResponseEntity?.when(
            initial: () => _buildLoading(),
            loading: () => _buildLoading(),
            refreshing: (old) => _buildList(old?.data?.betList ?? []),
            error: (msg, _) => _buildError(msg),
            success: (res) => _buildList(res.data?.betList ?? []),
          ) ?? const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<BetItemEntity> items) {
    if (items.isEmpty) return const Center(child: Text("No transactions yet."));

    return RefreshIndicator(
      onRefresh: () async => context.read<GameBloc>().add(FetchBetHistory()),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildBetCard(items[index]),
      ),
    );
  }

  Widget _buildBetCard(BetItemEntity bet) {
    final bool isWin = bet.status.toLowerCase() == 'win';
    final bool isPending = bet.status.toLowerCase() == 'pending';

    // Pick color based on status
    final statusColor = isWin ? Colors.green : (isPending ? Colors.orange : Colors.red);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 6)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left Side: Game Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bet.marketName.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${bet.gameMode} • ${bet.session}",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(bet.createdAt), // Clean Date helper
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right Side: Amount & Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isWin ? '+' : ''}${bet.points}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Text(
                    bet.status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to format date cleanly
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError(String msg) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 48, color: Colors.red),
        const SizedBox(height: 16),
        Text(msg),
        TextButton(
            onPressed: () => context.read<GameBloc>().add(FetchBetHistory()),
            child: const Text("Try Again"))
      ],
    ),
  );
}