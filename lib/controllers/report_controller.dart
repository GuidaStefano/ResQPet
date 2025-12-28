import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/report.dart';
import 'package:resqpet/repositories/annuncio_repository.dart';
import 'package:resqpet/repositories/report_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'report_controller.g.dart';

@riverpod
Stream<List<Report>> reports(Ref ref, [StatoReport? stato]) {
  return ref.read(reportRepositoryProvider)
    .getReportsStream(stato: stato);
}

sealed class ReportState {
  const ReportState();

  factory ReportState.idle() = ReportIdle;
  factory ReportState.loading() = ReportLoading;
  factory ReportState.success() = ReportSuccess;
  factory ReportState.error(String message) = ReportError;
}

class ReportIdle extends ReportState {}
class ReportLoading extends ReportState {}
class ReportSuccess extends ReportState {}

final class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
}


@riverpod
class ReportController extends _$ReportController {

  late ReportRepository _reportRepository;
  late AnnuncioRepository _annuncioRepository;

  @override
  ReportState build() {
    _reportRepository = ref.read(reportRepositoryProvider);
    return ReportState.idle();
  }

  Future<void> risolviReport(Report report) async {
    state = ReportState.loading();

    try {
      await _annuncioRepository.cancellaAnnuncio(report.annuncioRef);
      await _reportRepository.risolviReport(report.id);
      state = ReportState.success();
    } catch (e) {
      state = ReportState.error("Si e' verificato un errore durante la risoluzione del report");
    }
  }

  Future<void> creaReport({
    required String motivazione,
    required String descrizione,
    required String annuncioRef
  }) async {
    state = ReportState.loading();

    try {
      _reportRepository.creaReport(
        motivazione: motivazione,
        descrizione: descrizione,
        annuncioRef: annuncioRef
      );
      state = ReportState.success();
    } catch (e) {
      state = ReportState.error("Si e' verificato un errore durante la creazione del report");
    }
  }

  Future<void> cancellaReport(Report report) async {
    state = ReportState.loading();

    try {
      await _reportRepository.rimuoviReport(report.id);
      state = ReportState.success();
    } catch (e) {
      state = ReportState.error("Si e' verificato un errore durante la cancellazione del report");
    }
  }
}