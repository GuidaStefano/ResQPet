import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';

import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(
      overrides: getRiverpodConfig(),
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('TC_RegCitt_1 - Errore nominativo troppo corto', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Lu',
        email: 'luca@test.it',
        password: 'Password123!',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Il nominativo deve essere tra 3 e 50 caratteri'),
        ),
      ),
    );
  });

  test('TC_RegCitt_2 - Errore nominativo troppo lungo', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'L' * 60,
        email: 'luca@test.it',
        password: 'Password123!',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Il nominativo deve essere tra 3 e 50 caratteri'),
        ),
      ),
    );
  });

  test('TC_RegCitt_3 - Errore email non valida', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Luca Rossi',
        email: 'luca.test.it',
        password: 'Password123!',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Email non valida',
        ),
      ),
    );
  });

  test('TC_RegCitt_4 - Errore password troppo debole', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Luca Rossi',
        email: 'luca@test.it',
        password: '123',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('La password deve contenere'),
        ),
      ),
    );
  });

  test('TC_RegCitt_5 - Errore numero di telefono non valido', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Luca Rossi',
        email: 'luca@test.it',
        password: 'Password123!',
        numeroTelefono: '33A123',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Numero di telefono non valido',
        ),
      ),
    );
  });

  test('TC_RegCitt_6 - Registrazione cittadino avvenuta con successo', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Luca Rossi',
        email: 'luca@test.it',
        password: 'Password123!',
        numeroTelefono: '3331234567',
      ),
      completes,
    );

    final snapshot = await container
        .read(firebaseFirestoreProvider)
        .collection('utenti')
        .where('email', isEqualTo: 'luca@test.it')
        .get();

    expect(snapshot.docs.isNotEmpty, true);
  });
}
