import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/widgets/gali_shared_widgets.dart';

class CrossGameScreen extends StatefulWidget {
  const CrossGameScreen({super.key});

  @override
  State<CrossGameScreen> createState() => _CrossGameScreenState();
}

class _CrossGameScreenState extends State<CrossGameScreen> {
  final _digitsCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _digitsCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    context.read<GaliDesawarGameBloc>().add(RecalculateCrossGameEvent(
          digitsText: _digitsCtrl.text,
          amountText: _amountCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GaliDesawarGameBloc, GaliDesawarGameState>(
      listenWhen: (p, c) =>
          c.feedback != null && c.feedback != p.feedback,
      listener: (ctx, state) {
        final fb = state.feedback!;
        ScaffoldMessenger.of(ctx)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(fb.message),
            backgroundColor:
                fb.isError ? Colors.red.shade700 : Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ));
        if (!fb.isError) Navigator.pop(ctx);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cross Game',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        bottomNavigationBar: const GaliSubmitBar(),
        body: BlocBuilder<GaliDesawarGameBloc, GaliDesawarGameState>(
          buildWhen: (p, c) => c.gameState != p.gameState,
          builder: (ctx, state) {
            final data = state.gameState.dataOrNull;
            if (data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Input row ────────────────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _digitsCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => _recalculate(),
                          decoration: InputDecoration(
                            hintText: 'Enter Digits (e.g. 234)',
                            isDense: true,
                            border: const OutlineInputBorder(),
                            suffixIcon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: _ToggleChip(
                                label: 'Without\nJoda',
                                active: data.crossWithoutJoda,
                                onTap: () {
                                  ctx.read<GaliDesawarGameBloc>().add(
                                      ToggleCrossWithoutJodaEvent());
                                  _recalculate();
                                },
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 0, minHeight: 0),
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 14, left: 8, right: 8),
                        child: Text('=',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (_) => _recalculate(),
                          decoration: const InputDecoration(
                            hintText: 'Amount per combo',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Bet list ─────────────────────────────────────────────────
                  GaliBetListCard(
                    bets: data.crossBets,
                    onRemove: (i) => ctx
                        .read<GaliDesawarGameBloc>()
                        .add(RemoveCrossBetEvent(i)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: active,
              onChanged: (_) => onTap(),
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            ),
          ),
        ],
      ),
    );
  }
}
