import 'dart:io';

import 'package:intl/intl.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/dao/annuncio_dao.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/services/auth_service.dart';
import 'package:resqpet/services/cloud_storage_service.dart';

class AnnuncioRepository {
  final AnnuncioDao annuncioDao;
  final AuthService authService;
  final CloudStorageService storageService;

  AnnuncioRepository({
    required this.annuncioDao,
    required this.authService,
    required this.storageService
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


  void _checkCommonAnnuncioFields({
    required String nome,
    required String sesso,
    required double peso,
    required String colorePelo,
    required bool isSterilizzato,
    required String specie,
    required String razza,
    required List<File> foto,
  }) {

    if(!isLengthBetween(nome, 3, 30)) {
      throw ArgumentError.value(
        nome, 
        'nome', 
        'Il nome deve essere tra 3 e 30 caratteri'
      );
    }

    if (!sessoRegex.hasMatch(sesso)) {
      throw ArgumentError.value(
        sesso, 
        'sesso', 
        'Il sesso deve essere "maschio" o "femmina"'
      );
    }

    if (!isLengthBetween(specie, 3, 30)) {
      throw ArgumentError.value(
        specie, 
        'specie', 
        'La specie deve essere tra 3 e 30 caratteri'
      );
    }

    if (!isLengthBetween(razza, 3, 30)) {
      throw ArgumentError.value(
        razza, 
        'razza', 
        'La razza deve essere tra 3 e 30 caratteri'
      );
    }

    if (peso <= 0 || peso >= 1000) {
      throw ArgumentError.value(
        peso, 
        'peso', 
        'Il peso deve essere un numero positivo inferiore a 1000'
      );
    }

    if (!isLengthBetween(colorePelo, 3, 100)) {
      throw ArgumentError.value(
        colorePelo, 
        'colorePelo', 
        'Il colore deve essere tra 3 e 100 caratteri'
      );
    }

    if (foto.any((f) => !isJPEG(f.path))) {
      throw ArgumentError.value(
        foto, 
        'foto', 
        'Il formato delle foto deve essere jpeg'
      );
    }
  }

  Future<List<String>> _uploadPhotos(List<File> foto) async {
    final List<String> pathFoto = [];
    for (final fileFoto in foto) {
      pathFoto.add(await storageService.uploadFile(fileFoto));
    }

    return pathFoto;
  }

  Future<Annuncio> creaAnnuncioAdozione({
    required String nome,
    required String sesso,
    required double peso,
    required String colorePelo,
    required bool isSterilizzato,
    required String specie,
    required String razza,
    required List<File> foto,
    required StatoAnnuncio statoAnnuncio,
    required String storia,
    required String noteSanitarie,
    required double contributoSpeseSanitarie,
    required String carattere,
  }) async {

    if(authService.currentUser == null) {
      throw StateError("Utente non autenticato.");
    }

    final uid = authService.currentUser!.uid;

    _checkCommonAnnuncioFields(
      nome: nome, 
      sesso: sesso,
      peso: peso,
      colorePelo: colorePelo,
      isSterilizzato: isSterilizzato,
      specie: specie,
      razza: razza,
      foto: foto
    );

    if (!isLengthBetween(storia, 3, 200)) {
      throw ArgumentError.value(
        storia, 
        'storia', 
        'La storia deve essere tra 3 e 200 caratteri'
      );
    }

    if(!isLengthBetween(noteSanitarie, 3, 150)) {
      throw ArgumentError.value(
        noteSanitarie, 
        'noteSanitarie', 
        'Le note sanitarie devono essere tra 3 e 150 caratteri'
      );
    }

    if(!isLengthBetween(carattere, 3, 100)) {
      throw ArgumentError.value(
        carattere, 
        'carattere', 
        'Il carattere deve essere tra 3 e 100 caratteri'
      );
    }

    if(contributoSpeseSanitarie < 0) {
      throw ArgumentError.value(
        contributoSpeseSanitarie, 
        'contributoSpeseSanitarie', 
        'Il contributo alle spese sanitarie deve essere un numero decimale maggiore o uguale a zero'
      );
    }

    final paths = await _uploadPhotos(foto);

    return await annuncioDao.create(
      AnnuncioAdozione(
        creatoreRef: uid,
        nome: nome,
        sesso: sesso,
        peso: peso,
        colorePelo: colorePelo,
        isSterilizzato: isSterilizzato,
        specie: specie,
        razza: razza,
        foto: paths,
        statoAnnuncio: statoAnnuncio,
        storia: storia,
        noteSanitarie: noteSanitarie,
        contributoSpeseSanitarie: contributoSpeseSanitarie,
        carattere: carattere,
      )
    );
  }

  Future<Annuncio> creaAnnuncioVendita({
    required String nome,
    required String sesso,
    required double peso,
    required String colorePelo,
    required bool isSterilizzato,
    required String specie,
    required String razza,
    required List<File> foto,
    required StatoAnnuncio statoAnnuncio,
    required double prezzo,
    required String dataNascita,
    required String numeroMicrochip,
  }) async {

    if(authService.currentUser == null) {
      throw StateError("Utente non autenticato.");
    }

    final uid = authService.currentUser!.uid;

    _checkCommonAnnuncioFields(
      nome: nome, 
      sesso: sesso,
      peso: peso,
      colorePelo: colorePelo,
      isSterilizzato: isSterilizzato,
      specie: specie,
      razza: razza,
      foto: foto
    );

    if (!dataRegex.hasMatch(dataNascita)) {
      throw ArgumentError.value(
        dataNascita, 
        'dataNascita', 
        'Data di nascita deve essere nel formato gg/mm/aaaa'
      );
    }
    else {
try {
    // parseStrict lancia un'eccezione se la data non è reale (es. 31/02)
    final inputDate = DateFormat('dd/MM/yyyy').parseStrict(dataNascita);

    if (inputDate.isAfter(DateTime.now())) {
      throw ArgumentError.value(
        dataNascita,
        'dataNascita',
        'Data di nascita non può essere futura'
      );
    }
  } on FormatException {
    throw ArgumentError.value(
      dataNascita,
      'dataNascita',
      'La data inserita non esiste nel calendario'
    );
  }
}

    if (!microchipRegex.hasMatch(numeroMicrochip)) {
      throw ArgumentError.value(
        numeroMicrochip, 
        'numeroMicrochip', 
        'Il numero di microchip deve contenere esattamente 15 cifre'
      );
    }

    if (prezzo <= 0) {
      throw ArgumentError.value(
        prezzo, 
        'prezzo', 
        'Il prezzo deve essere un numero positivo'
      );
    }

    final paths = await _uploadPhotos(foto);

    return await annuncioDao.create(
      AnnuncioVendita(
        creatoreRef: uid, 
        nome: nome, 
        sesso: sesso, 
        peso: peso, 
        colorePelo: colorePelo, 
        isSterilizzato: isSterilizzato, 
        specie: specie, 
        razza: razza, 
        foto: paths,
        statoAnnuncio: statoAnnuncio, 
        prezzo: prezzo, 
        dataNascita: dataNascita, 
        numeroMicrochip: numeroMicrochip
      )
    );
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


    try {
      final annuncio = await annuncioDao.findById(annuncioId);
      if(annuncio != null) {
        for(final path in annuncio.foto) {
          storageService.deleteFile(path);
        }
      }
    } catch(_) {}

    return await annuncioDao.deleteById(annuncioId);
  }

  Future<Annuncio> aggiornaAnnuncio(Annuncio annuncio) async {
    return await annuncioDao.update(annuncio);
  }
}