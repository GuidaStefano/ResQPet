import 'dart:io';

import 'package:latlong2/latlong.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/segnalazione.dart';
import 'package:resqpet/repositories/segnalazione_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'segnalazioni_controller.g.dart';

@riverpod
Stream<List<Segnalazione>> segnalazioniVicine(Ref ref, LatLng currentPosition) {
  final segnalazioniRepository = ref.read(segnalazioneRepositoryProvider);

  return segnalazioniRepository.getSegnalazioniVicine(
    currentPosition.latitude,
    currentPosition.longitude
  );
}

@riverpod
Stream<List<Segnalazione>> segnalazioniDaRisolvere(Ref ref) {
  final segnalazioniRepository = ref.read(segnalazioneRepositoryProvider);
  return segnalazioniRepository.getSegnalazioniStream(StatoSegnalazione.presoInCarica);
}

@riverpod
Stream<List<Segnalazione>> segnalazioni(Ref ref) {
  final segnalazioniRepository = ref.read(segnalazioneRepositoryProvider);
  return segnalazioniRepository.getSegnalazioniStream();
}

@riverpod
Stream<List<Segnalazione>> segnalazioneCreate(Ref ref) {
  final segnalazioniRepository = ref.read(segnalazioneRepositoryProvider);
  return segnalazioniRepository.getSegnalazioniCreateByCittadino();
}

@riverpod
Stream<List<Segnalazione>> segnalazioniInCarico(Ref ref) {
  final segnalazioniRepository = ref.read(segnalazioneRepositoryProvider);
  return segnalazioniRepository.getIncarichiSoccorritore();
}

sealed class SegnalazioneState {
  const SegnalazioneState();

  factory SegnalazioneState.idle() = SegnalazioneIdle;
  factory SegnalazioneState.loading() = SegnalazioneLoading;
  factory SegnalazioneState.success() = SegnalazioneSuccess;
  factory SegnalazioneState.error(String message) = SegnalazioneError;
}

class SegnalazioneIdle extends SegnalazioneState {}
class SegnalazioneLoading extends SegnalazioneState {}
class SegnalazioneSuccess extends SegnalazioneState {}

class SegnalazioneError extends SegnalazioneState {
  final String message;
  const SegnalazioneError(this.message);
}

@riverpod
class SegnalazioneController extends _$SegnalazioneController {

  late final SegnalazioneRepository _segnalazioneRepository;

  @override
  SegnalazioneState build() {
    _segnalazioneRepository = ref.read(segnalazioneRepositoryProvider);
    return SegnalazioneState.idle();
  }

  Future<void> creaSegnalazione({
    required String descrizione,
    required LatLng coordinate,
    required String indirizzo,
    required List<File> foto
  }) async {

    try {

      state = SegnalazioneState.loading();

      await _segnalazioneRepository.creaSegnalazione(
        descrizione: descrizione, 
        latitudine: coordinate.latitude, 
        longitudine: coordinate.longitude, 
        indirizzo: indirizzo, 
        foto: foto
      );

      state = SegnalazioneState.success();
    } on ArgumentError catch(e) {
      state = SegnalazioneState.error(e.message);
    } on StateError catch(e) {
      state = SegnalazioneState.error(e.message);
    } catch(_) {
      state = SegnalazioneState.error("Errore durante la creazione dells segnalazione.");
    }
  }

  Future<void> abbandonaIncarico(String segnalazioneId) async {

    try {

      state = SegnalazioneState.loading();
      await _segnalazioneRepository.rinunciaSegnalazione(segnalazioneId);
      state = SegnalazioneState.success();
    } on ArgumentError catch(e) {
      state = SegnalazioneState.error(e.message);
    } on StateError catch(e) {
      state = SegnalazioneState.error(e.message);
    } catch(_) {
      state = SegnalazioneState.error("Errore durante la rinuncia della segnalazione.");
    }
  }

  Future<void> cancellaSegnalazione(String segnalazioneId) async {

    try {

      state = SegnalazioneState.loading();
      await _segnalazioneRepository.cancellaSegnalazione(segnalazioneId);
      state = SegnalazioneState.success();
    } on StateError catch(e) {
      state = SegnalazioneState.error(e.message);
    } catch(_) {
      state = SegnalazioneState.error("Errore durante la cancellazione della segnalazione.");
    }
  }


  Future<void> risolviSegnalazione(String segnalazioneId) async {

    try {
      state = SegnalazioneState.loading();
      await _segnalazioneRepository.risolviSegnalazione(segnalazioneId);
      state = SegnalazioneState.success();
    } on StateError catch(e) {
      state = SegnalazioneState.error(e.message);
    } catch(_) {
      state = SegnalazioneState.error("Errore durante la finalizzazione della segnalazione.");
    }
  }

  Future<void> prendiInCarico(String segnalazioneId) async {
    try {
      state = SegnalazioneState.loading();
      await _segnalazioneRepository.prendiInCaricoSegnalazione(segnalazioneId);
      state = SegnalazioneState.success();
    } on ArgumentError catch(e) {
      state = SegnalazioneState.error(e.message);
    } on StateError catch(e) {
      state = SegnalazioneState.error(e.message);
    } catch(_) {
      state = SegnalazioneState.error("Errore durante la presa in carico della segnalazione.");
    }
  }
}