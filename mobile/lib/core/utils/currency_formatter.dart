import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Format angka ke format mata uang Rupiah (contoh: 25000 -> Rp 25.000)
  static String format(num? amount) {
    if (amount == null) return 'Rp 0';
    return _formatter.format(amount);
  }

  /// Alias formatRupiah
  static String formatRupiah(num? amount) => format(amount);

  /// Format angka tanpa prefix simbol "Rp" (contoh: 25000 -> 25.000)
  static String formatNumber(num? amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount);
  }
}
