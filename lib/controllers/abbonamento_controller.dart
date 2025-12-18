import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'abbonamento_controller.g.dart';

@riverpod
Future<List<Abbonamento>> abbonamenti(Ref ref) async {
  final abbonamentoRepository = ref.read(abbonamentoRepositoryProvider);
  return abbonamentoRepository.getAll();
}

@riverpod
Future<Abbonamento> abbonamento(Ref ref) async {
  return ref.read(abbonamentoRepositoryProvider)
    .getAbbonamento();
}

@riverpod
Future<bool> isAbbonamentoExpired(Ref ref) async {
  return ref.read(abbonamentoRepositoryProvider)
    .isAbbonamentoScaduto();
}

@riverpod
Future<bool> canPublishMoreAd(Ref ref) async {
  final authService = ref.read(authServiceProvider);
  final abbonamento = await ref.read(abbonamentoProvider.future);

  final annunci = await ref.read(annuncioRepositoryProvider)
    .getAnnunciByCreatore(authService.currentUser!.uid);

  return annunci.length < abbonamento.maxAnnunciVendita;
}