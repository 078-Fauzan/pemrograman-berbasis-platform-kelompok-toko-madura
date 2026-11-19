import 'package:intl/intl.dart';

class DateFormatter {
  /// Format tanggal Indonesia: DD-MM-YYYY (contoh: 31-10-2026)
  static String formatShort(dynamic date) {
    final parsed = _parseDate(date);
    if (parsed == null) return '-';
    return DateFormat('dd-MM-yyyy').format(parsed);
  }

  /// Format tanggal Indonesia lengkap: 31 Oktober 2026
  static String formatFull(dynamic date) {
    final parsed = _parseDate(date);
    if (parsed == null) return '-';
    return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
  }

  /// Format tanggal dan waktu: 31 Okt 2026, 14:30 WIB
  static String formatWithTime(dynamic date) {
    final parsed = _parseDate(date);
    if (parsed == null) return '-';
    final dateStr = DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(parsed);
    return '$dateStr WIB';
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
