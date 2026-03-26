import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Sticky bottom bar shared by all three game screens
// ─────────────────────────────────────────────────────────────────────────────
class GaliSubmitBar extends StatelessWidget {
  const GaliSubmitBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<GaliDesawarGameBloc, GaliDesawarGameState>(
      buildWhen: (p, c) => c.gameState != p.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                // Total amount display
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '₹${data.totalAmount}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Total Amount',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Place Bet button
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        disabledBackgroundColor:
                            colorScheme.primary.withOpacity(0.4),
                        shape: const RoundedRectangleBorder(),
                        elevation: 0,
                      ),
                      onPressed: data.canSubmit
                          ? () => ctx
                              .read<GaliDesawarGameBloc>()
                              .add(SubmitGaliDesawarBetsEvent())
                          : null,
                      child: data.isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text(
                              'PLACE BET',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bet list card — rendered below the input in every game screen
// ─────────────────────────────────────────────────────────────────────────────
class GaliBetListCard extends StatelessWidget {
  /// The bets to display.
  final List<GaliDesawarBet> bets;

  /// Called when the delete button on a row is tapped.
  final void Function(int index) onRemove;

  const GaliBetListCard({
    super.key,
    required this.bets,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (bets.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: bets.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: colorScheme.outline.withOpacity(0.2)),
        itemBuilder: (_, i) {
          final bet = bets[i];
          final typeLabel = switch (bet.betType) {
            BetType.jodi => '',
            BetType.leftDigit => ' (A)',
            BetType.rightDigit => ' (B)',
          };
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${bet.betNumber}$typeLabel',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const Text('='),
                const SizedBox(width: 12),
                Text(
                  '₹${bet.betAmount}',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => onRemove(i),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Colors.red),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
