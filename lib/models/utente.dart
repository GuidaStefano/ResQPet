import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoUtente {

  cittadino('Cittadino'),
  soccorritore('Soccorritore'),
  venditore('Venditore'),
  ente('Ente'),
  admin('Admin');

  const TipoUtente(this.value);

  final String value;

  factory TipoUtente.fromString(String tipo) =>
    TipoUtente.values.firstWhere(
      (e) => e.value == tipo,
      orElse: () => throw ArgumentError("TipoUtente non valido: $tipo")
    );

  String toFirestore() => value;
}

class Utente {
  final String id;
  final String nominativo;
  final String email;
  final String numeroTelefono;
  final Timestamp dataCreazione;
  final TipoUtente tipo;

  Utente({
    required this.id,
    required this.nominativo,
    required this.email,
    required this.dataCreazione,
    required this.tipo,
    required this.numeroTelefono,
  });

  factory Utente.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data");
    }

    if(data['tipo'] == null) {
      throw ArgumentError.notNull("data['tipo']");
    }

    final tipo = TipoUtente.fromString(data['tipo']);

    return switch(tipo) {
      TipoUtente.ente => Ente.fromFirestore(snapshot, options),
      TipoUtente.venditore => Venditore.fromFirestore(snapshot, options),
      _ => Utente(
        id: snapshot.id,
        nominativo: data['nominativo'] ?? '',
        email: data['email'] ?? '',
        dataCreazione: data['dataCreazione'] as Timestamp? ?? Timestamp.now(),
        tipo: tipo,
        numeroTelefono: data['numeroTelefono'] ?? '',
      )
    };
  }

  Utente copyWith({
    String? id,
    String? nominativo,
    String? email,
    Timestamp? dataCreazione,
    TipoUtente? tipo,
    String? numeroTelefono
  }) => Utente(
    id: id ?? this.id,
    nominativo: nominativo ?? this.nominativo,
    email: email ?? this.email,
    tipo: tipo ?? this.tipo,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    numeroTelefono: numeroTelefono ?? this.numeroTelefono
  );

  Map<String, dynamic> toFirestore() {
    return {
      'nominativo': nominativo,
      'email': email,
      'dataCreazione': dataCreazione,
      'tipo': tipo.toFirestore(),
      'numeroTelefono': numeroTelefono,
    };
  }

}

class Ente extends Utente {
  final String sedeLegale;
  final String partitaIVA;

  Ente({
    required super.id,
    required super.nominativo,
    required super.email,
    required super.dataCreazione,
    required super.numeroTelefono,
    required this.sedeLegale,
    required this.partitaIVA,
  }) : super(tipo: TipoUtente.ente);

  factory Ente.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data");
    }

    final dettagliEnte = data['dettagli_ente'];
    if(dettagliEnte == null) {
      throw ArgumentError.notNull("dettagliEnte");
    }

    return Ente(
      id: snapshot.id,
      nominativo: data['nominativo'] ?? '',
      email: data['email'] ?? '',
      dataCreazione: data['dataCreazione'] as Timestamp? ?? Timestamp.now(),
      numeroTelefono: data['numeroTelefono'] ?? '',
      sedeLegale: dettagliEnte['sedeLegale'] ?? '',
      partitaIVA: dettagliEnte['partitaIVA'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final map = super.toFirestore();
    
    map['dettagli_ente'] = {
      'sedeLegale': sedeLegale,
      'partitaIVA': partitaIVA
    };
    
    return map;
  }

  @override
  Utente copyWith({
    String? id, 
    String? nominativo,
    String? email,
    Timestamp? dataCreazione,
    TipoUtente? tipo, // Ignored - tipo is fixed for this class
    String? numeroTelefono,
    String? sedeLegale,
    String? partitaIVA
  }) => Ente(
    id: id ?? this.id,
    nominativo: nominativo ?? this.nominativo,
    email: email ?? this.email,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    numeroTelefono: numeroTelefono ?? this.numeroTelefono,
    sedeLegale: sedeLegale ?? this.sedeLegale,
    partitaIVA: partitaIVA ?? this.partitaIVA
  );
}

class Venditore extends Utente {
  final String partitaIVA;
  final String indirizzo;
  final Timestamp dataSottoscrizioneAbbonamento;
  final String abbonamentoRef;

  Venditore({
    required super.id,
    required super.nominativo,
    required super.email,
    required super.dataCreazione,
    required super.numeroTelefono,
    required this.partitaIVA,
    required this.indirizzo,
    required this.dataSottoscrizioneAbbonamento,
    required this.abbonamentoRef,
  }) : super(tipo: TipoUtente.venditore);

  factory Venditore.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data");
    }

    final dettagliVenditore = data['dettagli_venditore'];
    if(dettagliVenditore == null) {
      throw ArgumentError.notNull("dettagliVenditore");
    }

    return Venditore(
      id: snapshot.id,
      nominativo: data['nominativo'] ?? '',
      email: data['email'] ?? '',
      dataCreazione: data['dataCreazione'] as Timestamp? ?? Timestamp.now(),
      numeroTelefono: data['numeroTelefono'] ?? '',
      partitaIVA: dettagliVenditore['partitaIVA'] ?? '',
      indirizzo: dettagliVenditore['indirizzo'] ?? '',
      dataSottoscrizioneAbbonamento:
        dettagliVenditore['dataSottoscrizioneAbbonamento'] as Timestamp? ?? Timestamp.now(),
      abbonamentoRef: dettagliVenditore['abbonamento_ref'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final map = super.toFirestore();
    
    map['dettagli_venditore'] = {
      'partitaIVA': partitaIVA,
      'indirizzo': indirizzo,
      'dataSottoscrizioneAbbonamento': dataSottoscrizioneAbbonamento,
      'abbonamento_ref': abbonamentoRef,
    };

    return map;
  }

    @override
  Utente copyWith({
    String? id, 
    String? nominativo,
    String? email,
    Timestamp? dataCreazione,
    TipoUtente? tipo, // Ignored - tipo is fixed for this class
    String? numeroTelefono,
    String? partitaIVA,
    String? indirizzo,
    Timestamp? dataSottoscrizioneAbbonamento,
    String? abbonamentoRef
  }) => Venditore(
    id: id ?? this.id,
    nominativo: nominativo ?? this.nominativo,
    email: email ?? this.email,
    dataCreazione: dataCreazione ?? this.dataCreazione,
    numeroTelefono: numeroTelefono ?? this.numeroTelefono,
    partitaIVA: partitaIVA ?? this.partitaIVA,
    indirizzo: indirizzo ?? this.indirizzo,
    dataSottoscrizioneAbbonamento: dataSottoscrizioneAbbonamento ?? this.dataSottoscrizioneAbbonamento,
    abbonamentoRef: abbonamentoRef ?? this.abbonamentoRef
  );
}
