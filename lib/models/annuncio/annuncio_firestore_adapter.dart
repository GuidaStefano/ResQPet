import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/core/adapters/firestore_adapter.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AnnuncioFirestoreAdapter implements FirestoreAdapter<Annuncio> {
  @override
  Annuncio fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();
    final id = snapshot.id;
    if (data == null) {
      throw StateError('Document snapshot has no data: $id');
    }

    final tipoString = data['tipo'] as String?;
    if (tipoString == null) {
      throw ArgumentError('Missing "tipo" field in annuncio document: $id');
    }

    final tipo = TipoAnnuncio.fromString(tipoString);

    return switch (tipo) {
      TipoAnnuncio.vendita => AnnuncioVendita.fromMap(data, id),
      TipoAnnuncio.adozione => AnnuncioAdozione.fromMap(data, id)
    };
  }

  @override
  Map<String, dynamic> toFirestore(Annuncio data) {
    return data.toMap();
  }

}