import 'package:cloud_firestore/cloud_firestore.dart';

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
///   stato         -> stato del report (es. "aperto", "risolto", "ignorato")
class Report {
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

  /// Mappa dalle chiavi JSON/Firestore alla nostra entity.
  /// NOTA: l'id del documento NON è salvato nel documento, ma arriva da Firestore (doc.id).
  factory Report.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options
  ) {

    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data");
    }

    return Report(
      id: snapshot.id,
      motivazione: data['motivazione'] as String? ?? '',
      descrizione: data['descrizione'] as String? ?? '',
      cittadinoRef: data['cittadino_ref'] as String? ?? '',
      annuncioRef: data['annuncio_ref'] as String? ?? '',
      stato: StatoReport.fromString(
        data['stato'] as String? ?? StatoReport.aperto.stato
      ),
    );
  }

  /// Conversione a JSON per Firestore.
  /// L'id NON viene incluso: Firestore usa l'id del documento, non un campo "id".
  Map<String, dynamic> toFirestore() {
    return {
      'motivazione': motivazione,
      'descrizione': descrizione,
      'cittadino_ref': cittadinoRef,
      'annuncio_ref': annuncioRef,
      'stato': stato.toFirestore(),
    };
  }
}