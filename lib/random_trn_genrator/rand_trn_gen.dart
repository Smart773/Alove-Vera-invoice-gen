import 'package:intl/intl.dart';

class UniqeTrnGenerator {
  late String _trn;

  UniqeTrnGenerator() {
    _trn = randTRNGenerator();
  }

  String formatNumber(int number, String formats) {
    NumberFormat format = NumberFormat(formats);
    return format.format(number).toString();
  }

  String randTRNGenerator() {
    _trn = '';
    DateTime now = DateTime.now();
    String year = now.year.toString();
    String month = formatNumber(now.month, '00');
    String day = formatNumber(now.day, '00');
    String hour = formatNumber(now.hour, '00');
    String minute = formatNumber(now.minute, '00');
    String second = formatNumber(now.second, '00');
    String millisecond = formatNumber(now.millisecond, '000').substring(1);
    _trn = year + month + day + hour + minute + second + millisecond;
    return _trn;
  }

  String getTrn() {
    return _trn;
  }
}
