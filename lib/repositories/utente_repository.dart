import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:resqpet/dao/utente_dao.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/services/auth_service.dart';

class UtenteRepository {
  final AuthService _authService;
  final UtenteDao _utenteDao;

  UtenteRepository(this._authService, this._utenteDao);

  Future<Utente?> getUtenteInfo() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      return null;
    }
    return _utenteDao.findById(currentUser.uid);
  }

  Future<Utente> aggiornaProfiloInfo(Utente utente) async {
    return _utenteDao.update(utente);
  }

  Future<Utente> registraCittadino({
    required String email,
    required String password,
    required String nominativo,
    required String numeroTelefono,
  }) async {
    return _registraUtente(
      email: email,
      password: password,
      nominativo: nominativo,
      numeroTelefono: numeroTelefono,
      tipo: TipoUtente.cittadino,
    );
  }

  Future<Utente> registraSoccorritore({
    required String email,
    required String password,
    required String nominativo,
    required String numeroTelefono,
  }) async {
    return _registraUtente(
      email: email,
      password: password,
      nominativo: nominativo,
      numeroTelefono: numeroTelefono,
      tipo: TipoUtente.soccorritore,
    );
  }

  Future<Venditore> registraVenditore({
    required String email,
    required String password,
    required String nominativo,
    required String numeroTelefono,
    required String partitaIVA,
    required String indirizzo,
    required String abbonamentoRef,
  }) async {
    final userCredential = await _authService.signUp(email, password);
    final uid = userCredential.user!.uid;

    final venditore = Venditore(
      id: uid,
      nominativo: nominativo,
      email: email,
      numeroTelefono: numeroTelefono,
      dataCreazione: Timestamp.now(),
      partitaIVA: partitaIVA,
      indirizzo: indirizzo,
      dataSottoscrizioneAbbonamento: Timestamp.now(),
      abbonamentoRef: abbonamentoRef,
    );

    await _utenteDao.create(venditore);
    return venditore;
  }

  Future<Ente> registraEnte({
    required String email,
    required String password,
    required String nominativo,
    required String numeroTelefono,
    required String sedeLegale,
    required String partitaIVA,
  }) async {
    final userCredential = await _authService.signUp(email, password);
    final uid = userCredential.user!.uid;

    final ente = Ente(
      id: uid,
      nominativo: nominativo,
      email: email,
      numeroTelefono: numeroTelefono,
      dataCreazione: Timestamp.now(),
      sedeLegale: sedeLegale,
      partitaIVA: partitaIVA,
    );

    await _utenteDao.create(ente);
    return ente;
  }

  Future<void> cancellaAccount() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw StateError('Nessun utente autenticato');
    }

    await _utenteDao.deleteById(currentUser.uid);
    await currentUser.delete();
  }

  Future<Utente> _registraUtente({
    required String email,
    required String password,
    required String nominativo,
    required String numeroTelefono,
    required TipoUtente tipo,
  }) async {
    final userCredential = await _authService.signUp(email, password);
    final uid = userCredential.user!.uid;

    final utente = Utente(
      id: uid,
      nominativo: nominativo,
      email: email,
      numeroTelefono: numeroTelefono,
      dataCreazione: Timestamp.now(),
      tipo: tipo,
    );

    await _utenteDao.create(utente);
    return utente;
  }
}
