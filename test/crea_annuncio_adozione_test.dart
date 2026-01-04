import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
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
        'nominativo': 'Luca',
        'email': 'mockuser@resqpet.it',
        'dataCreazione': Timestamp.now(),
        'numeroTelefono': '0123456789',
        'dettagli_ente': {
          'sedeLegale': 'via test',
          'partitaIVA': 'IT12345678901',
        }
      });
  }); 

  tearDown(() {
    container.dispose();
  });

  test('TC_CreaAnnA_1 - Errore lunghezza stringhe base < 3', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bo', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('3 e 30 caratteri'),
        ),
      ),
    );
  });

  test('TC_CreaAnnA_2 - Errore lunghezza stringhe base > 30', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Boooooooooooooooooooooooooooooooooooooooooo', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('3 e 30 caratteri'),
        ),
      ),
    );
  });

  test('TC_CreaAnnA_3 - Successo: annuncio creato con successo', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      completes
    );
  });

  test('TC_CreaAnnA_4 - Errore: sesso non valido', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'Machio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il sesso deve essere "maschio" o "femmina"',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_5 - Errore: peso non valido', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: -15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il peso deve essere un numero positivo inferiore a 1000',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_6 - Errore: lunghezza colore < 3', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 're', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il colore deve essere tra 3 e 100 caratteri',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_7 - Errore: lunghezza colore > 100', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'r' * 100 + 'e', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il colore deve essere tra 3 e 100 caratteri',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_8 - Errore: formato foto non valido', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.pdf')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il formato delle foto deve essere jpeg',
        ),
      ),
    );
  });

test('TC_CreaAnnA_9 - Errore: note sanitarie < 3', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: '',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Le note sanitarie devono essere tra 3 e 150 caratteri',
        ),
      ),
    );
  });
  test('TC_CreaAnnA_10 - Errore: note sanitarie > 150', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'Il cane è stato presentato per una visita di controllo periodica. Il proprietario riferisce un comportamento vivace e un appetito regolare. Non si segnalano episodi di vomito o diarrea recenti.',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('Le note sanitarie devono essere tra 3 e 150 caratteri'),
        ),
      ),
    );
  });

  test('TC_CreaAnnA_11 - Errore: lunghezza storia < 3', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: '',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La storia deve essere tra 3 e 200 caratteri',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_12 - Errore: lunghezza storia > 200', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: 500.0, 
        storia: 'Bob è un esemplare di Pastore Belga Malinois dall \'eleganza fiera e dal portamento atletico. Il suo corpo è una macchina di muscoli scattanti, rivestito da un mantello corto color fulvo carbonato che brilla sotto i raggi del sole. La caratteristica che colpisce immediatamente è la sua maschera nera, intensa e definita, che incornicia un muso affilato e vigile.',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La storia deve essere tra 3 e 200 caratteri',
        ),
      ),
    );
  });

  test('TC_CreaAnnA_13 - Errore: contributo spese sanitarie negativo', () async {
    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioAdozione(
        nome: 'Bob', 
        sesso: 'maschio', 
        peso: 15.0, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        contributoSpeseSanitarie: -500.0, 
        storia: 'cambia frequentemente casa',
        noteSanitarie: 'cane appena sterilizzato',
        carattere: 'frizzantino'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il contributo alle spese sanitarie deve essere un numero decimale maggiore o uguale a zero',
        ),
      ),
    );
  });
}