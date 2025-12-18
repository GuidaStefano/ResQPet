import 'package:resqpet/di/repositories.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'abbonamento_controller.g.dart';

@riverpod
Future<List<Abbonamento>> abbonamenti(Ref ref) async {
  final abbonamentoRepository = ref.read(abbonamentoRepositoryProvider);
  return abbonamentoRepository.getAll();
}