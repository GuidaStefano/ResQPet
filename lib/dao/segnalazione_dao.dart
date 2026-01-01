import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/models/segnalazione.dart'; 
import 'dao.dart'; 

class SegnalazioneDao implements Dao<Segnalazione, String> {
  
  static const segnalazioneCollection = 'segnalazioni';
  final FirebaseFirestore _firestore;

  final SegnalazioneFirestoreAdapter _adapter = SegnalazioneFirestoreAdapter();

  CollectionReference<Segnalazione> get _collection =>
    _firestore.collection(segnalazioneCollection)
      .withConverter(
        fromFirestore:(snapshot, options) => _adapter.fromFirestore(snapshot, options),
        toFirestore: (segnalazione, _) => _adapter.toFirestore(segnalazione)
      );

  SegnalazioneDao(this._firestore);


  @override
  Future<Segnalazione> create(Segnalazione data) async {
    final doc = await _collection.add(data);
    return data.copyWith(id: doc.id);
  }

  @override
  Future<bool> deleteById(String id) async {

    try{
      await _collection.doc(id).delete();
      return true;
    } catch(_) {
      return false;
    }
  }

  @override
  Future<List<Segnalazione>> findAll() async {
    final querySnapshot = await _collection.get();

    return querySnapshot.docs
      .map((doc) => doc.data())
      .toList();
  }

  @override
  Stream<List<Segnalazione>> findAllStream() {
    return _collection
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => doc.data())
          .toList();
      });
  }

  @override
  Future<Segnalazione?> findById(String id) async {
    final ref = await _collection.doc(id).get();
    return ref.data();
  }

  @override
  Future<Segnalazione> update(Segnalazione data) async {
    if (data.id.isEmpty) {
      throw Exception('Expected non-null id for update!');
    }

    await _collection.doc(data.id)
      .set(data);

    return data;
  }

  // --- Metodi Aggiuntivi per coprire i requisiti SDD ---

  /// Permette di recuperare le segnalazioni assegnate a un Soccorritore specifico.
  /// Necessario per il requisito "Prende in carico segnalazione" e "Visualizza segnalazioni" [SDD 4.2]
  Stream<List<Segnalazione>> findBySoccorritore(String soccorritoreId) {
    return _collection
      .where('soccorritore_ref', isEqualTo: soccorritoreId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => doc.data())
            .toList();
      });
  }

  /// Permette di recuperare lo storico delle segnalazioni di un Cittadino.
  /// Necessario per il requisito "Lista segnalazioni" lato cittadino [SDD 4.2]
  Stream<List<Segnalazione>> findByCittadino(String cittadinoId) {
    return _collection
      .where('cittadino_ref', isEqualTo: cittadinoId)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
          .map((doc) => doc.data())
            .toList();
      });
  }

  /// Permette di filtrare le segnalazione per stato
  Future<List<Segnalazione>> findByStato(StatoSegnalazione stato) async {
    final querySnapshot = await _collection
      .where('stato', isEqualTo: stato.value)
      .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Permette di filtrare le segnalazione per stato.
  /// Restituisce uno stream per aggirnamenti in tempo reale
  Stream<List<Segnalazione>> findByStatoStream(StatoSegnalazione stato) {
    return _collection
      .where('stato', isEqualTo: stato.value)
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map(
          (doc) => doc.data()
        ).toList()
      );
  }
}
