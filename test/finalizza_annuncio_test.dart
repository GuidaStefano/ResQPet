import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(
      overrides: getRiverpodConfig()
    );


    await container.read(firebaseFirestoreProvider)
      .collection('annunci')
      .doc('123456')
      .set({
        'creatoreRef': 'user1',
        'tipo': TipoAnnuncio.vendita.toFirestore(),
        'nome': 'Fido',
        'sesso': 'maschio',
        'peso': 10.0,
        'colorePelo': 'Nero',
        'isSterilizzato': true,
        'specie': 'Cane',
        'razza': 'Meticcio',
        'foto': const ['foto1.jpg'],
        'statoAnnuncio': StatoAnnuncio.attivo.toFirestore(),
        'dettagli_vendita': {
          'prezzo': 200.0,
          'dataNascita': '11/12/2024',
          'numeroMicrochip': 'MIC123',
        }
      });

  });

  tearDown(() {
    container.dispose();
  });

  /// =========================
  /// TC_FinAnn_1 – Inesistente
  /// =========================
  test('TC_FinAnn_1 - Errore se annuncio non esiste', () async {

    final repository = container.read(annuncioRepositoryProvider);

    // Act & Assert
    await expectLater(
      repository.finalizzaAnnuncio('id_inesistente'),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          'Annuncio non esistente',
        ),
      ),
    );
  });

  /// =========================
  /// TC_FinAnn_2 – Esistente
  /// =========================
  test('TC_FinAnn_2 - Annuncio finalizzato con successo', () async {

    final repository = container.read(annuncioRepositoryProvider);
    
    await expectLater(
      repository.finalizzaAnnuncio('123456'),
      completes
    );

    final doc = await container.read(firebaseFirestoreProvider)
      .collection('annunci')
      .doc('123456')
      .get();

    expect(
      doc['statoAnnuncio'], 
      StatoAnnuncio.concluso.toFirestore()
    );

  });
}
