import 'package:cloud_firestore/cloud_firestore.dart';

class Segnalazione {
  final String? id;
  final List<String> foto;
  final String descrizione;
  final GeoPoint posizione;
  final Timestamp dataCreazione;
  final String stato;
  final String indirizzo;
  // Riferimento al soccorritore (opzionale, es. all'inizio è null)
  final String? soccorritoreRef;
  // Riferimento al cittadino
  final String cittadinoRef;

  Segnalazione({
    this.id,
    required this.foto,
    required this.descrizione,
    required this.posizione,
    required this.dataCreazione,
    required this.stato,
    required this.indirizzo,
    this.soccorritoreRef,
    required this.cittadinoRef,
  });

  factory Segnalazione.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Segnalazione(
      id: snapshot.id,
      foto: data?['foto'] is Iterable ? List<String>.from(data?['foto']) : [],
      descrizione: data?['descrizione'] ?? '',
      // Fallback a 0,0 se manca la posizione, per evitare crash
      posizione: data?['posizione'] ?? const GeoPoint(0, 0),
      dataCreazione: data?['dataCreazione'] ?? Timestamp.now(),
      stato: data?['stato'] ?? 'in attesa',
      indirizzo: data?['indirizzo'] ?? '',
      soccorritoreRef: data?['soccorritore_ref'],
      // Importante: recuperiamo il riferimento al cittadino
      cittadinoRef: data?['cittadino_ref'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'foto': foto,
      'descrizione': descrizione,
      'posizione': posizione,
      'dataCreazione': dataCreazione,
      'stato': stato,
      'indirizzo': indirizzo,
      'soccorritore_ref': soccorritoreRef,
      'cittadino_ref': cittadinoRef,
    };
  }
}
