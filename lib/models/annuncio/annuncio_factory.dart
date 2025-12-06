import 'package:cloud_firestore/cloud_firestore.dart';

import 'annuncio.dart';
import 'annuncio_vendita.dart';
import 'annuncio_adozione.dart';
import 'tipo_annuncio.dart';

/// Factory class for creating the appropriate Annuncio subclass
/// based on the 'tipo' field in Firestore documents.
class AnnuncioFactory {
  AnnuncioFactory._(); // Private constructor - utility class

  /// Creates the appropriate Annuncio subclass from a Firestore document.
  ///
  /// Reads the 'tipo' field to determine whether to create
  /// AnnuncioVendita or AnnuncioAdozione.
  ///
  /// Throws [StateError] if the document has no data.
  /// Throws [ArgumentError] if the tipo field is missing or invalid.
  static Annuncio fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Document snapshot has no data: ${snapshot.id}');
    }
    return fromMap(data, snapshot.id);
  }

  /// Creates the appropriate Annuncio subclass from a map and document ID.
  ///
  /// This is useful when you have the raw data and ID separately.
  static Annuncio fromMap(Map<String, dynamic> map, String id) {
    final tipoString = map['tipo'] as String?;
    if (tipoString == null) {
      throw ArgumentError('Missing "tipo" field in annuncio document: $id');
    }

    final tipo = TipoAnnuncio.fromString(tipoString);

    switch (tipo) {
      case TipoAnnuncio.vendita:
        return AnnuncioVendita.fromMap(map, id);
      case TipoAnnuncio.adozione:
        return AnnuncioAdozione.fromMap(map, id);
    }
  }

  /// Utility method to check the tipo without full deserialization.
  static TipoAnnuncio getTipo(Map<String, dynamic> map) {
    final tipoString = map['tipo'] as String?;
    if (tipoString == null) {
      throw ArgumentError('Missing "tipo" field in annuncio document');
    }
    return TipoAnnuncio.fromString(tipoString);
  }
}
