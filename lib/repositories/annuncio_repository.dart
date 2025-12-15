import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AnnuncioRepository {
  final AnnuncioDao annuncioDao;

  AnnuncioRepository({
    required this.annuncioDao
  });

  Future<List<Annuncio>> getAnnunciVendita() async {
    return await annuncioDao.findActiveByTipo(TipoAnnuncio.vendita);
  }

  Stream<List<Annuncio>> getAnnunciVenditaStream() {
    return getAnnunciByStatoAndTipoStream(StatoAnnuncio.attivo, TipoAnnuncio.vendita);
  }

  Future<List<Annuncio>> getAnnunciAdozione() async {
    return await annuncioDao.findActiveByTipo(TipoAnnuncio.adozione);
  }

  Stream<List<Annuncio>> getAnnunciAdozioneStream() {
    return getAnnunciByStatoAndTipoStream(StatoAnnuncio.attivo, TipoAnnuncio.adozione);
  }

  Future<List<Annuncio>> getAnnunciByStatoAndTipo(StatoAnnuncio stato, TipoAnnuncio tipo) async {
    return await annuncioDao.findByStatoAndTipo(stato, tipo);
  }
  
  Stream<List<Annuncio>> getAnnunciByStatoAndTipoStream(StatoAnnuncio stato, TipoAnnuncio tipo) {
    return annuncioDao.findByStatoAndTipoStream(stato, tipo);
  }

  Future<List<Annuncio>> getAnnunciByCreatore(String creatoreRef) async {
    return await annuncioDao.findByCreatore(creatoreRef);
  }

  Stream<List<Annuncio>> getAnnunciByCreatoreStream(String creatoreRef) {
    return annuncioDao.findByCreatoreStream(creatoreRef);
  }

  Future<Annuncio> creaAnnuncio(Annuncio annuncio) async {
    return await annuncioDao.create(annuncio);
  }

  Future<void> finalizzaAnnuncio(String annuncioId) async {
    final Annuncio? annuncio = await annuncioDao.findById(annuncioId);

    if(annuncio == null) {
      throw StateError("Annuncio non esistente");
    }

    await annuncioDao.updateStato(
      annuncioId,
      StatoAnnuncio.concluso
    );
  }

  Future<bool> cancellaAnnuncio(String annuncioId) async {
    return await annuncioDao.deleteById(annuncioId);
  }

  Future<Annuncio> aggiornaAnnuncio(Annuncio annuncio) async {
    return await annuncioDao.update(annuncio);
  }
}