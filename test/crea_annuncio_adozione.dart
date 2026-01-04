import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_storage_mocks/firebase_storage_mocks.dart';

import 'riverpod_override_config.dart';

@GenerateMocks([])
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseStorage fakeStorage;
  // late AnnuncioService annuncioService;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    fakeStorage = MockFirebaseStorage();
    // annuncioService = AnnuncioService(
    //   firestore: fakeFirestore,
    //   storage: fakeStorage,
    // );
  });

  group('TC_CreaAnnuncioAdozione - Category Partitioning Tests', () {
    
    // ========================================================================
    // TC_CreaAnnA_1: Errore stringhe base < 3 caratteri
    // ========================================================================
    test('TC_CreaAnnA_1 - Errore: lunghezza stringhe base < 3', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bo', // < 3 caratteri - ERRORE
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('lunghezza stringhe base') ||
          e.toString().contains('minimo 3 caratteri')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_2: Errore stringhe base > 30 caratteri
    // ========================================================================
    test('TC_CreaAnnA_2 - Errore: lunghezza stringhe base > 30', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Boooooooooooooooooooooooooooooooooooooooooo', // > 30 caratteri
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('lunghezza stringhe base') ||
          e.toString().contains('massimo 30 caratteri')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_3: Successo - Annuncio creato correttamente
    // ========================================================================
    test('TC_CreaAnnA_3 - Successo: annuncio creato con successo', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act
      final result = await creaAnnuncioAdozione(input);

      // Assert
      expect(result, isNotNull);
      expect(result['success'], true);
      expect(result['annuncioId'], isNotEmpty);
    });

    // ========================================================================
    // TC_CreaAnnA_4: Errore sesso non valido (regex)
    // ========================================================================
    test('TC_CreaAnnA_4 - Errore: sesso non rispetta la regex', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'Machio', // Typo - non rispetta regex ^(maschio|femmina)$
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('sesso') &&
          (e.toString().contains('non valido') || e.toString().contains('regex'))
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_5: Errore peso non valido
    // ========================================================================
    test('TC_CreaAnnA_5 - Errore: peso non valido (negativo)', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': -15.0, // Peso negativo
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('peso') &&
          (e.toString().contains('negativo') || e.toString().contains('non valido'))
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_6: Errore colore pelo < 3 caratteri
    // ========================================================================
    test('TC_CreaAnnA_6 - Errore: lunghezza colore < 3', () async {
      // Arrange
      final input = {
        'colorePelo': 're', // < 3 caratteri
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('colore') &&
          e.toString().contains('3')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_7: Errore colore pelo > 100 caratteri
    // ========================================================================
    test('TC_CreaAnnA_7 - Errore: lunghezza colore > 100', () async {
      // Arrange
      final input = {
        'colorePelo': 'r' * 101, // 101 caratteri
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('colore') &&
          e.toString().contains('100')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_8: Errore formato foto non valido
    // ========================================================================
    test('TC_CreaAnnA_8 - Errore: formato foto non valido', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.pdf'], // Formato non valido (deve essere jpg/jpeg)
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('formato') &&
          e.toString().contains('foto')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_9: Errore note sanitarie < 3 caratteri
    // ========================================================================
    test('TC_CreaAnnA_9 - Errore: note sanitarie < 3', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': '', // Stringa vuota
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('note sanitarie') &&
          e.toString().contains('3')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_10: Errore note sanitarie > 150 caratteri
    // ========================================================================
    test('TC_CreaAnnA_10 - Errore: note sanitarie > 150', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'Il cane è stato presentato per una visita di controllo periodica. Il proprietario riferisce un comportamento vivace e un appetito regolare. Non si segnalano episodi di vomito o diarrea recenti.',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('note sanitarie') &&
          e.toString().contains('150')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_11: Errore storia < 3 caratteri
    // ========================================================================
    test('TC_CreaAnnA_11 - Errore: lunghezza storia < 3', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': '', // Stringa vuota
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('storia') &&
          e.toString().contains('3')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_12: Errore storia > 200 caratteri
    // ========================================================================
    test('TC_CreaAnnA_12 - Errore: lunghezza storia > 200', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': 500.00,
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'Bob è un esemplare di Pastore Belga Malinois dall\'eleganza fiera e dal portamento atletico. Il suo corpo è una macchina di muscoli scattanti, rivestito da un mantello corto color fulvo carbonato che brilla sotto i raggi del sole. La caratteristica che colpisce immediatamente è la sua maschera nera, intensa e definita, che incornicia un muso affilato e vigile.',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('storia') &&
          e.toString().contains('200')
        )),
      );
    });

    // ========================================================================
    // TC_CreaAnnA_13: Errore contributo spese sanitarie non valido
    // ========================================================================
    test('TC_CreaAnnA_13 - Errore: contributo spese sanitarie non valido', () async {
      // Arrange
      final input = {
        'colorePelo': 'red',
        'nome': 'Bob',
        'sesso': 'maschio',
        'specie': 'Cane',
        'razza': 'Labrador',
        'peso': 15.0,
        'contributoSpeseSanitarie': -500.00, // Valore negativo
        'foto': ['cane.jpeg'],
        'dataNascita': '12/11/2023',
        'isSterilizzato': true,
        'storia': 'cambia frequentemente casa',
        'noteSanitarie': 'cane appena sterilizzato',
        'carattere': 'frizzantino',
      };

      // Act & Assert
      expect(
        () => creaAnnuncioAdozione(input),
        throwsA(predicate((e) => 
          e.toString().contains('contributo') ||
          e.toString().contains('spese')
        )),
      );
    });
  });
}

// ============================================================================
// FUNZIONE DA TESTARE - Implementazione di esempio
// ============================================================================
Future<Map<String, dynamic>> creaAnnuncioAdozione(Map<String, dynamic> input) async {
  // Validazione Stringhe Base (nome, specie, razza, carattere)
  final stringheBase = ['nome', 'specie', 'razza', 'carattere'];
  for (var campo in stringheBase) {
    final valore = input[campo] as String;
    if (valore.length < 3) {
      throw Exception('Errore: $campo deve avere almeno 3 caratteri');
    }
    if (valore.length > 30) {
      throw Exception('Errore: $campo deve avere massimo 30 caratteri');
    }
  }

  // Validazione Sesso
  final sessoRegex = RegExp(r'^(maschio|femmina)$', caseSensitive: false);
  if (!sessoRegex.hasMatch(input['sesso'] as String)) {
    throw Exception('Errore: sesso non valido. Deve essere "maschio" o "femmina"');
  }

  // Validazione Peso
  final peso = input['peso'] as double;
  if (peso <= 0 || peso >= 1000) {
    throw Exception('Errore: peso deve essere tra 0 e 1000 kg');
  }

  // Validazione Colore Pelo
  final colorePelo = input['colorePelo'] as String;
  if (colorePelo.length < 3) {
    throw Exception('Errore: colore pelo deve avere almeno 3 caratteri');
  }
  if (colorePelo.length > 100) {
    throw Exception('Errore: colore pelo deve avere massimo 100 caratteri');
  }

  // Validazione Foto
  final foto = input['foto'] as List<String>;
  final formatoValido = RegExp(r'\.(jpg|jpeg)$', caseSensitive: false);
  if (!formatoValido.hasMatch(foto.first)) {
    throw Exception('Errore: formato foto non valido. Deve essere jpg o jpeg');
  }

  // Validazione Note Sanitarie
  final noteSanitarie = input['noteSanitarie'] as String;
  if (noteSanitarie.length < 3) {
    throw Exception('Errore: note sanitarie devono avere almeno 3 caratteri');
  }
  if (noteSanitarie.length > 150) {
    throw Exception('Errore: note sanitarie devono avere massimo 150 caratteri');
  }

  // Validazione Storia
  final storia = input['storia'] as String;
  if (storia.length < 3) {
    throw Exception('Errore: storia deve avere almeno 3 caratteri');
  }
  if (storia.length > 200) {
    throw Exception('Errore: storia deve avere massimo 200 caratteri');
  }

  // Validazione Contributo Spese Sanitarie
  final contributo = input['contributoSpeseSanitarie'] as double;
  if (contributo <= 0) {
    throw Exception('Errore: contributo spese sanitarie deve essere maggiore di 0');
  }

  // Se tutte le validazioni passano, simula la creazione dell'annuncio
  return {
    'success': true,
    'annuncioId': 'mock_id_${DateTime.now().millisecondsSinceEpoch}',
    'message': 'Annuncio creato con successo',
  };
}