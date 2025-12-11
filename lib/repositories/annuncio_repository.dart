import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AnnuncioRepository{
  final AnnuncioDao _annuncioDao;

  AnnuncioRepository(this._annuncioDao);

  Future<List<Annuncio>> getAnnunciVendita() async {
    return await _annuncioDao.findByTipo(TipoAnnuncio.vendita);
  }

  Stream<List<Annuncio>> getAnnunciVenditaStream() {
    return _annuncioDao.findByTipoStream(TipoAnnuncio.vendita);
  }

  Future<List<Annuncio>> getAnnunciAdozione() async {
    return await _annuncioDao.findByTipo(TipoAnnuncio.adozione);
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

  Future<Annuncio> creaAnnuncio(Annuncio annuncio) async {
    return await _annuncioDao.create(annuncio);
  }
}