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
  
  test('TC_RegEnte_1 - Errore email non valida', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Nuovo Ente',
        email: 'emailnonvalida@',
        password: 'PasswordSicura1',
        numeroTelefono: '3331234567',
        sedeLegale: 'Via Napoli 20, Roma',
        partitaIVA: '10987654321'
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

  test('TC_RegEnte_2 - Errore email già presente', () async {
    final repository = container.read(utenteRepositoryProvider);

    final mockAuth = container.read(firebaseAuthProvider) as MockFirebaseAuth;
    whenCalling(
      Invocation.method(
        #createUserWithEmailAndPassword,
        null,
        {
          #email: 'fpet@gmail.com',
          #password: 'PasswordSicura1',
        },
      ),
    )
    .on(mockAuth)
    .thenThrow(
      FirebaseAuthException(
        code: 'email-already-in-use'
      ),
    );

    await expectLater(
      repository.registraEnte(
        nominativo: 'Ente Protezione',
        email: 'fpet@gmail.com',
        password: 'PasswordSicura1',
        numeroTelefono: '3339876543',
        sedeLegale: 'Via Roma 10, Milano',
        partitaIVA: '12345678901'
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

  test('TC_RegEnte_3 - Errore password troppo corta', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Evviva I Cani YE',
        email: 'nuovo@ente.it',
        password: 'Pass1',
        numeroTelefono: '3331122334',
        partitaIVA: '11223344556',
        sedeLegale: 'Piazza Garibaldi 1 , Verona'
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

  test('TC_RegEnte_4 - Errore nominativo vuoto', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: '',
        email: 'ente@test.it',
        password: 'Password123',
        numeroTelefono: '3331234567',
        sedeLegale: 'Via Verdi 5, Torino',
        partitaIVA: '00000000001'
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

  test('TC_RegEnte_5 - Errore numero di telefono non valido', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Ente Telefono',
        email: 'ente@telefono.it',
        password: 'Password123',
        numeroTelefono: '36727839483',
        sedeLegale: 'Via Milano 2 , Venezia',
        partitaIVA: '00000000002'
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

  test('TC_RegEnte_6 - Errore sede legale vuota', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Ente Senza Sede',
        email: 'ente@sede.it',
        password: '3334445556',
        numeroTelefono: '3331234567',
        sedeLegale: '',
        partitaIVA: '00000000003'
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La sede legale non può essere vuota',
        ),
      ),
    );
  });

  test('TC_RegEnte_7 - Errore partita IVA non valida', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Ente Piva Errata',
        email: 'ente@piva.it',
        password: 'Password123',
        numeroTelefono: '3334445556',
        sedeLegale: 'Via Lunga 10, Fisciano',
        partitaIVA: '12345'
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Partita IVA non valida',
        ),
      ),
    );
  });

  test('TC_RegEnte_8 - Registrazione di un Ente avvenuta con successo', () async {
    final repository = container.read(utenteRepositoryProvider);

    await expectLater(
      repository.registraEnte(
        nominativo: 'Ente Valido',
        email: 'valid.ente@example.com',
        password: 'SecurePass2025',
        numeroTelefono: '3331234567',
        sedeLegale: 'Via della Validità 100, Roma',
        partitaIVA: '12345678928'
      ),
      completes,
    );

    final snapshot = await container
        .read(firebaseFirestoreProvider)
        .collection('utenti')
        .where('email', isEqualTo: 'valid.ente@example.com')
        .get();

    expect(snapshot.docs.isNotEmpty, true);
  });
}