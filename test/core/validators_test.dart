import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('accepte une adresse valide', () {
      expect(Validators.email('client@soko.bi'), isNull);
    });

    test('refuse une adresse invalide', () {
      expect(Validators.email('pas-un-email'), Validators.kInvalidEmail);
    });

    test('refuse une adresse vide', () {
      expect(Validators.email('   '), Validators.kRequiredField);
    });
  });

  group('Validators.password', () {
    test('accepte 6 caractères ou plus', () {
      expect(Validators.password('secret123'), isNull);
    });

    test('refuse moins de 6 caractères', () {
      expect(Validators.password('abc'), Validators.kInvalidPassword);
    });
  });

  group('Validators.price', () {
    test('accepte un prix positif (virgule décimale tolérée)', () {
      expect(Validators.price('12,5'), isNull);
      expect(Validators.price('25000'), isNull);
    });

    test('refuse 0, un nombre négatif et du texte', () {
      expect(Validators.price('0'), Validators.kInvalidPrice);
      expect(Validators.price('-3'), Validators.kInvalidPrice);
      expect(Validators.price('abc'), Validators.kInvalidPrice);
    });
  });

  group('Validators.stock', () {
    test('accepte 0 et un entier positif', () {
      expect(Validators.stock('0'), isNull);
      expect(Validators.stock('42'), isNull);
    });

    test('refuse un nombre négatif et un décimal', () {
      expect(Validators.stock('-1'), Validators.kInvalidStock);
      expect(Validators.stock('2.5'), Validators.kInvalidStock);
    });
  });

  group('Validators.phone', () {
    test('accepte un numéro avec séparateurs', () {
      expect(Validators.phone('+257 79 12 34 56'), isNull);
    });

    test('refuse un numéro trop court', () {
      expect(Validators.phone('123'), Validators.kInvalidPhone);
    });
  });
}
