import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/dao/dao.dart';

class AbbonamentoDao implements Dao<Abbonamento, String> {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'abbonamenti';

  final AbbonamentoFirestoreAdapter _adapter = AbbonamentoFirestoreAdapter();

  AbbonamentoDao(this._firestore);

  CollectionReference<Abbonamento> get _collection => _firestore
    .collection(_collectionPath)
    .withConverter<Abbonamento>(
      fromFirestore: (snapshot, options) => _adapter.fromFirestore(snapshot, options),
      toFirestore: (abbonamento, _) => _adapter.toFirestore(abbonamento)
    );

  @override
  Future<Abbonamento> create(Abbonamento data) async {
    final doc = await _collection.add(data);
    final snap = await doc.get();
    return snap.data()!;
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

    return snap.docs
      .map((d) => d.data())
      .toList();
  }

  @override
  Stream<List<Abbonamento>> findAllStream() {
    return _collection.snapshots().map(
      (QuerySnapshot<Abbonamento> query) =>
        query.docs.map((d) => d.data()).toList(),
    );
  }

  @override
  Future<Abbonamento?> findById(String id) async {
    final doc = await _collection.doc(id).get();
    return doc.data();
  }

  @override
  Future<Abbonamento> update(Abbonamento data) async {
    final id = data.id;
    
    if (id.isEmpty) {
      throw ArgumentError('Abbonamento.id is required for update');
    }
    
    final doc = _collection.doc(id);
    await doc.set(data);
    return (await doc.get()).data()!;
  }
}
