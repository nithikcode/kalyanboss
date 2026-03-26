import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/features/game/domain/entity/transaction_entity.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Assuming your GameBloc or a specific TransactionBloc handles this
    context.read<GameBloc>().add(FetchTransactionHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.2),
      appBar: AppBar(
        title: const Text("Wallet Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          // Replace with your actual state field for transactions
          return state.transactionEntity?.when(
            initial: () => _buildLoading(),
            loading: () => _buildLoading(),
            refreshing: (old) => _buildList(old?.data ?? []),
            error: (msg, _) => _buildError(msg),
            success: (res) => _buildList(res.data),
          ) ?? const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(List<TransactionItemEntity> items) {
    if (items.isEmpty) return const Center(child: Text("No transactions found"));

    return RefreshIndicator(
      onRefresh: () async => context.read<GameBloc>().add(FetchTransactionHistory()),
      child: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildTransactionCard(items[index]),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItemEntity tx) {
    final bool isDeposit = tx.transferType.toLowerCase() == 'deposit';
    final bool isCompleted = tx.status.toLowerCase() == 'completed';

    // UI Logic: Deposits are usually Green/Inward, Withdrawals are Red/Outward
    final Color flowColor = isDeposit ? Colors.green : Colors.redAccent;
    final String flowIcon = isDeposit ? AppLogos.deposit : AppLogos.withdraw;

    return Card(
      elevation: 0.5,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Icon Indicator
            Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: flowColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              // Adding padding forces the SVG to shrink
              padding: const EdgeInsets.all(8),
              child: SvgPicture.asset(
                flowIcon,
                colorFilter: ColorFilter.mode(flowColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 12),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.note.isNotEmpty ? tx.note : (isDeposit ? "Deposit" : "Withdrawal"),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: ${tx.id.substring(tx.id.length - 8).toUpperCase()}",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  Text(
                    _formatDate(tx.createdAt),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Amount and Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${isDeposit ? '+' : '-'} ₹${tx.amount}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: flowColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Bal: ₹${tx.currentBalance}",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (!isCompleted)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      tx.status.toUpperCase(),
                      style: const TextStyle(color: Colors.orange, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  Widget _buildError(String msg) => Center(child: Text(msg));
}
