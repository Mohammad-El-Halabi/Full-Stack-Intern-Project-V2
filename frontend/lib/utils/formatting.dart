import 'package:intl/intl.dart';

final NumberFormat _currency = NumberFormat.currency(symbol: '\$');
final DateFormat _dateTime = DateFormat('yyyy-MM-dd HH:mm');

String money(num value) => _currency.format(value);

String formatDate(DateTime? dt) => dt == null ? '-' : _dateTime.format(dt.toLocal());
