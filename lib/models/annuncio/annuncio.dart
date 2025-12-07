import 'package:cloud_firestore/cloud_firestore.dart';

import 'tipo_annuncio.dart';
import 'stato_annuncio.dart';
import 'annuncio_vendita.dart';
import 'annuncio_adozione.dart';

/// Base class for all announcement types.
/// Contains common fields shared between AnnuncioVendita and AnnuncioAdozione.
abstract class Annuncio {
  final String id;
  final String creatoreRef;
  final TipoAnnuncio tipo;
  final String nome;
  final String sesso;
  final String peso;
  final String colorePelo;
  final bool isSterilizzato;
  final String specie;
  final String razza;
  final List<String> foto;
  final StatoAnnuncio statoAnnuncio;

  const Annuncio({
    this.id = '',
    required this.creatoreRef,
    required this.tipo,
    required this.nome,
    required this.sesso,
    required this.peso,
    required this.colorePelo,
    required this.isSterilizzato,
    required this.specie,
    required this.razza,
    required this.foto,
    required this.statoAnnuncio,
  });

  /// Factory polimorfica per deserializzazione da Firestore.
  /// Compatibile con withConverter().
  factory Annuncio.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
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
    switch (tipo) {
      case TipoAnnuncio.vendita:
        return AnnuncioVendita.fromMap(data, id);
      case TipoAnnuncio.adozione:
        return AnnuncioAdozione.fromMap(data, id);
    }
  }

  /// Converts the common fields to a Firestore-compatible map.
  /// Subclasses should call this and add their specific fields.
  Map<String, dynamic> toFirestoreBase() {
    return {
      'creatore_ref': creatoreRef,
      'tipo': tipo.toFirestore(),
      'nome': nome,
      'sesso': sesso,
      'peso': peso,
      'colorePelo': colorePelo,
      'isSterelizzato': isSterilizzato, // Note: keeping original JSON spelling
      'specie': specie,
      'razza': razza,
      'foto': foto,
      'statoAnnuncio': statoAnnuncio.toFirestore(),
    };
  }

  /// Abstract method - each subclass must implement full serialization.
  Map<String, dynamic> toFirestore();

  /// Abstract method - each subclass must implement copyWith.
  Annuncio copyWith({
    String? id,
    String? creatoreRef,
    TipoAnnuncio? tipo,
    String? nome,
    String? sesso,
    String? peso,
    String? colorePelo,
    bool? isSterilizzato,
    String? specie,
    String? razza,
    List<String>? foto,
    StatoAnnuncio? statoAnnuncio,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Annuncio && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
