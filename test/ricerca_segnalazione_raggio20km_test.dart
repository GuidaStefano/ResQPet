import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/segnalazione.dart';
import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(overrides: getRiverpodConfig());

    await container
      .read(firebaseFirestoreProvider)
      .collection('segnalazioni')
      .doc('123456')
      .set({
        'foto': ['img1.jpg'],
        'descrizione': 'cane abbandonato',
        'posizione': GeoPoint(76, 76),
        'dataCreazione': Timestamp.now(),
        'stato': StatoSegnalazione.inAttesa.toFirestore(),
        'indirizzo': 'Via Giovanni II, Fisciano (SA)'
      });
  }); 

  tearDown(() {
    container.dispose();
  });

  test('TC_CreaAnnA_1 - Latitudine < -90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);
  
    expect(
      () => repository.getSegnalazioniVicine(-91, 14.25),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message, 
          'message', 
          'La latitudine è fuori range'
        )
      ), 
    );  
  }); 

  test('TC_CreaAnnA_2 - Latitudine > 90', () async {
    final repository = container.read(segnalazioneRepositoryProvider);
  
    expect(
      () => repository.getSegnalazioniVicine(91, 14.25),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message, 
          'message', 
          'La latitudine è fuori range'
        )
      ), 
    );  
  });   

  test('TC_CreaAnnA_3 - Longitudine < -180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);
  
    expect(
      () => repository.getSegnalazioniVicine(40.85, -181),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message, 
          'message', 
          'La longitudine è fuori range'
        )
      ), 
    );  
  }); 

  test('TC_CreaAnnA_4 - Longitudine > 180', () async {
    final repository = container.read(segnalazioneRepositoryProvider);
  
    expect(
      () => repository.getSegnalazioniVicine(40.85, 181),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message, 
          'message', 
          'La longitudine è fuori range'
        )
      ), 
    );  
  }); 

  test('TC_CreaAnnA_5 - Nessuna segnalazione presente nel raggio di 20km', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    final stream = repository.getSegnalazioniVicine(0, 0);

    await expectLater(
      stream,
      emits(isEmpty), 
    );
  });

  test('TC_CreaAnnA_6 - Segnalazione presente nel raggio di 20km', () async {
    final repository = container.read(segnalazioneRepositoryProvider);

    final stream = repository.getSegnalazioniVicine(76, 76);

    await expectLater(
      stream,
      emits(isNotEmpty), 
    );
  });
}