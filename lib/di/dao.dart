import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/dao/report_dao.dart';
import 'package:resqpet/dao/utente_dao.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dao.g.dart';

@riverpod
UtenteDao utenteDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return UtenteDao(firebaseFirestore);
}

@riverpod
AnnuncioDao annuncioDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return AnnuncioDao(firebaseFirestore);
}

@riverpod
ReportDao reportDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return ReportDao(firebaseFirestore);
}