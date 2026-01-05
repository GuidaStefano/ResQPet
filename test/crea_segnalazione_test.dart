import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';

import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(overrides: getRiverpodConfig());

    final userCredential = await container
        .read(firebaseAuthProvider)
        .signInWithEmailAndPassword(
          email: 'mockuser@resqpet.it',
          password: 'ResQPet',
        );

    final userUID = userCredential.user!.uid;

    await container
        .read(firebaseFirestoreProvider)
        .collection('utenti')
        .doc(userUID)
        .set({
          'nominativo': 'Mario Rossi',
          'email': 'mockuser@resqpet.it',
          'dataCreazione': Timestamp.now(),
          'numeroTelefono': '3331234567',
        });
  });

  tearDown(() {
    container.dispose();
  });

  // TC_CreaSegna_1
  test('TC_CreaSegna_1 - Successo: l’operazione viene eseguita correttamente',() async {
      final repository = container.read(segnalazioneRepositoryProvider);

      await expectLater(
        repository.creaSegnalazione(
          descrizione:
              'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
          latitudine: 40.7750,
          longitudine: 14.7890,
          indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
          foto: [File('img1.jpg'), File('img2.jpg')],
        ),
        completes,
      );
    },
  );


  test('TC_CreaSegna_2 - Errore: utente non loggato', () async {
    await container.read(firebaseAuthProvider).signOut();

    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('img1.jpg')],
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          'L\'utente deve essere autenticato per poter aprire una segnalazione',
        ),
      ),
    );
  });

  test('TC_CreaSegna_3 - Errore: la descrizione non è valida (vuota)', () async {
      final repository = container.read(segnalazioneRepositoryProvider);

      await expectLater(
        repository.creaSegnalazione(
          descrizione: '', 
          latitudine: 100.50, 
          longitudine: 14.7890,
          indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
          foto: [File('img1.jpg')],
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'La descrizione non può essere vuota',
          ),
        ),
      );
    },
  );

  test('TC_CreaSegna_4 - Errore: indirizzo non valido (vuoto)', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 14.775,
        indirizzo: '', 
        foto: [File('img1.jpg')],
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'L\'indirizzo non può essere vuoto',
        ),
      ),
    );
  });

  test('TC_CreaSegna_5 - Errore: latitudine > 90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 91.7750, 
        longitudine: 14.7890,
        indirizzo: 'Via Roma 11 Fisciano (SA)',
        foto: [File('img1.jpg')],
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La latitudine è fuori range',
        ),
      ),
    );
  });

  test('TC_creaSegn_6 - Errore: latitudine < -90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: -91.0, 
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('img1.jpg')],
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La latitudine è fuori range',
        ),
      ),
    );
  });

  test('TC_CreaSegna_7 - Errore: Longitudine > 180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 181.0, 
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('documento.pdf')],
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La longitudine è fuori range',
        ),
      ),
    );
  });

  test('TC_CreaSegna_8 - Errore: Longitudine < -180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: -181.0, 
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('documento.jpg')],
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La longitudine è fuori range',
        ),
      ),
    );
  });

  test('TC_CreaSegna_9 - Errore: nessuna foto disponibile', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [], 
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Deve essere fornita almeno una foto',
        ),
      ),
    );
  });

  test('TC_CreaSegna_10 - Errore: foto formato non valido', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('img1.png'), File('img2.png')], 
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Tutte le foto devono essere in formato JPEG',
        ),
      ),
    );
  });
}
