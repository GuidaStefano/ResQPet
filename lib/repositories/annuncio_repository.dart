import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AnnuncioRepository{
  final AnnuncioDao _annuncioDao;

  AnnuncioRepository(this._annuncioDao);

  Future<List<Annuncio>> getAnnunciVendita() async {
    return await _annuncioDao.findActiveByTipo(TipoAnnuncio.vendita);
  }

  Stream<List<Annuncio>> getAnnunciVenditaStream() {
    return _annuncioDao.findByTipoStream(TipoAnnuncio.vendita);
  }

  Future<List<Annuncio>> getAnnunciAdozione() async {
    return await _annuncioDao.findActiveByTipo(TipoAnnuncio.adozione);
  }

  Stream<List<Annuncio>> getAnnunciAdozioneStream() {
    return _annuncioDao.findByTipoStream(TipoAnnuncio.adozione);
  }

  Future<List<Annuncio>> getAnnunciByStatoAndTipo(StatoAnnuncio stato, TipoAnnuncio tipo) async {
    return await _annuncioDao.findByStatoAndTipo(stato, tipo);
  }
  
  Stream<List<Annuncio>> getAnnunciByStatoAndTipoStream(StatoAnnuncio stato, TipoAnnuncio tipo) {
    return _annuncioDao.findByStatoAndTipoStream(stato, tipo);
  }

  Future<List<Annuncio>> getAnnunciByCreatore(String creatoreRef) async {
    return await _annuncioDao.findByCreatore(creatoreRef);
  }

  Stream<List<Annuncio>> getAnnunciByCreatoreStream(String creatoreRef) {
    return _annuncioDao.findByCreatoreStream(creatoreRef);
  }

  Future<List<Annuncio>> getAnnunciBySpecie(String specie) async {
    return await _annuncioDao.findBySpecie(specie);
  }

  Stream<List<Annuncio>> getAnnunciBySpecieStream(String specie) {
    return _annuncioDao.findBySpecieStream(specie);
  }

  Future<List<Annuncio>> getAnnunciByRazza(String razza) async {
    return await _annuncioDao.findByRazza(razza);
  }

  Stream<List<Annuncio>> getAnnunciByRazzaStream(String razza) {
    return _annuncioDao.findByRazzaStream(razza);
  }

  Future<Annuncio> creaAnnuncio(Annuncio annuncio) async {
    return await _annuncioDao.create(annuncio);
  }

  Future<Annuncio> finalizzaAnnuncio(String annuncioId) async {
    final Annuncio? annuncio = await _annuncioDao.findById(annuncioId);

    if(annuncio == null) {
      throw StateError("Annuncio non esistente");
    }

    return annuncio.copyWith(statoAnnuncio: StatoAnnuncio.concluso);
  }

  Future<bool> cancellaAnnuncio(String annuncioId) async {
    return await _annuncioDao.deleteById(annuncioId);
  }

  Future<Annuncio> aggiornaAnnuncio(Annuncio annuncio) async {
    return await _annuncioDao.update(annuncio);
  }
}