import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/widgets/gali_shared_widgets.dart';

class JantriScreen extends StatelessWidget {
  const JantriScreen({super.key});

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
          title: const Text('Jantri Game',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        bottomNavigationBar: const GaliSubmitBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Enter Amount Below'),
              const SizedBox(height: 10),

              // ── 100-cell Jodi grid (01–99, 00) ─────────────────────────────
              _JantriGrid(
                count: 100,
                labelBuilder: (i) =>
                    i == 99 ? '00' : (i < 9 ? '0${i + 1}' : '${i + 1}'),
                betNumberBuilder: (i) =>
                    i == 99 ? '00' : (i < 9 ? '0${i + 1}' : '${i + 1}'),
                betType: BetType.jodi,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Andar / A'),
              const SizedBox(height: 8),

              // ── 10-cell Andar grid (1–9, 0) ─────────────────────────────────
              _JantriGrid(
                count: 10,
                labelBuilder: (i) => i == 9 ? '0' : '${i + 1}',
                betNumberBuilder: (i) => i == 9 ? '0' : '${i + 1}',
                betType: BetType.leftDigit,
              ),
              const SizedBox(height: 20),

              _SectionLabel('Bahar / B'),
              const SizedBox(height: 8),

              // ── 10-cell Bahar grid (1–9, 0) ─────────────────────────────────
              _JantriGrid(
                count: 10,
                labelBuilder: (i) => i == 9 ? '0' : '${i + 1}',
                betNumberBuilder: (i) => i == 9 ? '0' : '${i + 1}',
                betType: BetType.rightDigit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Generic grid used for all three jantri sections
// ─────────────────────────────────────────────────────────────────────────────
class _JantriGrid extends StatelessWidget {
  final int count;
  final String Function(int index) labelBuilder;
  final String Function(int index) betNumberBuilder;
  final BetType betType;

  const _JantriGrid({
    required this.count,
    required this.labelBuilder,
    required this.betNumberBuilder,
    required this.betType,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const headerColor = Color(0xff56a6a6);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisExtent: 76,
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
      ),
      itemBuilder: (ctx, i) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header cell
            Container(
              width: double.infinity,
              height: 35,
              decoration: BoxDecoration(
                color: headerColor,
                border: Border.all(color: Colors.black, width: 0.5),
              ),
              alignment: Alignment.center,
              child: Text(
                labelBuilder(i),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            // Input cell
            Container(
              width: double.infinity,
              height: 35,
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.5),
                border: Border(
                  left: BorderSide(color: Colors.black.withOpacity(0.3)),
                  right: BorderSide(color: Colors.black.withOpacity(0.3)),
                  bottom: BorderSide(color: Colors.black.withOpacity(0.3)),
                ),
              ),
              child: TextFormField(
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                cursorHeight: 16,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.all(4),
                  border: InputBorder.none,
                  fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                  filled: true,
                ),
                onChanged: (value) {
                  ctx.read<GaliDesawarGameBloc>().add(UpdateJantriBetEvent(
                        betNumber: betNumberBuilder(i),
                        amountText: value,
                        betType: betType,
                      ));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
    );
  }
}
