import '../daos/segnalazione_dao.dart';
import '../entities/segnalazione.dart';

class SegnalazioneService {
  final SegnalazioneDao _dao;

  SegnalazioneService(this._dao);

  /// 1. CREA SEGNALAZIONE [SDD: Crea segnalazione]
  /// Permette a un cittadino di inviare una segnalazione.
  Future<Segnalazione> creaSegnalazione(Segnalazione segnalazione) async {
    return await _dao.create(segnalazione);
  }

  /// 2. LISTA SEGNALAZIONI (STREAM) [SDD: Lista segnalazioni]
  /// Restituisce lo stream per aggiornare la UI in tempo reale (richiesto da architettura Event Driven).
  Stream<List<Segnalazione>> getSegnalazioniStream() {
    return _dao.findAllStream();
  }

  /// 3. LE MIE SEGNALAZIONI (Cittadino) [SDD: Ricerca segnalazione / Filtri]
  /// Recupera lo storico delle segnalazioni di un cittadino.
  Future<List<Segnalazione>> getSegnalazioniByCittadino(String cittadinoId) async {
    return await _dao.findByCittadino(cittadinoId);
  }

  /// 4. ASSEGNA SOCCORRITORE / PRENDI IN CARICO [SDD: Assegna soccorritore]
  /// Un soccorritore accetta una segnalazione.
  /// Logica: Aggiorna lo stato e imposta il riferimento del soccorritore.
  Future<void> prendiInCarico(Segnalazione segnalazione, String soccorritoreId) async {
    // Creiamo una copia aggiornata dell'oggetto con i nuovi dati
    final segnalazioneAggiornata = segnalazione.copyWith(
      soccorritoreRef: soccorritoreId,
      stato: "presa in carico", // Aggiorna lo stato come da flusso
    );

    await _dao.update(segnalazioneAggiornata);
  }

  /// 5. LE MIE ASSEGNAZIONI (Soccorritore)
  /// Visualizza le segnalazioni prese in carico dal soccorritore loggato.
  Future<List<Segnalazione>> getIncarichiSoccorritore(String soccorritoreId) async {
    return await _dao.findBySoccorritore(soccorritoreId);
  }

  /// 6. AGGIORNA STATO / CHIUDI SEGNALAZIONE [SDD: Aggiorna stato intervento / Chiudi segnalazione]
  /// Permette di cambiare lo stato (es. "risolto", "annullato").
  Future<void> aggiornaStato(Segnalazione segnalazione, String nuovoStato) async {
    final segnalazioneAggiornata = segnalazione.copyWith(
      stato: nuovoStato,
    );

    await _dao.update(segnalazioneAggiornata);
  }
}
