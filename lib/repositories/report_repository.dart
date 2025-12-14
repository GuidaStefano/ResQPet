import 'package:resqpet/dao/report_dao.dart';
import 'package:resqpet/models/report.dart';
import 'package:resqpet/services/auth_service.dart';

class ReportRepository {
  final ReportDao _reportDao;
  final AuthService _authService;

  ReportRepository({
    required ReportDao reportDao,
    required AuthService authService,
  }) : _reportDao = reportDao,
       _authService = authService;
    
// Crea un nuovo report associato all'utente attualmente autenticato
  Future<Report> creaReport({
    required String motivazione,
    required String descrizione,
    required String annuncioRef,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Utente non autenticato');
    }

    final nuovoReport = Report.newReport(
      motivazione: motivazione,
      descrizione: descrizione,
      cittadinoRef: uid,
      annuncioRef: annuncioRef,
    );

    return _reportDao.create(nuovoReport);
  }
// Recupera i report, opzionalmente filtrati per stato
  Future<List<Report>> getReports({StatoReport? stato}) {
    if (stato != null) {
      return _reportDao.findByStato(stato);
    }

    return _reportDao.findAll();
  }
// Segna un report come risolto dato il suo ID
  Future<Report> risolviReport(String reportId) async {
    final report = await _reportDao.findById(reportId);
    if (report == null) {
      throw ArgumentError('Report $reportId non trovato');
    }

    final risolto = report.copyWith(stato: StatoReport.risolto);
    return _reportDao.update(risolto);
  }
// Rimuove un report dato il suo ID
  Future<bool> rimuoviReport(String reportId) {
    return _reportDao.deleteById(reportId);
  }
}
