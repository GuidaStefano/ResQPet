import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
// Assicurati di importare il modello Segnalazione se necessario, anche se qui testiamo il repo
// import 'package:resqpet/models/segnalazione.dart';

import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(overrides: getRiverpodConfig());

    // Setup: Creazione utente e Login simulato (necessario per la maggior parte dei test)
    // Questo soddisfa la precondizione del TCS: "Il cittadino è loggato"
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
          'ruolo': 'cittadino', // Ipotizzo un campo ruolo
        });
  });

  tearDown(() {
    container.dispose();
  });

  // TC_CreaSegna_1
  test(
    'TC_CreaSegna_1 - Successo: l’operazione viene eseguita correttamente',
    () async {
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

  // TC_CreaSegna_2
  test('TC_CreaSegna_2 - Errore: utente non loggato', () async {
    // Disconnettiamo l'utente creato nel setUp per simulare questo scenario
    await container.read(firebaseAuthProvider).signOut();

    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione:
            'Trovato meticcio ferito sul ciglio della strada, sembra spaventato',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('img1.jpg')],
      ),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains("L'utente deve essere autenticato"),
        ),
      ),
    );
  });

  // TC_CreaSegna_3
  test(
    'TC_CreaSegna_3 - Errore: la descrizione non è valida (vuota)',
    () async {
      final repository = container.read(segnalazioneRepositoryProvider);

      await expectLater(
        repository.creaSegnalazione(
          descrizione: '', // Descrizione vuota
          latitudine:
              40.7750, // Uso coordinate valide per isolare l'errore descrizione
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

  // TC_CreaSegna_4
  test('TC_CreaSegna_4 - Errore: indirizzo non valido (vuoto)', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: '', // Indirizzo vuoto
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

  // TC_CreaSegna_5
  test('TC_CreaSegna_5 - Errore: latitudine > 90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 91.7750, // Latitudine non valida
        longitudine: 14.7890,
        indirizzo: 'Via Roma 11 – Fisciano (SA)',
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

  // TC_CreaSegna_6
  test('TC_creaSegn_6 - Errore: latitudine < -90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: -91.0, // Latitudine non valida
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

  // TC_CreaSegna_7
  test('TC_CreaSegna_7 - Errore: Longitudine > 180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 40.7750,
        longitudine: 181.0, // Longitudine non valida
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

  // TC_CreaSegna_8
  test('TC_CreaSegna_8 - Errore: Longitudine < -180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 40.7750,
        longitudine: -181.0, // Longitudine non valida
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

  // TC_CreaSegna_9
  test('TC_CreaSegna_9 - Errore: nessuna foto disponibile', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [], // Lista vuota
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

  // TC_CreaSegna_10
  test('TC_CreaSegna_10 - Errore: foto formato non valido', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    await expectLater(
      repository.creaSegnalazione(
        descrizione: 'Trovato meticcio ferito...',
        latitudine: 40.7750,
        longitudine: 14.7890,
        indirizzo: 'Via Giovanni Paolo II, Fisciano (SA)',
        foto: [File('img1.png'), File('img2.png')], // Formato .png non valido
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
