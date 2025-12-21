import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/repositories/stripe_repository.dart';
import 'package:resqpet/repositories/utente_repository.dart';
import 'package:resqpet/services/stripe_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signup_controller.g.dart';

sealed class SignUpState {
  SignUpState();

  factory SignUpState.idle() = SignUpIdle;
  factory SignUpState.success() = SignUpSuccess;
  factory SignUpState.error(String error) = SignUpError;
  factory SignUpState.loading() = SignUpLoading;
}

class SignUpIdle extends SignUpState {}
class SignUpSuccess extends SignUpState {}

class SignUpError extends SignUpState {
  final String error;
  SignUpError(this.error);
}

class SignUpLoading extends SignUpState {}

@riverpod
class SignUpController extends _$SignUpController {

  late UtenteRepository _utenteRepository;
  late StripeRepository _stripeRepository;

  @override
  SignUpState build() {
    
    _utenteRepository = ref.read(utenteRepositoryProvider);
    _stripeRepository = ref.read(stripeRepositoryProvider);

    return SignUpState.idle();
  }

  Future<void> registraUtente(TipoUtente tipo, Map<String, dynamic> dati) async {

    state = SignUpState.loading();

    try {

      final String nominativo = dati['nominativo'] as String;
      final String email = dati['email'] as String;
      final String password = dati['password'] as String;
      final String numeroTelefono = dati['numeroTelefono'] as String;

      switch(tipo) {
        case TipoUtente.cittadino:
          await _utenteRepository.registraCittadino(
            email: email, 
            password: password, 
            nominativo: nominativo,
            numeroTelefono: numeroTelefono
          );
          state = SignUpState.success();
          return;
        case TipoUtente.soccorritore:
          await _utenteRepository.registraSoccorritore(
            email: email, 
            password: password, 
            nominativo: nominativo, 
            numeroTelefono: numeroTelefono
          );
          state = SignUpState.success();
          return;
        case TipoUtente.venditore: {

          final String partitaIVA = dati['partitaIVA'] as String;
          final String indirizzo = dati['indirizzo'] as String;
          final String abbonamentoRef = dati['abbonamentoRef'] as String;
          final double prezzoAbbonamento = dati['prezzoAbbonamento'] as double;

          await _utenteRepository.registraVenditore(
            email: email, 
            password: password, 
            nominativo: nominativo, 
            numeroTelefono: numeroTelefono,
            partitaIVA: partitaIVA,
            indirizzo: indirizzo,
            abbonamentoRef: abbonamentoRef
          );

          await _stripeRepository.creaSessioneCheckout(prezzoAbbonamento.toString());
          final status = await _stripeRepository.effettuaPagamento();

          state = switch(status) {
            StripePaymentError(:final exception) => SignUpState.error(
              exception.error.message ?? "Si e' verificato un problema con il pagamento!"
            ),
            StripePaymentSuccess() => SignUpState.success()
          };
          return;
        }
        default:
          state = SignUpState.error("Errore account non valido.");
      }
    } on FirebaseAuthException catch (e) {
      state = SignUpState.error(e.message ?? "Si e' verificato un errore durante la registrazione!");
    } on Exception catch (_) {
      state = SignUpState.error("Si e' verificato un errore durante la registrazione!");
    }
  }
}