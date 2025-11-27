// Save this as: lib/core/utils/number_utils.dart

/// Utility class for safe number conversions
class NumberUtils {
  /// Safely converts any dynamic value to double
  /// Handles: null, int, double, String
  /// Returns 0.0 if conversion fails
  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        // Handle empty strings or invalid formats
        return 0.0;
      }
    }
    return 0.0;
  }

  /// Safely converts any dynamic value to int
  /// Handles: null, int, double, String
  /// Returns 0 if conversion fails
  static int toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        // Try parsing as double first, then convert to int
        try {
          return double.parse(value).toInt();
        } catch (e2) {
          return 0;
        }
      }
    }
    return 0;
  }

  /// Format number as currency with 2 decimal places
  static String formatCurrency(dynamic value, {String symbol = 'DA'}) {
    final amount = toDouble(value);
    return '${amount.toStringAsFixed(2)} $symbol';
  }

  /// Format number with custom decimal places
  static String formatNumber(dynamic value, {int decimals = 2}) {
    final number = toDouble(value);
    return number.toStringAsFixed(decimals);
  }

  /// Check if value is a valid number
  static bool isValidNumber(dynamic value) {
    if (value == null) return false;
    if (value is num) return true;
    if (value is String) {
      try {
        double.parse(value);
        return true;
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}

/// Extension methods for easier usage
extension NumberExtensions on dynamic {
  double toDoubleOrZero() => NumberUtils.toDouble(this);
  int toIntOrZero() => NumberUtils.toInt(this);
  String toCurrency({String symbol = 'DA'}) => NumberUtils.formatCurrency(this, symbol: symbol);
}