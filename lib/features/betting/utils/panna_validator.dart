/// PannaValidator
/// Mathematical rules for Satta Matka panna validation.
/// SP = all 3 digits different | DP = exactly 2 same | TP = all 3 same
library panna_validator;

enum PannaType { none, single, double, triple, any }

class PannaValidator {
  PannaValidator._();

  // ── Lazy-initialised sets ──────────────────────────────────────────────────

  static late final Set<String> _singlePannas = _buildSinglePannas();
  static late final Set<String> _doublePannas = _buildDoublePannas();
  static const Set<String> triplePannas = {
    '000', '111', '222', '333', '444',
    '555', '666', '777', '888', '999',
  };

  static Set<String> _buildSinglePannas() {
    final result = <String>{};
    for (int i = 0; i <= 999; i++) {
      final s = i.toString().padLeft(3, '0');
      final d = s.split('');
      if (d[0] != d[1] && d[1] != d[2] && d[0] != d[2]) result.add(s);
    }
    return result;
  }

  static Set<String> _buildDoublePannas() {
    final result = <String>{};
    for (int i = 0; i <= 999; i++) {
      final s = i.toString().padLeft(3, '0');
      final counts = <String, int>{};
      for (final c in s.split('')) counts[c] = (counts[c] ?? 0) + 1;
      if (counts.values.contains(2) && counts.values.contains(1)) result.add(s);
    }
    return result;
  }

  // ── Public validators ──────────────────────────────────────────────────────

  static bool isValidSinglePanna(String v) =>
      v.length == 3 && _singlePannas.contains(v);

  static bool isValidDoublePanna(String v) =>
      v.length == 3 && _doublePannas.contains(v);

  static bool isValidTriplePanna(String v) =>
      v.length == 3 && triplePannas.contains(v);

  static bool isValidAnyPanna(String v) =>
      isValidSinglePanna(v) || isValidDoublePanna(v) || isValidTriplePanna(v);

  static bool isValidForType(String v, PannaType type) {
    switch (type) {
      case PannaType.single:
        return isValidSinglePanna(v);
      case PannaType.double:
        return isValidDoublePanna(v);
      case PannaType.triple:
        return isValidTriplePanna(v);
      case PannaType.any:
        return isValidAnyPanna(v);
      case PannaType.none:
        return true;
    }
  }

  /// Sum of digits mod 10 → root digit (Ank).
  static int? getRootDigit(String panna) {
    if (panna.length != 3) return null;
    return panna.split('').map(int.parse).reduce((a, b) => a + b) % 10;
  }

  // ── Motor expansion ────────────────────────────────────────────────────────

  /// All unique permutations of a 3-char string.
  static Set<String> _permutations(String s) {
    assert(s.length == 3);
    final d = s.split('');
    return {
      '${d[0]}${d[1]}${d[2]}', '${d[0]}${d[2]}${d[1]}',
      '${d[1]}${d[0]}${d[2]}', '${d[1]}${d[2]}${d[0]}',
      '${d[2]}${d[0]}${d[1]}', '${d[2]}${d[1]}${d[0]}',
    };
  }

  /// Expand comma-separated motor input into valid pannas of the given type.
  /// e.g. "123" → ["123","132","213","231","312","321"] filtered by SP rules.
  static List<String> expandMotorInput(String raw, PannaType pannaType) {
    final seen = <String>{};
    final result = <String>[];

    for (final part in raw.split(',').map((e) => e.trim())) {
      if (part.length != 3 || !RegExp(r'^\d{3}$').hasMatch(part)) continue;
      for (final perm in _permutations(part)) {
        if (seen.contains(perm)) continue;
        if (isValidForType(perm, pannaType)) {
          seen.add(perm);
          result.add(perm);
        }
      }
    }
    return result;
  }

  // ── Bulk digit sets ────────────────────────────────────────────────────────

  /// Returns sorted list of all valid pannas for a given type (used in bulk grids).
  static List<String> allPannasForType(PannaType type) {
    switch (type) {
      case PannaType.single:
        return _singlePannas.toList()..sort();
      case PannaType.double:
        return _doublePannas.toList()..sort();
      case PannaType.triple:
        return triplePannas.toList()..sort();
      case PannaType.any:
        return [
          ..._singlePannas,
          ..._doublePannas,
          ...triplePannas,
        ]..sort();
      case PannaType.none:
        return [];
    }
  }

  // ── Jodi helpers ───────────────────────────────────────────────────────────

  static bool isValidJodi(String v) =>
      v.length == 2 && RegExp(r'^\d{2}$').hasMatch(v);

  static bool isValidSingleDigit(String v) =>
      v.length == 1 && RegExp(r'^\d$').hasMatch(v);
}
