import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/core/utils/functions.dart';
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

    if (descrizione.trim().isEmpty) {
      throw ArgumentError.value(
        descrizione,
        'descrizione',
        'La descrizione non può essere vuota',
      );
    }

    if (indirizzo.trim().isEmpty) {
      throw ArgumentError.value(
        indirizzo,
        'indirizzo',
        'L\'indirizzo non può essere vuoto',
      );
    }

    if (!isValidLatitude(latitudine)) {
      throw ArgumentError.value(
        latitudine,
        'latitudine',
        'La latitudine è fuori range',
      );
    }

    if (!isValidLongitude(longitudine)) {
      throw ArgumentError.value(
        longitudine,
        'longitudine',
        'La longitudine è fuori range',
      );
    }

    if (foto.isEmpty) {
      throw ArgumentError.value(
        foto,
        'foto',
        'Deve essere fornita almeno una foto',
      );
    }

    if (foto.any((file) => !isJPEG(file.path))) {
      throw ArgumentError.value(
        foto,
        'foto',
        'Tutte le foto devono essere in formato JPEG',
      );
    }

    final List<String> pathFoto = [];
    for (final fileFoto in foto) {
      pathFoto.add(await storageService.uploadFile(fileFoto));
    }

    try {
      return await dao.create(
        Segnalazione(
          descrizione: descrizione.trim(),
          foto: pathFoto,
          dataCreazione: Timestamp.now(),
          posizione: GeoPoint(latitudine, longitudine),
          stato: StatoSegnalazione.inAttesa,
          indirizzo: indirizzo.trim(),
          cittadinoRef: uid,
        ),
      );
    } catch (e) {
      // Rimuovi le foto caricate in caso di errore
      for (final path in pathFoto) {
        await storageService.deleteFile(path);
      }
      
      throw StateError("Errore nell'apertura della segnalazione!");
    }
  }

  Stream<List<Segnalazione>> getSegnalazioniVicine(double latitudine, double longitudine) {

    const distanceKm = 5.0;

    if (!isValidLatitude(latitudine)) {
      throw ArgumentError.value(
        latitudine,
        "latitudine",
        "La latitudine è fuori range",
      );
    }

    if (!isValidLongitude(longitudine)) {
      throw ArgumentError.value(
        longitudine,
        "longitudine",
        "La longitudine è fuori range",
      );
    }

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

  Stream<List<Segnalazione>> getSegnalazioniCreateByCittadino() {

    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il cittadino deve essere autenticato.");
    }

    return  dao.findByCittadino(uid)
      .map(
        (segnalazioni) => 
          segnalazioni.where((s) => s.stato == StatoSegnalazione.inAttesa)
            .toList()
      );
  }

  Stream<List<Segnalazione>> getIncarichiSoccorritore() {

    final uid = authService.currentUser?.uid;

    if(uid == null) {
      throw StateError("Il soccorritore deve essere autenticato.");
    }

    return dao.findBySoccorritore(uid);
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
