import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqpet/dao/utente_dao.dart';
import 'package:resqpet/dao/abbonamento_dao.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/services/auth_service.dart';

class AbbonamentoRepository {

  final UtenteDao utenteDao;
  final AbbonamentoDao abbonamentoDao;
  final AuthService authService;

  AbbonamentoRepository({
    required this.utenteDao,
    required this.abbonamentoDao,
    required this.authService
  });

  Future<Venditore> _getSellerDetail() async {
    final currentAuthenticatedUser = authService.currentUser;

    if(currentAuthenticatedUser == null) {
      throw StateError("Per poter attivare l'abbonamneto l'utente deve essere autenticato.");
    }

    final id = currentAuthenticatedUser.uid;
    final user = await utenteDao.findById(id);

    if(user == null) {
      throw StateError("Utete non trovato.");
    }

    if(user.tipo != TipoUtente.venditore) {
      throw StateError("Solo gli utenti registrati come venditori possono sottoscrivere un abbonamento.");
    }

    return user as Venditore;
  }

  Future<void> attivaAbbonamento(String abbonamentoId) async {

    final subscriptionPlan = await abbonamentoDao.findById(abbonamentoId);

    if(subscriptionPlan == null) {
      throw StateError("L'abbonamento specificato non è stato trovato.");
    }

    final seller = await _getSellerDetail();

    await utenteDao.update(
      seller.copyWith(
        abbonamentoRef: subscriptionPlan.id,
        dataSottoscrizioneAbbonamento: Timestamp.now()
      )
    );
  }

  Future<Abbonamento> getAbbonamento() async {
    final seller = await _getSellerDetail();
    final subscription = await abbonamentoDao.findById(seller.abbonamentoRef);

    if(subscription == null) {
      throw StateError("Impossibile trovare i dati dell'abbonamento specificato.");
    }

    return subscription;
  }

  Future<bool> isAbbonamentoScaduto() async {

    try {
      final durationInMonths = (await getAbbonamento()).durataInMesi;
      final seller = await _getSellerDetail();

      final subscriptionDate = seller.dataSottoscrizioneAbbonamento.toDate();
      final today = DateTime.now();

      int months = (today.year - subscriptionDate.year) * 12 +
        (today.month - subscriptionDate.month);

      if(today.day < subscriptionDate.day) {
        months--;
      }

      return months >= durationInMonths;
    } catch(_) {
      return true;
    }
  }

  Future<List<Abbonamento>> getAll() async {
    return abbonamentoDao.findAll();
  }

}