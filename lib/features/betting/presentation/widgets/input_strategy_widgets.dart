import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_event.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_state.dart';
import 'package:kalyanboss/features/betting/utils/panna_validator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY 1 — Grid Style (Single Digit, Odd-Even)
// ─────────────────────────────────────────────────────────────────────────────
class GridStyleInput extends StatefulWidget {
  const GridStyleInput({super.key});

  @override
  State<GridStyleInput> createState() => _GridStyleInputState();
}

class _GridStyleInputState extends State<GridStyleInput> {
  final _pointsCtrl = TextEditingController();
  String? _selected;

  @override
  void dispose() {
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _submit(GameReadyData data) {
    final pts = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    if (_selected == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Tap a digit first')));
      return;
    }
    context.read<UnifiedGameBloc>().add(AddSingleBetEvent(
      openValue: _selected!,
      closeValue: '',
      points: pts,
      session: data.currentSession,
    ));
    _pointsCtrl.clear();
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Digit grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (_, i) {
                final d = i.toString();
                final selected = _selected == d;
                return GestureDetector(
                  onTap: () => setState(() => _selected = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                      border: selected
                          ? null
                          : Border.all(color: Theme.of(context).dividerColor),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: selected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _PointsRow(
              controller: _pointsCtrl,
              onAdd: () => _submit(data),
              selectedLabel: _selected != null ? 'Digit: $_selected' : null,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY 2 — Input Style (Jodi / Panna single entry)
// ─────────────────────────────────────────────────────────────────────────────
class InputStyleInput extends StatefulWidget {
  const InputStyleInput({super.key});

  @override
  State<InputStyleInput> createState() => _InputStyleInputState();
}

class _InputStyleInputState extends State<InputStyleInput> {
  final _digitCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  @override
  void dispose() {
    _digitCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _submit(GameReadyData data) {
    final pts = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    context.read<UnifiedGameBloc>().add(AddSingleBetEvent(
      openValue: _digitCtrl.text.trim(),
      closeValue: '',
      points: pts,
      session: data.currentSession,
    ));
    _digitCtrl.clear();
    _pointsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        final config = data.config;
        return Column(
          children: [
            _BetTextField(
              controller: _digitCtrl,
              label: config.digitCount == 2 ? 'Jodi (00–99)' : 'Panna (000–999)',
              maxLength: config.digitCount,
              hint: '0' * config.digitCount,
            ),
            const SizedBox(height: 12),
            _PointsRow(
              controller: _pointsCtrl,
              onAdd: () => _submit(data),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY 3 — Bulk Style (10 always-visible rows)
// ─────────────────────────────────────────────────────────────────────────────
class BulkStyleInput extends StatefulWidget {
  const BulkStyleInput({super.key});

  @override
  State<BulkStyleInput> createState() => _BulkStyleInputState();
}

class _BulkStyleInputState extends State<BulkStyleInput> {
  late Map<String, TextEditingController> _rows;
  bool _rowsBuilt = false;

  void _buildRows(GameReadyData data) {
    if (_rowsBuilt) return;
    _rowsBuilt = true;

    final config = data.config;
    List<String> keys;

    if (config.digitCount == 1) {
      keys = List.generate(10, (i) => i.toString());
    } else if (config.digitCount == 2) {
      keys = List.generate(100, (i) => i.toString().padLeft(2, '0'));
    } else {
      final pannas = PannaValidator.allPannasForType(config.pannaType);
      keys = pannas.take(120).toList();
    }

    _rows = {for (final k in keys) k: TextEditingController()};
  }

  @override
  void dispose() {
    _rows.forEach((_, c) => c.dispose());
    super.dispose();
  }

  void _submitAll(GameReadyData data) {
    final entries = <String, int>{};
    _rows.forEach((key, ctrl) {
      final v = int.tryParse(ctrl.text.trim()) ?? 0;
      if (v > 0) entries[key] = v;
    });
    context.read<UnifiedGameBloc>().add(
        AddBulkBetsEvent(entries: entries, session: data.currentSession));
    for (final c in _rows.values) c.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        _buildRows(data);

        return Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.separated(
                itemCount: _rows.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final key = _rows.keys.elementAt(i);
                  return Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          key,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: _BetTextField(
                          controller: _rows[key]!,
                          label: 'Points',
                          maxLength: 6,
                          hint: '0',
                          isNumeric: true,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _submitAll(data),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Add All to Cart'),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY 4 — Motor Style (auto-generate combinations)
// ─────────────────────────────────────────────────────────────────────────────
class MotorStyleInput extends StatefulWidget {
  const MotorStyleInput({super.key});

  @override
  State<MotorStyleInput> createState() => _MotorStyleInputState();
}

class _MotorStyleInputState extends State<MotorStyleInput> {
  final _pannaCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();
  List<String> _preview = [];

  void _updatePreview(PannaType type) {
    setState(() {
      _preview = PannaValidator.expandMotorInput(_pannaCtrl.text, type);
    });
  }

  @override
  void dispose() {
    _pannaCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _submit(GameReadyData data) {
    final pts = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    context.read<UnifiedGameBloc>().add(AddMotorBetsEvent(
      rawInput: _pannaCtrl.text,
      pointsPerCombo: pts,
      session: data.currentSession,
    ));
    _pannaCtrl.clear();
    _pointsCtrl.clear();
    setState(() => _preview = []);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        final config = data.config;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _pannaCtrl,
              decoration: InputDecoration(
                labelText: 'Enter Pannas (comma-separated)',
                hintText: 'e.g. 123, 456, 789',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Preview combos',
                  onPressed: () => _updatePreview(config.pannaType),
                ),
              ),
              onChanged: (_) => _updatePreview(config.pannaType),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d,\s]'))
              ],
            ),

            // Live preview chip strip
            if (_preview.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '${_preview.length} combos generated:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _preview
                    .take(30)
                    .map((p) => Chip(
                  label: Text(p),
                  visualDensity: VisualDensity.compact,
                  backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
                ))
                    .toList(),
              ),
              if (_preview.length > 30)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '+ ${_preview.length - 30} more…',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],

            const SizedBox(height: 12),
            _PointsRow(
              controller: _pointsCtrl,
              onAdd: () => _submit(data),
              selectedLabel: _preview.isNotEmpty
                  ? 'Per combo — Total: ₹${(int.tryParse(_pointsCtrl.text.trim()) ?? 0) * _preview.length}'
                  : null,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY 5 — Sangam Style (Digit+Panna or Panna+Panna)
// ─────────────────────────────────────────────────────────────────────────────
class SangamStyleInput extends StatefulWidget {
  const SangamStyleInput({super.key});

  @override
  State<SangamStyleInput> createState() => _SangamStyleInputState();
}

class _SangamStyleInputState extends State<SangamStyleInput> {
  final _openCtrl = TextEditingController();
  final _closeCtrl = TextEditingController();
  final _pointsCtrl = TextEditingController();

  @override
  void dispose() {
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  void _submit(GameReadyData data) {
    final pts = int.tryParse(_pointsCtrl.text.trim()) ?? 0;
    context.read<UnifiedGameBloc>().add(AddSingleBetEvent(
      openValue: _openCtrl.text.trim(),
      closeValue: _closeCtrl.text.trim(),
      points: pts,
      session: data.currentSession,
    ));
    _openCtrl.clear();
    _closeCtrl.clear();
    _pointsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UnifiedGameBloc, UnifiedGameState>(
      buildWhen: (previous, current) =>
      current.gameState != previous.gameState,
      builder: (ctx, state) {
        final data = state.gameState.dataOrNull;
        if (data == null) return const SizedBox.shrink();

        final config = data.config;
        final isFullSangam = config.hasDualPanna;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _BetTextField(
                    controller: _openCtrl,
                    label: isFullSangam ? 'Open Panna' : 'Open Digit',
                    maxLength: isFullSangam ? 3 : 1,
                    hint: isFullSangam ? '123' : '5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BetTextField(
                    controller: _closeCtrl,
                    label: 'Close Panna',
                    maxLength: 3,
                    hint: '456',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PointsRow(
              controller: _pointsCtrl,
              onAdd: () => _submit(data),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared UI helpers (private to this file)
// ─────────────────────────────────────────────────────────────────────────────

class _BetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLength;
  final bool isNumeric;

  const _BetTextField({
    required this.controller,
    required this.label,
    required this.maxLength,
    this.hint = '',
    this.isNumeric = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        counterText: '',
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onAdd;
  final String? selectedLabel;

  const _PointsRow({
    required this.controller,
    required this.onAdd,
    this.selectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (selectedLabel != null) ...[
          Expanded(
            flex: 2,
            child: Text(
              selectedLabel!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: _BetTextField(
            controller: controller,
            label: 'Points',
            maxLength: 7,
            hint: '100',
            isNumeric: true,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: onAdd,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
          child: const Text('Add'),
        ),
      ],
    );
  }
}