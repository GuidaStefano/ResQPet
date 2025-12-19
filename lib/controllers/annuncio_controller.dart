import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/repositories/annuncio_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'annuncio_controller.g.dart';

@riverpod
Stream<List<Annuncio>> annunci(Ref ref, {
  TipoAnnuncio? tipo,
  StatoAnnuncio stato = StatoAnnuncio.attivo
}) {
  final annuncioRepository = ref.read(annuncioRepositoryProvider);

  return tipo == null
    ? annuncioRepository.getAnnunciByStato(stato)
    : annuncioRepository.getAnnunciByStatoAndTipoStream(stato, tipo);
}

sealed class AnnuncioState {
  const AnnuncioState();

  factory AnnuncioState.idle() = AnnuncioIdle;
  factory AnnuncioState.loading() = AnnuncioLoading;
  factory AnnuncioState.success() = AnnuncioSuccess;
  factory AnnuncioState.error(String message) = AnnuncioError;
}

final class AnnuncioIdle extends AnnuncioState {}
final class AnnuncioLoading extends AnnuncioState {}
final class AnnuncioSuccess extends AnnuncioState {}

final class AnnuncioError extends AnnuncioState {
  final String message;
  const AnnuncioError(this.message);
}

@riverpod
class AnnuncioController extends _$AnnuncioController {

  late final AnnuncioRepository _annuncioRepository;

  @override
  AnnuncioState build() {
    _annuncioRepository = ref.read(annuncioRepositoryProvider);
    return AnnuncioState.idle();
  }

  Future<void> deleteAnnuncio(Annuncio annuncio) async {
    try {
      state = AnnuncioState.loading();
      final isSuccess = await _annuncioRepository.cancellaAnnuncio(annuncio.id);
      state = isSuccess 
        ? AnnuncioState.success()
        : AnnuncioState.error("Si e' verificato un problema con la rimozione dell'annuncio");
    } catch(e) {
      state = AnnuncioState.error("Si e' verificato un problema con la rimozione dell'annuncio");
    }
  }

  Future<void> creaAnnuncio(Annuncio annuncio) async {
    try {
      state = AnnuncioState.loading();
      await _annuncioRepository.creaAnnuncio(annuncio);
      state = AnnuncioState.success();
    } catch(e) {
      state = AnnuncioState.error("Si e' verificato un problema con la creazione dell'annuncio");
    }
  }

  Future<void> finalizzaAnnuncio(Annuncio annuncio) async {
    try {
      state = AnnuncioState.loading();
      await _annuncioRepository.finalizzaAnnuncio(annuncio.id);
      state = AnnuncioState.success();
    } catch(e) {
      state = AnnuncioState.error("Si e' verificato un problema con la finalizzazione dell'annuncio");
    }
  }

  Future<void> aggiornaAnnuncio(Annuncio annuncio) async {
    try {
      state = AnnuncioState.loading();
      await _annuncioRepository.aggiornaAnnuncio(annuncio);
      state = AnnuncioState.success();
    } catch(e) {
      state = AnnuncioState.error("Si e' verificato un problema con l'aggiornamento dell'annuncio");
    }
  }
}