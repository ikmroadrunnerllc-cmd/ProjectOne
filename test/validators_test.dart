import 'package:flutter_test/flutter_test.dart';
import 'package:movement_quest/helper/validators.dart';

void main() {
  group('validateReps', () {
    test('accepts whole numbers from 1 to 999', () {
      for (final raw in ['1', '12', ' 30 ', '999']) {
        expect(validateReps(raw), isNull, reason: raw);
      }
    });

    test('rejects blanks, zero, negatives, text and decimals', () {
      for (final raw in [null, '', '   ', '0', '-3', 'abc', '2.5', '1000']) {
        expect(validateReps(raw), isNotNull, reason: '$raw');
      }
    });
  });
}
