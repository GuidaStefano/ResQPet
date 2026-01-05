import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

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
  
  test('TC_RegCitt_1 - Errore email non valida', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Mario Rossi',
        email: 'emailnonvalida',
        password: 'Password123',
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

  test('TC_RegCitt_2 - Errore email già presente', () async {
    final repository = container.read(utenteRepositoryProvider);

    final mockAuth = container.read(firebaseAuthProvider) as MockFirebaseAuth;
    whenCalling(
      Invocation.method(
        #createUserWithEmailAndPassword,
        null,
        {
          #email: 'mario.rossi@example.com',
          #password: 'Password123',
        },
      ),
    )
    .on(mockAuth)
    .thenThrow(
      FirebaseAuthException(code: 'email-already-in-use'),
    );

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Mario Rossi',
        email: 'mario.rossi@example.com',
        password: 'Password123',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<FirebaseAuthException>()
          .having(
            (e) => e.code, 
            "code",
            "email-already-in-use"
          )
      ),
    );
  });

  test('TC_RegCitt_3 - Errore password troppo corta', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: 'Luca Rossi',
        email: 'luca@test.it',
        password: 'Pass1',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La password deve contenere almeno 8 caratteri',
        ),
      ),
    );
  });

  test('TC_RegCitt_4 - Errore nominativo vuoto', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraCittadino(
        nominativo: '',
        email: 'luca@test.it',
        password: 'Password123',
        numeroTelefono: '3331234567',
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il nominativo non può essere vuoto',
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
        password: 'Password123',
        numeroTelefono: '123456',
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
        password: 'Password123',
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