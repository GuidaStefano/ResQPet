import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/report.dart';

import 'riverpod_override_config.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer(
      overrides: getRiverpodConfig()
    );

    // Popola il database fake con un report esistente per TC_RisRep_2
    await container.read(firebaseFirestoreProvider)
      .collection('reports')
      .doc('RP_111')
      .set({
        'motivazione': 'Contenuto inappropriato',
        'descrizione': 'L\'annuncio contiene linguaggio offensivo',
        'cittadino_ref': 'user123',
        'annuncio_ref': 'annuncio456',
        'stato': StatoReport.aperto.toFirestore(),
      });
  });

  tearDown(() {
    container.dispose();
  });

  /// =========================
  /// TC_RisRep_1 – ID Non Valido
  /// =========================
  test('TC_RisRep_1 - Errore se ID report non è valido (non esiste)', () async {
    // Arrange
    final repository = container.read(reportRepositoryProvider);
    const reportIDInesistente = 'RP_101';

    // Act & Assert
    await expectLater(
      repository.risolviReport(reportIDInesistente),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Report $reportIDInesistente non trovato',
        ),
      ),
    );
  });

  /// =========================
  /// TC_RisRep_2 – Risoluzione con Successo
  /// =========================
  test('TC_RisRep_2 - Report risolto con successo', () async {
    // Arrange
    final repository = container.read(reportRepositoryProvider);
    const reportIDEsistente = 'RP_111';

    // Act
    await expectLater(
      repository.risolviReport(reportIDEsistente),
      completes
    );

    // Assert - Verifica che lo stato del report sia cambiato a "risolto"
    final doc = await container.read(firebaseFirestoreProvider)
      .collection('reports')
      .doc(reportIDEsistente)
      .get();

    expect(
      doc['stato'], 
      StatoReport.risolto.toFirestore()
    );
  });
}
