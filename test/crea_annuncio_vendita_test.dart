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
        'dettagli_venditore': {
          'indirizzo': 'via test',
          'partitaIVA': 'IT12345678901',
          'dataSottoscrizioneAbbonamento': Timestamp.now(),
          'abbonamento_ref': 'abbonamento_id1'
        }
      });
  }); 

  tearDown(() {
    container.dispose();
  });

  test('TC_CreaAnnV_1 - Errore Nome/specie/razza troppo corti ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Bo', 
        sesso: 'Maschio', 
        peso: 15, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Labrador', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 500, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '123456789123456'
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

  test('TC_CreaAnnV_2 - Errore Nome/specie/razza troppo lunghi ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Furiaaaaaaaaaaaaaaaaaaaaaaaaaaa', 
        sesso: 'Maschio', 
        peso: 35, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Pitbull', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 700, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380098100123456'
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

  test('TC_CreaAnnV_3 - Annuncio di vendita creato ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Bucky', 
        sesso: 'Maschio', 
        peso: 500, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Barboncino', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 500, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380031331323456'
      ), 
      completes
    );
  });  

  test('TC_CreaAnnV_4 - Errore Sesso non valido ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Gioia', 
        sesso: 'Femina', 
        peso: 10, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Volpino', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 700, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380098100123456'
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

  test('TC_CreaAnnV_5 - Errore peso non valido ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Briciola', 
        sesso: 'Femmina', 
        peso: 250000, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Volpino', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 100, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380098100123456'
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

  test('TC_CreaAnnV_6 - Errore lunghezza colore pelo < 3 ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 're', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 800, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380098100123456'
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

  test('TC_CreaAnnV_7 - Errore lunghezza colore pelo > 100 ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 'redddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 800, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '380098100123456'
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

  test('TC_CreaAnnV_8 - Errore microchip non valido ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 'rosso', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 800, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '1000339240F13531'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il numero di microchip deve contenere esattamente 15 cifre',
        ),
      ),
    );
  });     

  test('TC_CreaAnnV_9 - Errore prezzo <= 0 ', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 'nero', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 0, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '100033924013531'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Il prezzo deve essere un numero positivo',
        ),
      ),
    );
  });  

  test('TC_CreaAnnV_10 - Errore formato foto non valido', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 'arancione', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.png')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 800, 
        dataNascita: '12/12/2025', 
        numeroMicrochip: '100033924013531'
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

  test('TC_CreaAnnV_11 - Errore formato data non valido', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Chicco', 
        sesso: 'Maschio', 
        peso: 23, 
        colorePelo: 'arancione', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Coker', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 800, 
        dataNascita: '12-12-2025', 
        numeroMicrochip: '100033924013531'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Data di nascita deve essere nel formato gg/mm/aaaa',
        ),
      ),
    );
  });

  test('TC_CreaAnnV_12 - Errore data di nascita futura', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Bucky', 
        sesso: 'Maschio', 
        peso: 500, 
        colorePelo: 'red', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Barboncino', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 900, 
        dataNascita: '12/11/2027', 
        numeroMicrochip: '380031331323456'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Data di nascita non può essere futura',
        ),
      ),
    );
  });  

test('TC_CreaAnnV_13 - Errore data di nascita non valida', () async {

    final repository = container.read(annuncioRepositoryProvider);
  
    await expectLater(
      repository.creaAnnuncioVendita(
        nome: 'Bucky', 
        sesso: 'Maschio', 
        peso: 500, 
        colorePelo: 'arancione', 
        isSterilizzato: true, 
        specie: 'Cane', 
        razza: 'Barboncino', 
        foto: [File('card1.jpg')], 
        statoAnnuncio: StatoAnnuncio.attivo, 
        prezzo: 900, 
        dataNascita: '12/19/2017', 
        numeroMicrochip: '380031331323456'
      ), 
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'La data inserita non esiste nel calendario',
        ),
      ),
    );
  });
}
