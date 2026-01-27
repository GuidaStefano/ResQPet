# 🐾 ResQPet

ResQPet è un’applicazione mobile progettata per centralizzare, tracciare e rendere sicure le attività di 
**segnalazione di animali abbandonati**, **adozione responsabile** ed eventuale **compravendita regolamentata** di animali domestici.

L’obiettivo principale è superare l’uso di strumenti non strutturati come social network o app di messaggistica, offrendo una piattaforma unica, 
affidabile e tracciabile a supporto di cittadini, soccorritori e strutture di accoglienza.

### 📌 Problema affrontato

Attualmente:
- Le segnalazioni di abbandono avvengono tramite canali informali
- Non esiste un sistema di tracciamento delle segnalazioni
- I dati rischiano di andare persi o duplicati
- La comunicazione tra cittadini, enti e soccorritori è frammentata

ResQPet nasce per risolvere queste criticità attraverso un sistema centralizzato e strutturato.

### 🎯 Obiettivi dell’app

- [x] Centralizzare le segnalazioni di abbandono
- [x] Garantire un rapido intervento dei soccorritori
- [x] Tracciare il percorso dell’animale dalla segnalazione all’accoglienza
- [x] Unificare annunci di adozione e informazioni sulle strutture
- [x] Consentire la compravendita sicura di animali tra privati
- [x] Migliorare la comunicazione tra tutti gli attori coinvolti

## 🚀 Funzionalità principali

### 🆘 Segnalazione abbandoni
- Inserimento rapido di segnalazioni tramite app
- Geolocalizzazione dell’evento
- Stato della segnalazione sempre tracciabile

### 🏥 Strutture di accoglienza

- Registrazione e gestione delle strutture
- Presa in carico degli animali soccorsi


### 🐕 Adozioni

- Pubblicazione di annunci di adozione
- Consultazione centralizzata degli animali disponibili
- Informazioni chiare e verificate

### 💼 Compravendita sicura

- Vendita di animali da parte di privati
- Sistema pensato per garantire trasparenza e sicurezza
- Riduzione di truffe e annunci non verificati

## 👥 Una rete che funziona

ResQPet connette:
- **Cittadini**, che segnalano e adottano
- **Soccorritori**, che intervengono sul territorio
- **Strutture di accoglienza**, che proteggono e curano
- **Privati**, che operano in modo responsabile

Tutti all’interno di un ecosistema digitale unico.

## ❤️ Visione

ResQPet non è solo un’app, ma uno strumento per:

- Tutelare il benessere animale
- Supportare chi aiuta concretamente sul territorio
- Rendere più responsabile e trasparente l’adozione e la gestione degli animali


## 🛠️ Tecnologie utilizzate

- **Dart**: linguaggio di programmazione utilizzato per lo sviluppo dell’applicazione
- **Flutter**: framework per la realizzazione dell’app mobile multipiattaforma
-**Firebase**:
  - **Firebase Authentication** per la gestione degli utenti
  - **Cloud Firestore** per l’archiviazione e la sincronizzazione dei dati
  - **Firebase Storage** per la gestione di immagini e contenuti multimediali
  - **Firebase Cloud Messaging** per notifiche e aggiornamenti in tempo reale

Questa architettura consente un’elevata scalabilità, affidabilità e una gestione in tempo reale delle informazioni.

# 🧪 Build & Testing
## 🔧 Prerequisiti

- **Flutter SDK** (versione stabile)
- **Dart SDK**
- **Android Studio / VS Code**
- **Emulatore Android** o **dispositivo fisico**
- **Account Firebase** configurato

## 🚀 Build dell’app

**Clona il repository e posizionati nella directory del progetto:**
```bash
git clone https://github.com/your-username/resqpet.git
cd resqpet
```

**Installa le dipendenze:**
```bash
flutter pub get
```

**Avvia l’app in modalità debug:**
```bash
flutter run
```

### Per generare una build di rilascio:

**Android**
```
flutter build apk
```

**iOS**
```
flutter build ios
```

## 🧪 Testing

**Esegui i test automatici con:**
```bash
flutter test
```
