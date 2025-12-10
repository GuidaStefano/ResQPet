import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/core/adapters/firestore_adapter.dart';
import 'package:resqpet/core/utils/copyable.dart';

enum StatoSegnalazione {
  inAttesa('in attesa'),
  presoInCarica('preso in carica'),
  risolto('risolto');

  const StatoSegnalazione(this.value);
  final String value;

  factory StatoSegnalazione.fromString(String stato)
    => StatoSegnalazione.values.firstWhere(
      (e) => e.value == stato,
      orElse: () => throw ArgumentError("StatoSegnalazione invalido: $stato")
    );

  String toFirestore() => value;
}

class Segnalazione implements Copyable<Segnalazione>{
  final String id;
  final List<String> foto;
  final String descrizione;
  final GeoPoint posizione;
  final Timestamp dataCreazione;
  final StatoSegnalazione stato;
  final String indirizzo;
  // Riferimento al soccorritore (opzionale, es. all'inizio è null)
  final String? soccorritoreRef;
  // Riferimento al cittadino
  final String cittadinoRef;

  Segnalazione({
    this.id = '',
    required this.foto,
    required this.descrizione,
    required this.posizione,
    required this.dataCreazione,
    required this.stato,
    required this.indirizzo,
    this.soccorritoreRef,
    required this.cittadinoRef,
  });

  @override
  Segnalazione copyWith({
    String? id,
    List<String>? foto,
    String? descrizione,
    GeoPoint? posizione,
    Timestamp? dataCreazione,
    StatoSegnalazione? stato,
    String? indirizzo,
    String? soccorritoreRef,
    bool resetSoccorritoreRef = false,
    String? cittadinoRef,
  }) {
    return Segnalazione(
      id: id ?? this.id,
      foto: foto ?? this.foto,
      descrizione: descrizione ?? this.descrizione,
      posizione: posizione ?? this.posizione,
      dataCreazione: dataCreazione ?? this.dataCreazione,
      stato: stato ?? this.stato,
      indirizzo: indirizzo ?? this.indirizzo,
      soccorritoreRef: resetSoccorritoreRef 
        ? null 
        : (soccorritoreRef ?? this.soccorritoreRef),
      cittadinoRef: cittadinoRef ?? this.cittadinoRef,
    );
  }
}

class SegnalazioneFirestoreAdapter implements FirestoreAdapter<Segnalazione> {
  @override
  Segnalazione fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    [SnapshotOptions? options]
  ) {
    final data = snapshot.data();

    if(data == null) {
      throw ArgumentError.notNull("snapshot.data()");
    }

    return Segnalazione(
      id: snapshot.id,
      foto: List<String>.from(data['foto'] ?? []),
      descrizione: data['descrizione'] ?? '',
      posizione: data['posizione'] ?? const GeoPoint(0, 0),
      dataCreazione: data['dataCreazione'] ?? Timestamp.now(),
      stato: StatoSegnalazione.fromString(
        data['stato'] ?? StatoSegnalazione.inAttesa.value
      ),
      indirizzo: data['indirizzo'] ?? '',
      soccorritoreRef: data['soccorritore_ref'],
      cittadinoRef: data['cittadino_ref'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toFirestore(Segnalazione segnalazione) {
    return {
      'foto': segnalazione.foto,
      'descrizione': segnalazione.descrizione,
      'posizione': segnalazione.posizione,
      'dataCreazione': segnalazione.dataCreazione,
      'stato': segnalazione.stato.toFirestore(),
      'indirizzo': segnalazione.indirizzo,
      'soccorritore_ref': segnalazione.soccorritoreRef,
      'cittadino_ref': segnalazione.cittadinoRef,
    };
  }
}