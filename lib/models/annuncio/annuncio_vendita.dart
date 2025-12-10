import 'package:cloud_firestore/cloud_firestore.dart';

import 'annuncio.dart';
import 'tipo_annuncio.dart';
import 'stato_annuncio.dart';

/// Represents a sale announcement with specific fields for selling animals.
class AnnuncioVendita extends Annuncio {
  final double prezzo;
  final Timestamp dataNascita;
  final String numeroMicrochip;

  const AnnuncioVendita({
    super.id,
    required super.creatoreRef,
    required super.nome,
    required super.sesso,
    required super.peso,
    required super.colorePelo,
    required super.isSterilizzato,
    required super.specie,
    required super.razza,
    required super.foto,
    required super.statoAnnuncio,
    required this.prezzo,
    required this.dataNascita,
    required this.numeroMicrochip,
  }) : super(tipo: TipoAnnuncio.vendita);

  @override
  Map<String, dynamic> toMap() {
    final base = toMapBase();
    base['dettagli_vendita'] = {
      'prezzo': prezzo,
      'dataNascita': dataNascita,
      'numeroMicrochip': numeroMicrochip,
    };
    return base;
  }

  /// Creates an AnnuncioVendita from a Firestore document map.
  /// The [id] is provided separately (from document reference).
  factory AnnuncioVendita.fromMap(Map<String, dynamic> map, String id) {
    final dettagli = map['dettagli_vendita'] as Map<String, dynamic>? ?? {};

    return AnnuncioVendita(
      id: id,
      creatoreRef: map['creatore_ref'] as String? ?? '',
      nome: map['nome'] as String? ?? '',
      sesso: map['sesso'] as String? ?? '',
      peso: map['peso'] as String? ?? '',
      colorePelo: map['colorePelo'] as String? ?? '',
      isSterilizzato: map['isSterelizzato'] as bool? ?? false,
      specie: map['specie'] as String? ?? '',
      razza: map['razza'] as String? ?? '',
      foto: List<String>.from(map['foto'] ?? []),
      statoAnnuncio: StatoAnnuncio.fromString(
        map['statoAnnuncio'] as String? ?? 'ATTIVO',
      ),
      prezzo: (dettagli['prezzo'] as num?)?.toDouble() ?? 0.0,
      dataNascita: dettagli['dataNascita'] as Timestamp? ?? Timestamp.now(),
      numeroMicrochip: dettagli['numeroMicrochip'] as String? ?? '',
    );
  }

  @override
  AnnuncioVendita copyWith({
    String? id,
    String? creatoreRef,
    TipoAnnuncio? tipo, // Ignored - tipo is fixed for this class
    String? nome,
    String? sesso,
    String? peso,
    String? colorePelo,
    bool? isSterilizzato,
    String? specie,
    String? razza,
    List<String>? foto,
    StatoAnnuncio? statoAnnuncio,
    double? prezzo,
    Timestamp? dataNascita,
    String? numeroMicrochip,
  }) {
    return AnnuncioVendita(
      id: id ?? this.id,
      creatoreRef: creatoreRef ?? this.creatoreRef,
      nome: nome ?? this.nome,
      sesso: sesso ?? this.sesso,
      peso: peso ?? this.peso,
      colorePelo: colorePelo ?? this.colorePelo,
      isSterilizzato: isSterilizzato ?? this.isSterilizzato,
      specie: specie ?? this.specie,
      razza: razza ?? this.razza,
      foto: foto ?? List.from(this.foto),
      statoAnnuncio: statoAnnuncio ?? this.statoAnnuncio,
      prezzo: prezzo ?? this.prezzo,
      dataNascita: dataNascita ?? this.dataNascita,
      numeroMicrochip: numeroMicrochip ?? this.numeroMicrochip,
    );
  }

  @override
  String toString() {
    return 'AnnuncioVendita(id: $id, nome: $nome, prezzo: $prezzo)';
  }
}
