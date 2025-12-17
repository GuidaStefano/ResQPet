import 'package:resqpet/core/utils/copyable.dart';

import 'tipo_annuncio.dart';
import 'stato_annuncio.dart';

/// Base class for all announcement types.
/// Contains common fields shared between AnnuncioVendita and AnnuncioAdozione.
abstract class Annuncio implements Copyable<Annuncio> {
  final String id;
  final String creatoreRef;
  final TipoAnnuncio tipo;
  final String nome;
  final String sesso;
  final double peso;
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

  /// Converts the common fields to a Firestore-compatible map.
  /// Subclasses should call this and add their specific fields.
  Map<String, dynamic> toMapBase() {
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

  Map<String, dynamic> toMap();

  /// Abstract method - each subclass must implement copyWith.
  @override
  Annuncio copyWith({
    String? id,
    String? creatoreRef,
    TipoAnnuncio? tipo,
    String? nome,
    String? sesso,
    double? peso,
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
