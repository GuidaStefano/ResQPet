import 'package:cloud_firestore/cloud_firestore.dart';

import 'annuncio.dart';
import 'tipo_annuncio.dart';
import 'stato_annuncio.dart';

/// Represents an adoption announcement with specific fields for animal adoption.
class AnnuncioAdozione extends Annuncio {
  final String storia;
  final String noteSanitarie;
  final String contributoSpeseSanitarie;
  final String carattere;

  const AnnuncioAdozione({
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
    required this.storia,
    required this.noteSanitarie,
    required this.contributoSpeseSanitarie,
    required this.carattere,
  }) : super(tipo: TipoAnnuncio.adozione);

  @override
  Map<String, dynamic> toFirestore() {
    final base = toFirestoreBase();
    base['dettagli_adozione'] = {
      'storia': storia,
      'noteSanitarie': noteSanitarie,
      'contributoSpeseSanitarie': contributoSpeseSanitarie,
      'carattere': carattere,
    };
    return base;
  }

  /// Creates an AnnuncioAdozione from a Firestore document map.
  /// The [id] is provided separately (from document reference).
  factory AnnuncioAdozione.fromMap(Map<String, dynamic> map, String id) {
    final dettagli = map['dettagli_adozione'] as Map<String, dynamic>? ?? {};

    return AnnuncioAdozione(
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
      storia: dettagli['storia'] as String? ?? '',
      noteSanitarie: dettagli['noteSanitarie'] as String? ?? '',
      contributoSpeseSanitarie:
          dettagli['contributoSpeseSanitarie'] as String? ?? '',
      carattere: dettagli['carattere'] as String? ?? '',
    );
  }

  /// Creates an AnnuncioAdozione directly from a Firestore DocumentSnapshot.
  factory AnnuncioAdozione.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Document snapshot has no data');
    }
    return AnnuncioAdozione.fromMap(data, snapshot.id);
  }

  @override
  AnnuncioAdozione copyWith({
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
    String? storia,
    String? noteSanitarie,
    String? contributoSpeseSanitarie,
    String? carattere,
  }) {
    return AnnuncioAdozione(
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
      storia: storia ?? this.storia,
      noteSanitarie: noteSanitarie ?? this.noteSanitarie,
      contributoSpeseSanitarie:
          contributoSpeseSanitarie ?? this.contributoSpeseSanitarie,
      carattere: carattere ?? this.carattere,
    );
  }

  @override
  String toString() {
    return 'AnnuncioAdozione(id: $id, nome: $nome, carattere: $carattere)';
  }
}
