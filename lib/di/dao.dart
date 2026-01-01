import 'package:resqpet/dao/abbonamento_dao.dart';
import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/dao/report_dao.dart';
import 'package:resqpet/dao/segnalazione_dao.dart';
import 'package:resqpet/dao/utente_dao.dart';
import 'package:resqpet/di/firebase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dao.g.dart';

@Riverpod(keepAlive: true)
UtenteDao utenteDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return UtenteDao(firebaseFirestore);
}

@Riverpod(keepAlive: true)
AnnuncioDao annuncioDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return AnnuncioDao(firebaseFirestore);
}

@Riverpod(keepAlive: true)
ReportDao reportDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return ReportDao(firebaseFirestore);
}

@Riverpod(keepAlive: true)
SegnalazioneDao segnalazioneDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return SegnalazioneDao(firebaseFirestore);
}

@Riverpod(keepAlive: true)
AbbonamentoDao abbonamentoDao(Ref ref) {
  final firebaseFirestore = ref.read(firebaseFirestoreProvider);
  return AbbonamentoDao(firebaseFirestore);
}