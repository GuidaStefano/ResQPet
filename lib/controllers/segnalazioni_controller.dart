import 'package:latlong2/latlong.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/segnalazione.dart';
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