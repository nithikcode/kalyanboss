import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/widgets/gali_shared_widgets.dart';

class OpenPlayScreen extends StatefulWidget {
  const OpenPlayScreen({super.key});

  @override
  State<OpenPlayScreen> createState() => _OpenPlayScreenState();
}

class _OpenPlayScreenState extends State<OpenPlayScreen> {
  final _numbersCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _harupCtrl = TextEditingController();
  final _harupAmountCtrl = TextEditingController();

  @override
  void dispose() {
    _numbersCtrl.dispose();
    _amountCtrl.dispose();
    _harupCtrl.dispose();
    _harupAmountCtrl.dispose();
    super.dispose();
  }

  void _recalculate() {
    context.read<GaliDesawarGameBloc>().add(RecalculateOpenPlayEvent(
          numbersText: _numbersCtrl.text,
          amountText: _amountCtrl.text,
          harupText: _harupCtrl.text,
          harupAmountText: _harupAmountCtrl.text,
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
          title: const Text('Open Play',
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
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Jodi row ────────────────────────────────────────────────
                  _InputField(
                    controller: _numbersCtrl,
                    hint: 'Enter Pairs (e.g. 2345)',
                    onChanged: (_) => _recalculate(),
                    suffix: _ToggleChip(
                      label: 'With\nPalti',
                      active: data.openPlayWithPalti,
                      onTap: () {
                        ctx
                            .read<GaliDesawarGameBloc>()
                            .add(ToggleOpenPlayPaltiEvent());
                        _recalculate();
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 14, left: 8, right: 8),
                    child: Text('=',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ),
                  _InputField(
                    controller: _amountCtrl,
                    hint: 'Amount',
                    onChanged: (_) => _recalculate(),
                  ),
                  const SizedBox(height: 12),

                  // ── Harup row ────────────────────────────────────────────────

                      _InputField(
                        controller: _harupCtrl,
                        hint: 'Enter Harup Digits',
                        onChanged: (_) => _recalculate(),
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ToggleChip(
                              label: 'A',
                              active: data.openPlayHarupAndar,
                              onTap: () {
                                ctx
                                    .read<GaliDesawarGameBloc>()
                                    .add(ToggleOpenPlayHarupAndarEvent());
                                _recalculate();
                              },
                            ),
                            const SizedBox(width: 6),
                            _ToggleChip(
                              label: 'B',
                              active: data.openPlayHarupBahar,
                              onTap: () {
                                ctx
                                    .read<GaliDesawarGameBloc>()
                                    .add(ToggleOpenPlayHarupBaharEvent());
                                _recalculate();
                              },
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 14, left: 8, right: 8),
                        child: Text('=',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                      ),
                      _InputField(
                        controller: _harupAmountCtrl,
                        hint: 'Harup Amount',
                        onChanged: (_) => _recalculate(),
                      ),


                  const SizedBox(height: 20),

                  // ── Bet list ─────────────────────────────────────────────────
                  GaliBetListCard(
                    bets: data.openPlayBets,
                    onRemove: (i) => ctx
                        .read<GaliDesawarGameBloc>()
                        .add(RemoveOpenPlayBetEvent(i)),
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

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable text field
// ─────────────────────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        border: const OutlineInputBorder(),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: suffix,
              )
            : null,
        suffixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Toggle chip (With Palti / A / B)
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              height: 1.2,
              color: colorScheme.onSurface,
            ),
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
