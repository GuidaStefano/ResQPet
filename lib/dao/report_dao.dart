import 'package:cloud_firestore/cloud_firestore.dart';

import 'dao.dart';
import '../models/report.dart';

/// Implementazione concreta del DAO per la collezione "reports".
///
/// Schema documenti (campi):
///   motivazione   : string
///   descrizione   : string
///   cittadino_ref : string (id utente)
///   annuncio_ref  : string (id annuncio)
///   stato         : string (es. "aperto", "risolto", "ignorato")
///
/// L'id del report è il document.id di Firestore.
class ReportDao implements Dao<Report, String> {
  final FirebaseFirestore _db;

  CollectionReference<Report> get _collection 
    => _db.collection('reports')
      .withConverter(
        fromFirestore: Report.fromFirestore,
        toFirestore: (report, _)  => report.toFirestore()
      );

  ReportDao(this._db);

  /// Crea un nuovo documento "report" in Firestore.
  ///
  /// Ignora l'id passato nel [data] (può essere anche stringa vuota) e usa
  /// l'id generato da Firestore.
  @override
  Future<Report> create(Report data) async {
    final docRef = await _collection.add(data);
    // restituisco lo stesso report con id aggiornato
    return data.copyWith(id: docRef.id);
  }

  /// Restituisce un singolo report dato il suo id, oppure null se non esiste.
  @override
  Future<Report?> findById(String id) async {
    final doc = await _collection.doc(id).get();
    return doc.data();
  }

  /// Aggiorna il documento esistente per il report passato.
  ///
  /// È necessario che [data.id] non sia vuoto e corrisponda ad un documento esistente.
  @override
  Future<Report> update(Report data) async {
    if (data.id.isEmpty) {
      throw ArgumentError("Report.id non può essere vuoto per l'update");
    }

    await _collection
      .doc(data.id)
      .update(data.toFirestore());

    return data;
  }

  /// Cancella il report con l'id specificato.
  ///
  /// Restituisce true se la delete non solleva eccezioni.
  @override
  Future<bool> deleteById(String id) async {
    try {
      await _collection.doc(id).delete();
      return true;
    } catch(_) {
      // Puoi loggare l'errore o propagare in modo diverso se preferisci
      return false;
    }
  }

  /// Recupera tutti i report presenti nella collezione.
  @override
  Future<List<Report>> findAll() async {
    final snapshot = await _collection.get();
    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  }

  /// Stream in tempo reale di tutti i report.
  ///
  /// Utile per le schermate admin: dashboard dei report aperti ecc.
  @override
  Stream<List<Report>> findAllStream() {
    return _collection.snapshots().map(
      (querySnapshot) => querySnapshot.docs
        .map((doc) => doc.data())
        .toList(),
    );
  }

  // --- Metodi extra opzionali ---

  /// Restituisce tutti i report con uno specifico stato (es. "aperto", "risolto").
  Future<List<Report>> findByStato(StatoReport stato) async {
    final snapshot = await _collection
      .where('stato', isEqualTo: stato.stato)
      .get();

    return snapshot.docs
      .map((doc) => doc.data())
      .toList();
  }

  /// Stream dei soli report con uno specifico stato (es. solo "aperto").
  Stream<List<Report>> findByStatoStream(StatoReport stato) {
    return _collection
      .where('stato', isEqualTo: stato.stato)
      .snapshots()
      .map(
        (querySnapshot) => querySnapshot.docs
          .map((doc) => doc.data())
          .toList()
      );
  }
}