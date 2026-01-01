import 'package:resqpet/dao/report_dao.dart';
import 'package:resqpet/models/report.dart';
import 'package:resqpet/services/auth_service.dart';

class ReportRepository {
  final ReportDao reportDao;
  final AuthService authService;

  ReportRepository({
    required this.reportDao,
    required this.authService,
  });
    
  // Crea un nuovo report associato all'utente attualmente autenticato
  Future<Report> creaReport({
    required String motivazione,
    required String descrizione,
    required String annuncioRef,
  }) async {
    final uid = authService.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Utente non autenticato');
    }

    final nuovoReport = Report.newReport(
      motivazione: motivazione,
      descrizione: descrizione,
      cittadinoRef: uid,
      annuncioRef: annuncioRef,
    );

    return reportDao.create(nuovoReport);
  }

  // Recupera i report, opzionalmente filtrati per stato
  Future<List<Report>> getReports({StatoReport? stato}) {
    if (stato != null) {
      return reportDao.findByStato(stato);
    }

    return reportDao.findAll();
  }

  Stream<List<Report>> getReportsStream({StatoReport? stato}) {
    
    if (stato != null) {
      return reportDao.findByStatoStream(stato);
    }

    return reportDao.findAllStream();
  }

  // Segna un report come risolto dato il suo ID
  Future<Report> risolviReport(String reportId) async {
    final report = await reportDao.findById(reportId);
    if (report == null) {
      throw ArgumentError('Report $reportId non trovato');
    }

    final risolto = report.copyWith(stato: StatoReport.risolto);
    return reportDao.update(risolto);
  }
  
  // Rimuove un report dato il suo ID
  Future<bool> rimuoviReport(String reportId) {
    return reportDao.deleteById(reportId);
  }
}
