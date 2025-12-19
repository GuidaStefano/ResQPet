import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AnnuncioRepository {
  final AnnuncioDao annuncioDao;

  AnnuncioRepository({
    required this.annuncioDao
  });

  Stream<List<Annuncio>> getAnnunciByStato(StatoAnnuncio stato) {
    return annuncioDao.findByStatoStream(stato);
  }

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

    if(!isLengthBetween(annuncio.nome, 3, 30)) {
      throw ArgumentError.value(
        annuncio.nome, 
        'nome', 
        'Il nome deve essere tra 3 e 30 caratteri'
      );
    }

    if (!sessoRegex.hasMatch(annuncio.sesso)) {
      throw ArgumentError.value(
        annuncio.sesso, 
        'sesso', 
        'Il sesso deve essere "maschio" o "femmina"'
      );
    }

    if (!isLengthBetween(annuncio.specie, 3, 30)) {
      throw ArgumentError.value(
        annuncio.specie, 
        'specie', 
        'La specie deve essere tra 3 e 30 caratteri'
      );
    }

    if (!isLengthBetween(annuncio.razza, 3, 30)) {
      throw ArgumentError.value(
        annuncio.razza, 
        'razza', 
        'La razza deve essere tra 3 e 30 caratteri'
      );
    }

    if (annuncio.peso <= 0 || annuncio.peso >= 1000) {
      throw ArgumentError.value(
        annuncio.peso, 
        'peso', 
        'Il peso deve essere un numero positivo inferiore a 1000'
      );
    }

    if (!isLengthBetween(annuncio.colorePelo, 3, 100)) {
      throw ArgumentError.value(
        annuncio.colorePelo, 
        'colorePelo', 
        'Il colore deve essere tra 3 e 100 caratteri'
      );
    }

    if (annuncio.foto.any((path) => !isJPEG(path))) {
      throw ArgumentError.value(
        annuncio.foto, 
        'foto', 
        'Il formato delle foto deve essere jpeg'
      );
    }

    if(annuncio is AnnuncioVendita) {

      if (dataRegex.hasMatch(annuncio.dataNascita)) {
        throw ArgumentError.value(
          annuncio.dataNascita, 
          'dataNascita', 
          'Data di nascita deve essere nel formato gg/mm/aaaa'
        );
      }

      if (!microchipRegex.hasMatch(annuncio.numeroMicrochip)) {
        throw ArgumentError.value(
          annuncio.numeroMicrochip, 
          'numeroMicrochip', 
          'Il numero di microchip deve contenere esattamente 15 cifre'
        );
      }

      if (annuncio.prezzo <= 0) {
        throw ArgumentError.value(
          annuncio.prezzo, 
          'prezzo', 
          'Il prezzo deve essere un numero positivo'
        );
      }

    }

    if(annuncio is AnnuncioAdozione) {
      if (!isLengthBetween(annuncio.storia, 3, 200)) {
        throw ArgumentError.value(
          annuncio.storia, 
          'storia', 
          'La storia deve essere tra 3 e 200 caratteri'
        );
      }

      if(!isLengthBetween(annuncio.noteSanitarie, 3, 150)) {
        throw ArgumentError.value(
          annuncio.noteSanitarie, 
          'noteSanitarie', 
          'Le note sanitarie devono essere tra 3 e 150 caratteri'
        );
      }

      if(!isLengthBetween(annuncio.carattere, 3, 100)) {
        throw ArgumentError.value(
          annuncio.carattere, 
          'carattere', 
          'Il carattere deve essere tra 3 e 100 caratteri'
        );
      }

      if(annuncio.contributoSpeseSanitarie < 0) {
        throw ArgumentError.value(
          annuncio.contributoSpeseSanitarie, 
          'contributoSpeseSanitarie', 
          'Il contributo alle spese sanitarie deve essere un numero decimale maggiore o uguale a zero'
        );
      }
    }

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