import 'package:cloud_firestore/cloud_firestore.dart';
import 'dao.dart';
import '../models/utente.dart';

class UtenteDao implements Dao<Utente, String> {
  static const userCollection = 'utenti';
  final FirebaseFirestore _firestore;

  final UtenteFirestoreAdapter _adapter = UtenteFirestoreAdapter();

  CollectionReference<Utente> get _collection =>
    _firestore.collection(userCollection)
      .withConverter(
        fromFirestore: (snapshot, options) => _adapter.fromFirestore(snapshot, options),
        toFirestore: (utente, _) => _adapter.toFirestore(utente)
      );

  UtenteDao(this._firestore);

  @override
  Future<Utente> create(Utente data) async {

    if(data.id.isEmpty) {
      throw ArgumentError("ID dell'utente non può essere vuoto. Deve corrispondere all'UID di Firebase Auth.");
    }

    final doc = _collection.doc(data.id);
    await doc.set(data);

    return data;
  }

  @override
  Future<Utente?> findById(String id) async {
    final ref = await _collection.doc(id).get();
    return ref.data();
  }

  @override
  Future<Utente> update(Utente data) async {

    if(data.id.isEmpty) {
      throw ArgumentError('Impossibile aggiornare un utente senza ID.');
    }

    await _collection.doc(data.id)
      .set(data);

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
  Future<List<Utente>> findAll() async {
    final querySnapshot = await _collection.get();
    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<Utente>> findAllStream() {
    return _collection
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map(
          (doc) => doc.data()
        ).toList();
      });
  }
}
