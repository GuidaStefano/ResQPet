import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqpet/controllers/dati_utente_controller.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/repositories/auth_repository.dart';
import 'package:resqpet/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'signin_controller.g.dart';

sealed class SignInState {
  SignInState();

  factory SignInState.idle() = SignInIdle;
  factory SignInState.success() = SignInSuccess;
  factory SignInState.error(String error) = SignInError;
  factory SignInState.loading() = SignInLoading;
}

class SignInIdle extends SignInState {}
class SignInSuccess extends SignInState {}

class SignInError extends SignInState {
  final String error;
  SignInError(this.error);
}

class SignInLoading extends SignInState {}

@riverpod
class SignInController extends _$SignInController {

  late AuthRepository _authRepository;
  late NotificationService _notificationService;

  @override
  SignInState build() {
    _authRepository = ref.read(authRepositoryProvider); 
    _notificationService = ref.read(notificationServiceProvider);
    return SignInState.idle();
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = SignInState.loading();
      
      await _authRepository.signIn(email, password);
      final utente = await ref.read(datiUtenteProvider.future);
      
      if(utente.tipo == TipoUtente.soccorritore) {
        await _notificationService.subscriptToTopic();
      }

      state = SignInState.success();
    } on FirebaseAuthException catch(e) {
      state = SignInState.error(e.message ?? "Errore con le credenziali");
    }
  }
}