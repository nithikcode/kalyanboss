
// ─────────────────────────────────────────────────────────────────────────────
// UI strategy styles
// ─────────────────────────────────────────────────────────────────────────────
import 'package:kalyanboss/features/betting/utils/panna_validator.dart';

enum InputStyle {
  /// 0-9 tap grid (Single Digit, Odd-Even)
  gridStyle,

  /// Single TextField (Jodi = 2 digits, Panna = 3 digits)
  inputStyle,

  /// 10 always-visible rows, one per digit 0-9 (all BULK modes)
  bulkStyle,

  /// One text field for comma-separated pannas → auto-expand combinations
  motorStyle,

  /// Two fields: Digit + Panna  (Half Sangam) OR Panna + Panna (Full Sangam)
  sangamStyle,
}

// ─────────────────────────────────────────────────────────────────────────────
// Session options per game
// ─────────────────────────────────────────────────────────────────────────────
enum SessionType { open, close, both }

// ─────────────────────────────────────────────────────────────────────────────
// Immutable config object
// ─────────────────────────────────────────────────────────────────────────────
class GameTypeConfig {
  final InputStyle inputStyle;
  final PannaType pannaType;

  /// Number of digits expected in primary input (1, 2, or 3).
  final int digitCount;

  /// Human-readable hint shown below the input area.
  final String hint;

  /// Whether the game supports a second input (FULL SANGAM: panna + panna).
  final bool hasDualPanna;

  /// Whether session selector (OPEN/CLOSE) is relevant.
  final SessionType sessionType;

  const GameTypeConfig({
    required this.inputStyle,
    required this.hint,
    this.pannaType = PannaType.none,
    this.digitCount = 1,
    this.hasDualPanna = false,
    this.sessionType = SessionType.both,
  });

  // ── Factory ───────────────────────────────────────────────────────────────

  factory GameTypeConfig.fromGameName(String name) {
    switch (name.toUpperCase().trim()) {
      // ── DIGITS ──────────────────────────────────────────────────────────
      case 'SINGLE DIGIT':
        return const GameTypeConfig(
          inputStyle: InputStyle.gridStyle,
          digitCount: 1,
          hint: 'Tap a digit (0 – 9)',
        );

      case 'SINGLE DIGIT BULK':
        return const GameTypeConfig(
          inputStyle: InputStyle.bulkStyle,
          digitCount: 1,
          hint: 'Enter points for digits 0 – 9',
        );

      case 'JODI DIGIT':
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          digitCount: 2,
          hint: 'Enter 2-digit Jodi (00 – 99)',
        );

      case 'JODI DIGIT BULK':
        return const GameTypeConfig(
          inputStyle: InputStyle.bulkStyle,
          digitCount: 2,
          hint: 'Enter points for each Jodi (00 – 99)',
        );

      // ── SINGLE PANNA ────────────────────────────────────────────────────
      case 'SINGLE PANNA':
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          pannaType: PannaType.single,
          digitCount: 3,
          hint: 'Enter a valid Single Panna (3 digits, all different)',
        );

      case 'SINGLE PANNA BULK':
        return const GameTypeConfig(
          inputStyle: InputStyle.bulkStyle,
          pannaType: PannaType.single,
          digitCount: 3,
          hint: 'Enter points for each Single Panna row',
        );

      // ── DOUBLE PANNA ────────────────────────────────────────────────────
      case 'DOUBLE PANNA':
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          pannaType: PannaType.double,
          digitCount: 3,
          hint: 'Enter a valid Double Panna (exactly 2 same digits)',
        );

      case 'DOUBLE PANNA BULK':
        return const GameTypeConfig(
          inputStyle: InputStyle.bulkStyle,
          pannaType: PannaType.double,
          digitCount: 3,
          hint: 'Enter points for each Double Panna row',
        );

      // ── TRIPLE PANNA ────────────────────────────────────────────────────
      case 'TRIPLE PANNA':
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          pannaType: PannaType.triple,
          digitCount: 3,
          hint: 'Enter a Triple Panna (000, 111 … 999)',
        );

      case 'TRIPLE PANNA BULK':
        return const GameTypeConfig(
          inputStyle: InputStyle.bulkStyle,
          pannaType: PannaType.triple,
          digitCount: 3,
          hint: 'Enter points for each Triple Panna row',
        );

      // ── RED BRACKET ─────────────────────────────────────────────────────
      case 'RED BRAKET':
      case 'RED BRACKET':
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          pannaType: PannaType.any,
          digitCount: 3,
          hint: 'Enter any valid Panna for Red Bracket',
          sessionType: SessionType.open,
        );

      // ── ODD EVEN ────────────────────────────────────────────────────────
      case 'ODD EVEN':
        return const GameTypeConfig(
          inputStyle: InputStyle.gridStyle,
          digitCount: 1,
          hint: 'Tap Odd (1,3,5,7,9) or Even (0,2,4,6,8) digit',
        );

      // ── MOTOR ───────────────────────────────────────────────────────────
      case 'SP MOTOR':
        return const GameTypeConfig(
          inputStyle: InputStyle.motorStyle,
          pannaType: PannaType.single,
          digitCount: 3,
          hint: 'Type 3-digit Single Pannas separated by commas  e.g. 123, 456',
        );

      case 'DP MOTOR':
        return const GameTypeConfig(
          inputStyle: InputStyle.motorStyle,
          pannaType: PannaType.double,
          digitCount: 3,
          hint: 'Type 3-digit Double Pannas separated by commas  e.g. 112, 334',
        );

      case 'TP MOTOR':
        return const GameTypeConfig(
          inputStyle: InputStyle.motorStyle,
          pannaType: PannaType.triple,
          digitCount: 3,
          hint: 'Type Triple Pannas separated by commas  e.g. 111, 222',
        );

      // ── SANGAM ──────────────────────────────────────────────────────────
      case 'HALF SANGAM':
        return const GameTypeConfig(
          inputStyle: InputStyle.sangamStyle,
          pannaType: PannaType.single,
          digitCount: 3,
          hint: 'Enter Open Digit (0-9) + Single Panna',
          sessionType: SessionType.open,
        );

      case 'FULL SANGAM':
        return const GameTypeConfig(
          inputStyle: InputStyle.sangamStyle,
          pannaType: PannaType.any,
          digitCount: 3,
          hasDualPanna: true,
          hint: 'Enter Open Panna + Close Panna',
          sessionType: SessionType.both,
        );

      default:
        return const GameTypeConfig(
          inputStyle: InputStyle.inputStyle,
          digitCount: 1,
          hint: 'Enter your bet',
        );
    }
  }
}
