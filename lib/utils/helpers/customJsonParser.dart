import 'dart:convert';

import 'helpers.dart'; // Or your logging function import

extension JsonMapParser on Map<String, dynamic> {
  T? parse<T>(String key) {
    final value = this[key];
    if (value == null) return null;

    try {
      final type = T.toString();

      // Handle String / String?
      if (type == 'String' || type == 'String?') {
        if (value is String) return value as T;
        return value.toString() as T;
      }

      // Handle int / int?
      if (type == 'int' || type == 'int?') {
        if (value is int) return value as T;
        if (value is double) return value.toInt() as T;
        if (value is String) {
          final parsed = int.tryParse(value);
          if (parsed != null) return parsed as T;
        }
      }

      // Handle double / double?
      if (type == 'double' || type == 'double?') {
        if (value is double) return value as T;
        if (value is int) return value.toDouble() as T;
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed as T;
        }
      }

      // Handle bool / bool?
      if (type == 'bool' || type == 'bool?') {
        if (value is bool) return value as T;
        if (value is int) return (value != 0) as T;
        if (value is String) {
          final lower = value.toLowerCase();
          if (['true', 'yes', '1'].contains(lower)) return true as T;
          if (['false', 'no', '0'].contains(lower)) return false as T;
        }
      }
    } catch (e) {
      createLog(
        "[JsonParser Error] Failed parsing key: $key, value: $value, type: ${T.toString()}, error: $e",
      );
      return null;
    }

    // Log only if parsing actually failed
    createLog(
      "[JsonParser Warning] Could not parse key: $key, value: $value, expected type: ${T.toString()}",
    );
    return null;
  }



  /// Parse a nested object from a map key.
  T? parseNested<T>(String key, T Function(Map<String, dynamic>) parser) {
    final value = this[key];
    try {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return parser(value);
      if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is Map<String, dynamic>) return parser(decoded);
      }
    } catch (e) {
      createLog("[JsonParser Error] Failed nested parsing key: $key, value: $value, error: $e");
    }
    return null;
  }

  /// Parse a list of objects from a map key.
  List<T>? parseListOf<T>(String key, T Function(dynamic) parser) {
    final value = this[key];
    try {
      if (value == null) return null;
      final list = <T>[];

      List<dynamic> sourceList = [];
      if (value is List) {
        sourceList = value;
      } else if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          sourceList = decoded;
        }
      }

      for (final e in sourceList) {
        try {
          final parsed = parser(e);
          // Assuming parser returns T, not T?
          list.add(parsed);
        } catch (e) {
          createLog("[JsonParser Error] Failed parsing list element key: $key, element: $e, error: $e");
        }
      }
      return list.isEmpty ? null : list;
    } catch (e) {
      createLog("[JsonParser Error] Failed parsing list key: $key, value: $value, error: $e");
      return null;
    }
  }
}