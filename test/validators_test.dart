import 'package:flutter_test/flutter_test.dart';
import 'package:fixpair/core/utils/validators.dart';

void main() {
  group('Validators.password', () {
    test('should validate empty or null values', () {
      expect(Validators.password(null), equals('Password is required'));
      expect(Validators.password(''), equals('Password is required'));
      expect(Validators.password('   '), equals('Password is required'));
    });

    test('should validate default weak parameters (minLength=6)', () {
      expect(
        Validators.password('12345'),
        equals('Password must be at least 6 characters'),
      );
      expect(Validators.password('123456'), isNull);
    });

    test('should validate strong password policy', () {
      // Too short
      expect(
        Validators.password(
          'Ab1!',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        equals('Password must be at least 8 characters'),
      );

      // No digit
      expect(
        Validators.password(
          'Abcdefgh!',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        equals('Password must contain at least one number'),
      );

      // No uppercase
      expect(
        Validators.password(
          'abcdefgh1!',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        equals('Password must contain at least one uppercase letter'),
      );

      // No lowercase
      expect(
        Validators.password(
          'ABCDEFGH1!',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        equals('Password must contain at least one lowercase letter'),
      );

      // No special char
      expect(
        Validators.password(
          'Abcdefgh1',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        equals('Password must contain at least one special character'),
      );

      // Valid strong password
      expect(
        Validators.password(
          'Abcdefgh1!',
          minLength: 8,
          requireDigit: true,
          requireUppercase: true,
          requireLowercase: true,
          requireSpecialChar: true,
        ),
        isNull,
      );
    });
  });
}
