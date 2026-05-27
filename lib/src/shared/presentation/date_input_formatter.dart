import 'package:flutter/services.dart';

class DateInputFormatter extends TextInputFormatter {
  const DateInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsBeforeSelection = _digitsBefore(
      newValue.text,
      newValue.selection.baseOffset,
    );
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digits.length > 8 ? digits.substring(0, 8) : digits;
    final formatted = _formatDigits(limitedDigits);
    final offset = _offsetForDigitCount(formatted, digitsBeforeSelection);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }

  int _digitsBefore(String text, int selectionOffset) {
    final safeOffset = selectionOffset.clamp(0, text.length);
    return text
        .substring(0, safeOffset)
        .replaceAll(RegExp(r'\D'), '')
        .length
        .clamp(0, 8);
  }

  String _formatDigits(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2 || i == 4) {
        buffer.write('.');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  int _offsetForDigitCount(String formatted, int digitCount) {
    if (digitCount <= 0) {
      return 0;
    }

    var seenDigits = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        seenDigits++;
      }
      if (seenDigits == digitCount) {
        return i + 1;
      }
    }
    return formatted.length;
  }
}
