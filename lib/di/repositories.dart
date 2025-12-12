import 'package:resqpet/di/dao.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/repositories/report_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'repositories.g.dart';
// Fornisce un'istanza di ReportRepository con le dipendenze iniettate
@riverpod
ReportRepository reportRepository(Ref ref) {
  final reportDao = ref.read(reportDaoProvider);
  final authService = ref.read(authServiceProvider);

  return ReportRepository(reportDao: reportDao, authService: authService);
}