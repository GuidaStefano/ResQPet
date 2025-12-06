import 'package:cloud_firestore/cloud_firestore.dart';

class Abbonamento {
  final String id;
  final String descrizione;
  final double prezzo;
  final int maxAnnunciVendita;
  final int annunciPriority;
  final int durataInMesi;

  Abbonamento({
    this.id = '',
    required this.descrizione,
    required this.prezzo,
    required this.maxAnnunciVendita,
    required this.annunciPriority,
    required this.durataInMesi,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'descrizione': descrizione,
      'prezzo': prezzo,
      'maxAnnunciVendita': maxAnnunciVendita,
      'annunciPriority': annunciPriority,
      'durataInMesi': durataInMesi,
    };
  }

  factory Abbonamento.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {

    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data()");
    }

    return Abbonamento(
      id: snapshot.id,
      descrizione: data['descrizione'] as String? ?? '',
      prezzo: (data['prezzo'] as num?)?.toDouble() ?? 0.0,
      maxAnnunciVendita: data['maxAnnunciVendita'] as int? ?? 0,
      annunciPriority: data['annunciPriority'] as int? ?? 0,
      durataInMesi: data['durataInMesi'] as int? ?? 0 
    );
  }
}
