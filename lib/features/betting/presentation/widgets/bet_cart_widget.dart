import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/betting/domain/entity/betting_entity.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_event.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_state.dart';

class BetCartWidget extends StatelessWidget {
  const BetCartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      // Only rebuild for gameState changes — never for feedback-only updates.
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;

        if (data == null || data.cart.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Your cart is empty.\nAdd bets above ↑',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cart header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cart',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (data == null || data.cart.isEmpty)
                  Align(
                    alignment: Alignment.topRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          context.read<UnifiedGameBloc>().add(const ClearCartEvent()),
                      icon: const Icon(Icons.delete_sweep, color: Colors.red),
                      label: const Text('Clear All',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _SummaryBar(data: data),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.cart.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) => _CartTile(
                entry: data.cart[i],
                onRemove: () => ctx
                    .read<UnifiedGameBloc>()
                    .add(RemoveBetEvent(data.cart[i].id)),
              ),
            ),
            const SizedBox(height: 8),

          ],
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final GameReadyData data;

  const _SummaryBar({required this.data});

  @override
  Widget build(BuildContext context) {
    final isOverBalance = data.remainingBalance < 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isOverBalance
            ? Colors.red.withOpacity(0.1)
            : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOverBalance
              ? Colors.red
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _InfoChip(
            label: 'Bets',
            value: '${data.cart.length}',
            icon: Icons.receipt_long,
          ),
          _InfoChip(
            label: 'Total',
            value: '₹${data.totalPoints}',
            icon: Icons.currency_rupee,
            color: Colors.orange,
          ),
          _InfoChip(
            label: 'Balance',
            value: '₹${data.remainingBalance}',
            icon: Icons.account_balance_wallet,
            color: isOverBalance ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CartTile extends StatelessWidget {
  final BetEntry entry;
  final VoidCallback onRemove;

  const _CartTile({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final subtitle = entry.closeDigit.isEmpty
        ? entry.openDigit
        : '${entry.openDigit}  →  ${entry.closeDigit}';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: _sessionColor(entry.session).withOpacity(0.15),
        child: Text(
          entry.session[0], // "O" or "C"
          style: TextStyle(
            color: _sessionColor(entry.session),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
      title: Text(subtitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(entry.tag,
          style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${entry.points}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: Colors.red),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Color _sessionColor(String session) =>
      session == 'OPEN' ? Colors.green : Colors.blue;
}