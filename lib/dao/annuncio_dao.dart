import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/dao/dao.dart';

/// Data Access Object for Annuncio entities.
///
/// Implements the Dao interface and provides polymorphic handling
/// of AnnuncioVendita and AnnuncioAdozione types.
class AnnuncioDao implements Dao<Annuncio, String> {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'annunci';

  AnnuncioDao(this._firestore);

  /// Collection con withConverter per serializzazione/deserializzazione automatica.
  CollectionReference<Annuncio> get _collection =>
      _firestore.collection(_collectionPath).withConverter<Annuncio>(
            fromFirestore: Annuncio.fromFirestore,
            toFirestore: (annuncio, _) => annuncio.toFirestore(),
          );

  // ==================== Dao Interface Methods ====================

  @override
  Future<Annuncio> create(Annuncio data) async {
    final docRef = _collection.doc();
    await docRef.set(data);
    return data.copyWith(id: docRef.id);
  }

  @override
  Future<Annuncio?> findById(String id) async {
    final doc = await _collection.doc(id).get();
    return doc.data();
  }

  @override
  Future<Annuncio> update(Annuncio data) async {
    if (data.id.isEmpty) {
      throw ArgumentError('Annuncio.id is required for update');
    }
    await _collection.doc(data.id).set(data);
    return data;
  }

  @override
  Future<bool> deleteById(String id) async {
    try {
      await _collection.doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Annuncio>> findAll() async {
    final snap = await _collection.get();
    return snap.docs.map((d) => d.data()).toList();
  }

  @override
  Stream<List<Annuncio>> findAllStream() {
    return _collection
        .snapshots()
        .map((query) => query.docs.map((d) => d.data()).toList());
  }

  // ==================== Additional Query Methods ====================

  /// Finds all announcements of a specific type.
  Future<List<Annuncio>> findByTipo(TipoAnnuncio tipo) async {
    final snap = await _collection
        .where('tipo', isEqualTo: tipo.toFirestore())
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Returns a stream of announcements filtered by type.
  Stream<List<Annuncio>> findByTipoStream(TipoAnnuncio tipo) {
    return _collection
        .where('tipo', isEqualTo: tipo.toFirestore())
        .snapshots()
        .map((query) => query.docs.map((d) => d.data()).toList());
  }

  /// Finds all announcements created by a specific user.
  Future<List<Annuncio>> findByCreatore(String creatoreRef) async {
    final snap = await _collection
        .where('creatore_ref', isEqualTo: creatoreRef)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Returns a stream of announcements for a specific creator.
  Stream<List<Annuncio>> findByCreatoreStream(String creatoreRef) {
    return _collection
        .where('creatore_ref', isEqualTo: creatoreRef)
        .snapshots()
        .map((query) => query.docs.map((d) => d.data()).toList());
  }

  /// Finds all announcements with a specific status.
  Future<List<Annuncio>> findByStato(StatoAnnuncio stato) async {
    final snap = await _collection
        .where('statoAnnuncio', isEqualTo: stato.toFirestore())
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Returns a stream of announcements filtered by status.
  Stream<List<Annuncio>> findByStatoStream(StatoAnnuncio stato) {
    return _collection
        .where('statoAnnuncio', isEqualTo: stato.toFirestore())
        .snapshots()
        .map((query) => query.docs.map((d) => d.data()).toList());
  }

  /// Finds announcements by status and type.
  /// Useful for calculating seller revenue (closed sale announcements).
  Future<List<Annuncio>> findByStatoAndTipo(
    StatoAnnuncio stato,
    TipoAnnuncio tipo,
  ) async {
    final snap = await _collection
        .where('statoAnnuncio', isEqualTo: stato.toFirestore())
        .where('tipo', isEqualTo: tipo.toFirestore())
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Stream version of findByStatoAndTipo.
  Stream<List<Annuncio>> findByStatoAndTipoStream(
    StatoAnnuncio stato,
    TipoAnnuncio tipo,
  ) {
    return _collection
        .where('statoAnnuncio', isEqualTo: stato.toFirestore())
        .where('tipo', isEqualTo: tipo.toFirestore())
        .snapshots()
        .map((query) => query.docs.map((d) => d.data()).toList());
  }

  /// Finds active announcements of a specific type.
  /// Useful for displaying listings to users.
  Future<List<Annuncio>> findActiveByTipo(TipoAnnuncio tipo) async {
    final snap = await _collection
        .where('tipo', isEqualTo: tipo.toFirestore())
        .where('statoAnnuncio', isEqualTo: StatoAnnuncio.attivo.toFirestore())
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Finds announcements by species (e.g., 'cane', 'gatto').
  Future<List<Annuncio>> findBySpecie(String specie) async {
    final snap = await _collection.where('specie', isEqualTo: specie).get();
    return snap.docs.map((d) => d.data()).toList();
  }

  /// Updates only the status of an announcement.
  /// More efficient than updating the entire document.
  Future<void> updateStato(String id, StatoAnnuncio nuovoStato) async {
    await _firestore.collection(_collectionPath).doc(id).update({
      'statoAnnuncio': nuovoStato.toFirestore(),
    });
  }

  /// Batch delete multiple announcements by ID.
  /// Useful for cleanup operations.
  Future<void> deleteMultiple(List<String> ids) async {
    final batch = _firestore.batch();
    for (final id in ids) {
      batch.delete(_collection.doc(id));
    }
    await batch.commit();
  }
}
