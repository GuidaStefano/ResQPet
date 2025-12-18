import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/utente.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dati_utente_controller.g.dart';

@riverpod
Future<Utente> datiUtente(Ref ref) async {
  final utenteRepository = ref.read(utenteRepositoryProvider);
  final utente = await utenteRepository.getUtenteInfo();

  if(utente == null) {
    throw StateError("Errore nel caricamento dei dati utente.");
  }

  return utente;
}