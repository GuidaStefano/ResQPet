import 'package:cloud_firestore/cloud_firestore.dart';

class Utente {
  final String id;
  final String nominativo;
  final String email;
  final String password;
  final Timestamp dataCreazione;
  final String tipo;
  final String numeroTelefono;

  Utente({
    required this.id,
    required this.nominativo,
    required this.email,
    required this.password,
    required this.dataCreazione,
    required this.tipo,
    required this.numeroTelefono,
  });

  factory Utente.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final tipo = data?['tipo'] as String? ?? 'Cittadino';

    if (tipo == 'Ente') {
      return Ente.fromFirestore(snapshot, options);
    } else if (tipo == 'Venditore') {
      return Venditore.fromFirestore(snapshot, options);
    } else {
      return Utente(
        id: snapshot.id,
        nominativo: data?['nominativo'] ?? '',
        email: data?['email'] ?? '',
        password: data?['password'] ?? '',
        dataCreazione: data?['dataCreazione'] as Timestamp? ?? Timestamp.now(),
        tipo: tipo,
        numeroTelefono: data?['numeroTelefono'] ?? '',
      );
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'nominativo': nominativo,
      'email': email,
      'password': password,
      'dataCreazione': dataCreazione,
      'tipo': tipo,
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
    required super.password,
    required super.dataCreazione,
    required super.numeroTelefono,
    required this.sedeLegale,
    required this.partitaIVA,
  }) : super(tipo: 'Ente');

  factory Ente.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final dettagli = data?['dettagli_ente'] as Map<String, dynamic>? ?? {};

    return Ente(
      id: snapshot.id,
      nominativo: data?['nominativo'] ?? '',
      email: data?['email'] ?? '',
      password: data?['password'] ?? '',
      dataCreazione: data?['dataCreazione'] as Timestamp? ?? Timestamp.now(),
      numeroTelefono: data?['numeroTelefono'] ?? '',
      sedeLegale: dettagli['sedeLegale'] ?? '',
      partitaIVA: dettagli['partitaIVA'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final map = super.toFirestore();
    map['dettagli_ente'] = {'sedeLegale': sedeLegale, 'partitaIVA': partitaIVA};
    return map;
  }
}

class Venditore extends Utente {
  final String partitaIVA;
  final String indirizzo;
  final Timestamp? dataSottoscrizioneAbbonamento;
  final String abbonamentoRef;

  Venditore({
    required super.id,
    required super.nominativo,
    required super.email,
    required super.password,
    required super.dataCreazione,
    required super.numeroTelefono,
    required this.partitaIVA,
    required this.indirizzo,
    this.dataSottoscrizioneAbbonamento,
    required this.abbonamentoRef,
  }) : super(tipo: 'Venditore');

  factory Venditore.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    final dettagli = data?['dettagli_venditore'] as Map<String, dynamic>? ?? {};

    return Venditore(
      id: snapshot.id,
      nominativo: data?['nominativo'] ?? '',
      email: data?['email'] ?? '',
      password: data?['password'] ?? '',
      dataCreazione: data?['dataCreazione'] as Timestamp? ?? Timestamp.now(),
      numeroTelefono: data?['numeroTelefono'] ?? '',
      partitaIVA: dettagli['partitaIVA'] ?? '',
      indirizzo: dettagli['indirizzo'] ?? '',
      dataSottoscrizioneAbbonamento:
          dettagli['dataSottoscrizioneAbbonamento'] as Timestamp?,
      abbonamentoRef: dettagli['abbonamento_ref'] ?? '',
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
}
