import 'package:number_to_words/number_to_words.dart';
import 'package:intl/intl.dart';
import 'package:string_extensions/string_extensions.dart';

String decimalToWord(double number) {
  String word = "";
  String numberString = formatNumber(number);
  int decimalIndex = numberString.indexOf(".");
  String decimalString = numberString.substring(decimalIndex + 1);
  int decimal = int.parse(decimalString);
  int wholeNumber = number.toInt();
  word += NumberToWord().convert('en-in', wholeNumber);
  if (decimal > 0) {
    word += ("and ${NumberToWord().convert('en-in', decimal)}fils");
  }
  return 'AED: ${word.toTitleCase!}';
}

String formatNumber(double number) {
  return NumberFormat("#,##0.00", "en_US").format(number);
}
