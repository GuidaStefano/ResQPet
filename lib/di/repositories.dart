import 'package:resqpet/di/dao.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/repositories/abbonamento_repository.dart';
import 'package:resqpet/repositories/report_repository.dart';
import 'package:resqpet/repositories/utente_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repositories.g.dart';

@riverpod
UtenteRepository utenteRepository(Ref ref) {
  final authService = ref.read(authServiceProvider);
  final utenteDao = ref.read(utenteDaoProvider);
  return UtenteRepository(authService, utenteDao);
}

@riverpod
ReportRepository reportRepository(Ref ref) {
  final reportDao = ref.read(reportDaoProvider);
  final authService = ref.read(authServiceProvider);

  return ReportRepository(reportDao: reportDao, authService: authService);
}

@riverpod
AbbonamentoRepository abbonamentoRepository(Ref ref) {

  final authService = ref.read(authServiceProvider);
  final utenteDao = ref.read(utenteDaoProvider);
  final abbonamentoDao = ref.read(abbonamentoDaoProvider);
  
  return AbbonamentoRepository(
    utenteDao: utenteDao,
    abbonamentoDao: abbonamentoDao,
    authService: authService
  );
}