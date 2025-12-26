import 'package:firebase_auth/firebase_auth.dart';
import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/repositories/auth_repository.dart';
import 'package:resqpet/repositories/utente_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'utente_controller.g.dart';

@riverpod
Stream<List<Utente>> utenti(Ref ref) {
  final utenteRepository = ref.read(utenteRepositoryProvider);
  return utenteRepository.getAllExceptAdmin();
}

sealed class DeleteAccountState {
  DeleteAccountState();

  factory DeleteAccountState.idle() = DeleteAccountIdle;
  factory DeleteAccountState.error(String message) = DeleteAccountError;
}

class DeleteAccountIdle extends DeleteAccountState {}
class DeleteAccountError extends DeleteAccountState {
  final String message;
  DeleteAccountError(this.message);
}

@riverpod
class DeleteAccountController extends _$DeleteAccountController {
  

  late final UtenteRepository _utenteRepository;

  @override
  DeleteAccountState build() {
    _utenteRepository = ref.read(utenteRepositoryProvider);
    return DeleteAccountState.idle();
  }

  Future<void> deleteAccount(Utente utente) async {
    try {
      await _utenteRepository.cancellaAccountById(utente.id);
      state = DeleteAccountState.idle();
    } catch(e) {
      state = DeleteAccountState.error("Si e' verificato un problema con la rimozione dell'account");
    }
  }
}


sealed class UpdateAccountState {
  UpdateAccountState();

  factory UpdateAccountState.idle() = UpdateAccountIdle;
  factory UpdateAccountState.success() = UpdateAccountSuccess;
  factory UpdateAccountState.loading() = UpdateAccountLoading;
  factory UpdateAccountState.error(String message) = UpdateAccountError;
}

class UpdateAccountIdle extends UpdateAccountState {}
class UpdateAccountSuccess extends UpdateAccountState {}
class UpdateAccountLoading extends UpdateAccountState {}
class UpdateAccountError extends UpdateAccountState {
  final String message;
  UpdateAccountError(this.message);
}

@riverpod
class UpdateAccountController extends _$UpdateAccountController {
  
  late final UtenteRepository _utenteRepository;
  late final AuthRepository _authRepository;

  @override
  UpdateAccountState build() {
    _utenteRepository = ref.read(utenteRepositoryProvider);
    _authRepository = ref.read(authRepositoryProvider);
    return UpdateAccountState.idle();
  }

  Future<void> updatePassword({
    required String email, 
    required String currentPassword,
    required String newPassword
  }) async {
    try {
      state = UpdateAccountState.idle();
      
      await _authRepository.reauthenticate(email, currentPassword);
      await _authRepository.updatePassword(newPassword);
      
      state = UpdateAccountState.success();
    } on FirebaseAuthException catch (e) {
      state = UpdateAccountState.error(e.message ?? "Errore durante l'aggiornamento della password");
    }
  }

  Future<void> updateEmail({
    required Utente utente,
    required String currentPassword,
    required String newEmail
  }) async {
    try {
      state = UpdateAccountState.idle();
      
      await _authRepository.reauthenticate(utente.email, currentPassword);
      
      await _authRepository.updateEmail(newEmail);
      await _utenteRepository.aggiornaProfiloInfo(
        utente.copyWith(
          email: newEmail
        )
      );
      
      state = UpdateAccountState.success();
    } on FirebaseAuthException catch (e) {
      state = UpdateAccountState.error(e.message ?? "Errore durante l'aggiornamento dell'email");
    }
  }

  Future<void> update(Utente utente) async {
    try {
      state = UpdateAccountState.idle();
      _utenteRepository.aggiornaProfiloInfo(utente);
      state = UpdateAccountState.success();
    } on FirebaseAuthException catch (e) {
      state = UpdateAccountState.error(e.message ?? "Errore durante l'aggiornamento dei dati del profilo");
    }
  }

}