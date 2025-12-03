import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/dao/dao.dart';

class AbbonamentoDao implements Dao<Abbonamento, String> {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'abbonamenti';

  AbbonamentoDao({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Abbonamento> get _collection => _firestore.collection(_collectionPath).withConverter<Abbonamento>(
        fromFirestore: (snapshot, _) => Abbonamento.fromFirestore(snapshot),
        toFirestore: (abbonamento, _) => abbonamento.toFirestore(),
      );

  @override
  Future<Abbonamento> create(Abbonamento data) async {
    final id = (data.id.isNotEmpty) ? data.id : _collection.doc().id;
    final DocumentReference<Abbonamento> docRef = _collection.doc(id);
    final toStore = data.copyWith(id: id);
    await docRef.set(toStore);
    final snap = await docRef.get();
    final Abbonamento? stored = snap.data();
    return stored ?? toStore;
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
  Future<List<Abbonamento>> findAll() async {
    final QuerySnapshot<Abbonamento> snap = await _collection.get();
    return snap.docs.map((d) {
      final data = d.data();
      return data.copyWith(id: d.id);
    }).toList();
  }

  @override
  Stream<List<Abbonamento>> findAllStream() {
    return _collection.snapshots().map((QuerySnapshot<Abbonamento> query) =>
      query.docs.map((d) => d.data().copyWith(id: d.id)).toList());
  }

  @override
  Future<Abbonamento?> findById(String id) async {
    final DocumentSnapshot<Abbonamento> doc = await _collection.doc(id).get();
    final Abbonamento? data = doc.data();
    if (data == null) return null;
    return data.copyWith(id: doc.id);
  }

  @override
  Future<Abbonamento> update(Abbonamento data) async {
    if (data.id.isEmpty) throw ArgumentError('Abbonamento.id is required for update');
    final DocumentReference<Abbonamento> docRef = _collection.doc(data.id);
    await docRef.set(data);
    final snap = await docRef.get();
    final Abbonamento? stored = snap.data();
    return stored ?? data;
  }
}
