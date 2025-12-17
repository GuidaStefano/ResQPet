import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/core/adapters/firestore_adapter.dart';
import 'package:resqpet/core/utils/copyable.dart';

class Abbonamento implements Copyable<Abbonamento> {
  final String id;
  final String descrizione;
  final double prezzo;
  final int maxAnnunciVendita;
  final int percentualeGuadagni;
  final int durataInMesi;

  Abbonamento({
    this.id = '',
    required this.descrizione,
    required this.prezzo,
    required this.maxAnnunciVendita,
    required this.percentualeGuadagni,
    required this.durataInMesi,
  });

  @override
  Abbonamento copyWith({
    String? id,
    String? descrizione,
    double? prezzo,
    int? maxAnnunciVendita,
    int? percentualeGuadagni,
    int? durataInMesi,
  }) {
    return Abbonamento(
      id: id ?? this.id,
      descrizione: descrizione ?? this.descrizione,
      prezzo: prezzo ?? this.prezzo,
      maxAnnunciVendita: maxAnnunciVendita ?? this.maxAnnunciVendita,
      percentualeGuadagni: percentualeGuadagni ?? this.percentualeGuadagni,
      durataInMesi: durataInMesi ?? this.durataInMesi,
    );
  }
}

class AbbonamentoFirestoreAdapter implements FirestoreAdapter<Abbonamento> {
  @override
  Abbonamento fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull('snapshot.data()');
    }

    return Abbonamento(
      id: snapshot.id,
      descrizione: data['descrizione'] as String? ?? '',
      prezzo: (data['prezzo'] as num?)?.toDouble() ?? 0.0,
      maxAnnunciVendita: data['maxAnnunciVendita'] as int? ?? 0,
      percentualeGuadagni: data['percentualeGuadagni'] as int? ?? 0,
      durataInMesi: data['durataInMesi'] as int? ?? 0 
    );
  }

  @override
  Map<String, dynamic> toFirestore(Abbonamento abbonamento) {
    return {
      'descrizione': abbonamento.descrizione,
      'prezzo': abbonamento.prezzo,
      'maxAnnunciVendita': abbonamento.maxAnnunciVendita,
      'percentualeGuadagni': abbonamento.percentualeGuadagni,
      'durataInMesi': abbonamento.durataInMesi,
    };
  }
  
}