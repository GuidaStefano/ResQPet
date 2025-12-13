import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/dao/segnalazione_dao.dart';
import 'package:resqpet/models/segnalazione.dart';
import 'package:resqpet/services/auth_service.dart';
import 'package:resqpet/services/cloud_storage_service.dart';

class SegnalazioneRepository {

  final SegnalazioneDao dao;
  final CloudStorageService storageService;
  final AuthService authService;

  SegnalazioneRepository({
    required this.dao,
    required this.storageService,
    required this.authService
  });

  Future<Segnalazione> creaSegnalazione({
    required String descrizione,
    required double latitudine,
    required double longitudine,
    required String indirizzo,
    required List<File> foto
  }) async {

    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("L'utente deve essere autenticato per poter aprire una segnalazione");
    }

    final List<String> pathFoto = [];
    for(final fileFoto in foto) {
      pathFoto.add(await storageService.uploadFile(fileFoto));
    }

    try {
      return await dao.create(
        Segnalazione(
          descrizione: descrizione,
          foto: pathFoto,
          dataCreazione: Timestamp.now(),
          posizione: GeoPoint(latitudine, longitudine),
          stato: StatoSegnalazione.inAttesa,
          indirizzo: indirizzo,
          cittadinoRef: uid
        )
      );
    } catch(e) {

      for(final path in pathFoto) {
        await storageService.deleteFile(path);
      }

      throw StateError("Errore nell'apertura della segnalazione!");
    }
  }

  Stream<List<Segnalazione>> getSegnalazioniVicine(double latitudine, double longitudine) {

    const distanceKm = 30.0;

    return dao.findByStatoStream(StatoSegnalazione.inAttesa)
      .map((segnalazioni) {
        return segnalazioni.where((segnalazione) {

          final distance = Distance();

          final km = distance.as(
            LengthUnit.Kilometer,
            LatLng(
              latitudine,
              longitudine
            ),
            LatLng(
              segnalazione.posizione.latitude,
              segnalazione.posizione.longitude
            )
          );

          return km <= distanceKm;
        }).toList();
      });
  }


  Future<void> prendiInCaricoSegnalazione(String segnalazioneId) async {
    
    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il soccoritore deve essere autenticato.");
    }

    Segnalazione? segnalazione = await dao.findById(segnalazioneId);

    if(segnalazione == null) {
      throw StateError("Segnalazione non trovata");
    }

    await dao.update(
      segnalazione.copyWith(
        soccorritoreRef: uid,
        stato: StatoSegnalazione.presoInCarica
      )
    );
  }

  Future<void> rinunciaSegnalazione(String segnalazioneId) async {
    
    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il soccorritore deve essere autenticato.");
    }

    Segnalazione? segnalazione = await dao.findById(segnalazioneId);

    if(segnalazione == null) {
      throw StateError("Segnalazione non trovata");
    }

    await dao.update(
      segnalazione.copyWith(
        soccorritoreRef: null,
        stato: StatoSegnalazione.inAttesa
      )
    );
  }

  Stream<List<Segnalazione>> getSegnalazioniStream() {
    return dao.findByStatoStream(StatoSegnalazione.inAttesa);
  }

  Future<List<Segnalazione>> getSegnalazioniCreateByCittadino() async {

    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il cittadino deve essere autenticato.");
    }

    return (await dao.findByCittadino(uid))
      .where((s) => s.stato == StatoSegnalazione.inAttesa)
      .toList();
  }

  Future<List<Segnalazione>> getIncarichiSoccorritore() async {

    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il soccorritore deve essere autenticato.");
    }

    return await dao.findBySoccorritore(uid);
  }

  Future<Segnalazione> risolviSegnalazione(String segnalazioneId) async {
    final segnalazione = await dao.findById(segnalazioneId);

    if(segnalazione == null) {
      throw StateError("Segnalazione non trovata.");
    }

    await dao.deleteById(segnalazioneId);
    return segnalazione.copyWith(stato: StatoSegnalazione.risolto);
  }

  Future<bool> cancellaSegnalazione(String segnalazioneId) async  {
    final segnalazione =  await dao.findById(segnalazioneId);

    if(segnalazione == null) {
      throw StateError("Segnalazione non trovata.");
    }

    try {
      for(final path in segnalazione.foto) {
        await storageService.deleteFile(path);
      }
    } catch(_) {

    }

    return await dao.deleteById(segnalazioneId);
  }
}
