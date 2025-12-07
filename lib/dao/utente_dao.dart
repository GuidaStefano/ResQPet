import 'package:cloud_firestore/cloud_firestore.dart';
import 'dao.dart';
import '../models/utente.dart';

class UtenteDao implements Dao<Utente, String> {
  static const userCollection = "utenti";
  final FirebaseFirestore _firestore;

  UtenteDao(this._firestore);

  @override
  Future<Utente> create(Utente data) async {
    final doc = _firestore
        .collection(userCollection)
        .doc(data.id.isNotEmpty ? data.id : null);

    await doc.set(data.toFirestore());

    final ref = await doc
        .withConverter(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .get();

    return ref.data()!;
  }

  @override
  Future<Utente?> findById(String id) async {
    final ref = await _firestore
        .collection(userCollection)
        .doc(id)
        .withConverter(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .get();

    return ref.data();
  }

  @override
  Future<Utente> update(Utente data) async {
    await _firestore
        .collection(userCollection)
        .doc(data.id)
        .withConverter<Utente>(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .set(data);

    final ref = await _firestore
        .collection(userCollection)
        .doc(data.id)
        .withConverter(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .get();

    return ref.data()!;
  }

  @override
  Future<bool> deleteById(String id) async {
    try {
      await _firestore.collection(userCollection).doc(id).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<Utente>> findAll() async {
    final querySnapshot = await _firestore
        .collection(userCollection)
        .withConverter(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Stream<List<Utente>> findAllStream() {
    return _firestore
        .collection(userCollection)
        .withConverter(
          fromFirestore: Utente.fromFirestore,
          toFirestore: (utente, _) => utente.toFirestore(),
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }
}
