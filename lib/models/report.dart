import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/core/adapters/firestore_adapter.dart';
import 'package:resqpet/core/utils/copyable.dart';

enum StatoReport {
  aperto("aperto"),
  risolto("risolto");

  const StatoReport(this.stato);
  final String stato;

  factory StatoReport.fromString(String value)
    => StatoReport.values.firstWhere(
      (e) => e.stato == value,
      orElse: () => throw ArgumentError("StatoReport non valido: $value")
    );

  String toFirestore() => stato;
}

/// Modello dominio per la collezione "reports"
/// Struttura logica:
///   id            -> id del documento Firestore (document.id)
///   motivazione   -> motivo sintetico del report 
///   descrizione   -> descrizione estesa
///   cittadinoRef  -> riferimento all'utente che ha creato il report (utenti/_id)
///   annuncioRef   -> riferimento all'annuncio segnalato (annunci/_id)
///   stato         -> stato del report (es. "aperto", "risolto")
class Report implements Copyable<Report> {
  final String id;
  final String motivazione;
  final String descrizione;
  final String cittadinoRef;
  final String annuncioRef;
  final StatoReport stato;

  const Report({
    this.id = '',
    required this.motivazione,
    required this.descrizione,
    required this.cittadinoRef,
    required this.annuncioRef,
    required this.stato,
  });

  /// Puoi passare id vuoto, sarà sostituito nella create() del DAO.
  factory Report.newReport({
    required String motivazione,
    required String descrizione,
    required String cittadinoRef,
    required String annuncioRef,
    StatoReport stato = StatoReport.aperto,
  }) {
    return Report(
      motivazione: motivazione,
      descrizione: descrizione,
      cittadinoRef: cittadinoRef,
      annuncioRef: annuncioRef,
      stato: stato,
    );
  }

  @override
  Report copyWith({
    String? id,
    String? motivazione,
    String? descrizione,
    String? cittadinoRef,
    String? annuncioRef,
    StatoReport? stato,
  }) {
    return Report(
      id: id ?? this.id,
      motivazione: motivazione ?? this.motivazione,
      descrizione: descrizione ?? this.descrizione,
      cittadinoRef: cittadinoRef ?? this.cittadinoRef,
      annuncioRef: annuncioRef ?? this.annuncioRef,
      stato: stato ?? this.stato,
    );
  }
}



class ReportFirestoreAdapter implements FirestoreAdapter<Report> {
  @override
  Report fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ){
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data()");
    }
    
    return Report(
      id: snapshot.id,
      motivazione: data['motivazione'] as String? ?? '',
      descrizione: data['descrizione'] as String? ?? '',
      cittadinoRef: data['cittadinoRef'] as String? ?? '',
      annuncioRef: data['annuncioRef'] as String? ?? '',
      stato: StatoReport.fromString(
        data['stato'] as String? ?? StatoReport.aperto.stato
      )
    );
  }

  @override
  Map<String, dynamic> toFirestore(Report report) {
    return {
      'motivazione': report.motivazione,
      'descrizione': report.descrizione,
      'cittadinoRef': report.cittadinoRef,
      'annuncioRef': report.annuncioRef,
      'stato': report.stato.toFirestore(),
    };
  }
}