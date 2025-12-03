import 'package:cloud_firestore/cloud_firestore.dart';

class Abbonamento {
  final String id;
  final String descrizione;
  final double prezzo;
  final int maxAnnunciVendita;
  final int annunciPriority;
  final int durataInMesi;

  Abbonamento({
    required this.id,
    required this.descrizione,
    required this.prezzo,
    required this.maxAnnunciVendita,
    required this.annunciPriority,
    required this.durataInMesi,
  });

  Abbonamento copyWith({
    String? id,
    String? descrizione,
    double? prezzo,
    int? maxAnnunciVendita,
    int? annunciPriority,
    int? durataInMesi,
  }) {
    return Abbonamento(
      id: id ?? this.id,
      descrizione: descrizione ?? this.descrizione,
      prezzo: prezzo ?? this.prezzo,
      maxAnnunciVendita: maxAnnunciVendita ?? this.maxAnnunciVendita,
      annunciPriority: annunciPriority ?? this.annunciPriority,
      durataInMesi: durataInMesi ?? this.durataInMesi,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'descrizione': descrizione,
      'prezzo': prezzo,
      'maxAnnunciVendita': maxAnnunciVendita,
      'annunciPriority': annunciPriority,
      'durataInMesi': durataInMesi,
    };
  }

  factory Abbonamento.fromMap(Map<String, dynamic> map) {
    return Abbonamento(
      id: map['id'] as String? ?? '',
      descrizione: map['descrizione'] as String? ?? '',
      prezzo: (map['prezzo'] is int)
          ? (map['prezzo'] as int).toDouble()
          : (map['prezzo'] as num?)?.toDouble() ?? 0.0,
      maxAnnunciVendita: (map['maxAnnunciVendita'] as num?)?.toInt() ?? 0,
      annunciPriority: (map['annunciPriority'] as num?)?.toInt() ?? 0,
      durataInMesi: (map['durataInMesi'] as num?)?.toInt() ?? 0,
    );
  }

  factory Abbonamento.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    // Ensure id from document id if not present in data
    final id = (data['id'] as String?) ?? snapshot.id;
    return Abbonamento.fromMap({...data, 'id': id});
  }
}
