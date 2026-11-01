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

  group('validateWeight', () {
    test('accepts blank for bodyweight and numbers up to 2000', () {
      for (final raw in [null, '', '  ', '45', '2.5', ' 135 ', '2000']) {
        expect(validateWeight(raw), isNull, reason: '$raw');
      }
    });

    test('rejects zero, negatives, text and anything over 2000', () {
      for (final raw in ['0', '-5', 'heavy', '2000.5', '1e9']) {
        expect(validateWeight(raw), isNotNull, reason: raw);
      }
    });

    test('formats whole pounds without a decimal', () {
      expect(formatWeight(135), '135');
      expect(formatWeight(2.5), '2.5');
      expect(parseWeight(' '), isNull);
      expect(parseWeight('137.5'), 137.5);
    });
  });
}
