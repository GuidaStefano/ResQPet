import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/repositories/abbonamento_repository.dart';
import 'package:resqpet/repositories/stripe_repository.dart';
import 'package:resqpet/services/stripe_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'abbonamento_controller.g.dart';

@Riverpod(keepAlive: true)
Future<List<Abbonamento>> abbonamenti(Ref ref) async {
  final abbonamentoRepository = ref.read(abbonamentoRepositoryProvider);
  return abbonamentoRepository.getAll();
}

@Riverpod(keepAlive: true)
Future<Abbonamento> abbonamento(Ref ref) async {
  return ref.read(abbonamentoRepositoryProvider)
    .getAbbonamento();
}

@Riverpod(keepAlive: true)
Future<bool> isAbbonamentoExpired(Ref ref) async {
  return ref.read(abbonamentoRepositoryProvider)
    .isAbbonamentoScaduto();
}

@Riverpod(keepAlive: true)
class AbbonamentoController  extends _$AbbonamentoController {

  @override
  dynamic build() {}

  Future<bool> canPublishMoreAd() async {
    final authService = ref.read(authServiceProvider);
    final abbonamento = await ref.read(abbonamentoProvider.future);

    final annunci = await ref.read(annuncioRepositoryProvider)
      .getAnnunciByCreatore(authService.currentUser!.uid);

    return annunci.length < abbonamento.maxAnnunciVendita;
  }
}

sealed class AbbonamentoState {
  const AbbonamentoState();

  factory AbbonamentoState.idle() = AbbonamentoIdle;
  factory AbbonamentoState.loading() = AbbonamentoLoading;
  factory AbbonamentoState.success() = AbbonamentoSuccess;
  factory AbbonamentoState.error(String message) = AbbonamentoError;
}

class AbbonamentoIdle extends AbbonamentoState {}
class AbbonamentoLoading extends AbbonamentoState {}
class AbbonamentoSuccess extends AbbonamentoState {}

class AbbonamentoError extends AbbonamentoState {
  final String message;

  const AbbonamentoError(this.message);
}

@riverpod
class AttivaAbbonamentoController extends _$AttivaAbbonamentoController {

  late AbbonamentoRepository _abbonamentoRepository;
  late StripeRepository _stripeRepository;

  @override
  AbbonamentoState build() {
    _stripeRepository = ref.read(stripeRepositoryProvider);
    _abbonamentoRepository = ref.read(abbonamentoRepositoryProvider);

    return AbbonamentoState.idle();
  }

  Future<void> attivaAbbonamento(Abbonamento abbonamento) async {
    try {
      state = AbbonamentoState.loading();

      await _stripeRepository.creaSessioneCheckout(abbonamento.prezzo);
      final status = await _stripeRepository.effettuaPagamento();

      if(status is StripePaymentError) {
        state = AbbonamentoState.error(status.exception.error.message ?? "Errore con il pagamento");
        return;
      }

      await _abbonamentoRepository.attivaAbbonamento(abbonamento.id);
      state = AbbonamentoState.success();

      ref.invalidate(abbonamentoProvider);
    } catch (e) {
      
      state = AbbonamentoState.error("Errore con l'attivazione dell'abbonamento");
    }
  }
}