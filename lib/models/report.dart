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
  final String stato;

  const Report({
    required this.id,
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
    String stato = 'aperto',
  }) {
    return Report(
      id: '',
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
    String? stato,
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
  factory Report.fromMap(Map<String, dynamic> map, {required String id}) {
    return Report(
      id: id,
      motivazione: map['motivazione'] as String? ?? '',
      descrizione: map['descrizione'] as String? ?? '',
      cittadinoRef: map['cittadino_ref'] as String? ?? '',
      annuncioRef: map['annuncio_ref'] as String? ?? '',
      stato: map['stato'] as String? ?? '',
    );
  }

  /// Conversione a JSON per Firestore.
  /// L'id NON viene incluso: Firestore usa l'id del documento, non un campo "id".
  Map<String, dynamic> toMap() {
    return {
      'motivazione': motivazione,
      'descrizione': descrizione,
      'cittadino_ref': cittadinoRef,
      'annuncio_ref': annuncioRef,
      'stato': stato,
    };
  }
}