import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/photo_upload_card.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class AnnuncioFormScreen extends ConsumerStatefulWidget {
  final TipoAnnuncio tipoAnnuncio;
  final Annuncio? annuncio;

  const AnnuncioFormScreen({
    super.key, 
    this.annuncio,
    required this.tipoAnnuncio
  });

  bool get isEdit => annuncio != null;

  @override
  ConsumerState<AnnuncioFormScreen> createState() => _AnnuncioFormPageState();
}

class _AnnuncioFormPageState extends ConsumerState<AnnuncioFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Campi comuni
  final _nomeCtrl = TextEditingController();
  final _sessoCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _coloreCtrl = TextEditingController();
  final _specieCtrl = TextEditingController();
  final _razzaCtrl = TextEditingController();
  bool _sterilizzato = false;
  late bool _salvaComeBozza = false;

  final List<File> _foto = [];

  // Adozione
  final _storiaCtrl = TextEditingController();
  final _noteSanitarieCtrl = TextEditingController();
  final _contributoCtrl = TextEditingController();
  final _carattereCtrl = TextEditingController();

  // Vendita
  final _prezzoCtrl = TextEditingController();
  final _dataNascitaCtrl = TextEditingController();
  final _microchipCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (!widget.isEdit) {
      return;
    }

    final a = widget.annuncio!;

    _salvaComeBozza = a.statoAnnuncio == StatoAnnuncio.inAttesa;

    _nomeCtrl.text = a.nome;
    _sessoCtrl.text = a.sesso;
    _pesoCtrl.text = a.peso.toString();
    _coloreCtrl.text = a.colorePelo;
    _specieCtrl.text = a.specie;
    _razzaCtrl.text = a.razza;
    _sterilizzato = a.isSterilizzato;

    if (a is AnnuncioAdozione) {
      _storiaCtrl.text = a.storia;
      _noteSanitarieCtrl.text = a.noteSanitarie;
      _contributoCtrl.text = a.contributoSpeseSanitarie.toString();
      _carattereCtrl.text = a.carattere;
    }

    if (a is AnnuncioVendita) {
      _prezzoCtrl.text = a.prezzo.toString();
      _dataNascitaCtrl.text = a.dataNascita;
      _microchipCtrl.text = a.numeroMicrochip;
    }

  }

  @override
  void dispose() {
    super.dispose();

    _nomeCtrl.dispose();
    _sessoCtrl.dispose();
    _pesoCtrl.dispose();
    _coloreCtrl.dispose();
    _specieCtrl.dispose();
    _razzaCtrl.dispose();

    _storiaCtrl.dispose();
    _noteSanitarieCtrl.dispose();
    _contributoCtrl.dispose();
    _carattereCtrl.dispose();

    _prezzoCtrl.dispose();
    _dataNascitaCtrl.dispose();
    _microchipCtrl.dispose();
  }

  Future<void> takePicture(BuildContext context, [bool fromCamera = false]) async {
    try {
      final image = await pickImage(context, fromCamera: fromCamera);
      setState(() {
        _foto.add(File(image.path));
      });

      if(context.mounted) {
        showSnackBar(context, "Immaggine selezionata!");
      }
    } catch(_) {
      if(context.mounted) {
        showErrorSnackBar(context, "Errore nell'acquisizione della foto");
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(annuncioControllerProvider, (_, state) {
      if(state is AnnuncioError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is AnnuncioSuccess) {
        showSnackBar(context, "Annuncio Creato!");
        context.pop();
      }

      if(state is AnnuncioModificatoSuccess) {
        showSnackBar(context, "Annuncio Aggiornato!");
        context.pop();
      }
    });

    final state = ref.watch(annuncioControllerProvider);

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ResQPetColors.primaryDark),
        title: Text(
          widget.isEdit ? 'Modifica Annuncio' : 'Nuovo Annuncio',
          style: const TextStyle(
            color: ResQPetColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ResQPetColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ResQPetColors.primaryDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.raw_on,
                      color: ResQPetColors.primaryDark,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Salvare come bozza?',
                        style: TextStyle(
                          fontSize: 16,
                          color: ResQPetColors.primaryDark,
                        ),
                      ),
                    ),
                    Switch(
                      value: _salvaComeBozza,
                      onChanged: (v) => setState(() => _salvaComeBozza = v),
                      activeThumbColor: ResQPetColors.accent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if(!widget.isEdit) PhotoUploadCard(
                onPickImageFromCamera: () async {
                  await takePicture(context, true);
                }, 
                onPickImageFromGallery: () async {
                  await takePicture(context);
                },
                selectedImages: _foto
              ),
              const SizedBox(height: 20),
              // Sezione Informazioni Animale
              const Text(
                'Informazioni Animale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResQPetColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),

              _field(
                _nomeCtrl, 
                'Nome', 
                Icons.pets,
                validator: (value) {
                  return !isLengthBetween(value ?? '', 3, 30)
                    ? 'Il nome deve essere tra 3 e 30 caratteri'
                    : null;
                }
              ),
              _field(
                _sessoCtrl, 
                'Sesso',
                Icons.wc,
                validator: (value) {
                  return !sessoRegex.hasMatch(value ?? '')
                    ? 'Il sesso deve essere "maschio" o "femmina"'
                    : null;
                }
              ),
              _field(
                _pesoCtrl,
                'Peso',
                Icons.monitor_weight,
                keyboard: TextInputType.number,
                validator: (value) {
                  final peso = double.tryParse(value ?? '') ?? -1;
                  return (peso <= 0 || peso >= 1000)
                    ? 'Il peso deve essere un numero positivo inferiore a 1000'
                    : null;
                }
              ),
              _field(
                _coloreCtrl,
                'Colore pelo',
                Icons.palette,
                validator: (value) {
                  return !isLengthBetween(value ?? '', 3, 100)
                    ? 'Il colore deve essere tra 3 e 100 caratteri'
                    : null;
                }
              ),
              _field(
                _specieCtrl, 
                'Specie',
                Icons.category,
                validator: (value) {
                  return !isLengthBetween(value ?? '', 3, 30)
                    ? 'La specie deve essere tra 3 e 30 caratteri'
                    : null;
                }
              ),
              _field(
                _razzaCtrl,
                'Razza',
                Icons.label,
                validator: (value) {
                  return !isLengthBetween(value ?? '', 3, 30)
                    ? 'La razza deve essere tra 3 e 30 caratteri'
                    : null;
                }
              ),

              // Switch Sterilizzato come Card
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ResQPetColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: ResQPetColors.primaryDark.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: ResQPetColors.primaryDark,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Sterilizzato',
                        style: TextStyle(
                          fontSize: 16,
                          color: ResQPetColors.primaryDark,
                        ),
                      ),
                    ),
                    Switch(
                      value: _sterilizzato,
                      onChanged: (v) => setState(() => _sterilizzato = v),
                      activeThumbColor: ResQPetColors.accent,
                    ),
                  ],
                ),
              ),

              const Divider(height: 32),

              // Sezione Specifica
              if (widget.tipoAnnuncio == TipoAnnuncio.adozione) ...[
                const Text(
                  'Dettagli Adozione',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResQPetColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ..._adozioneFields(),
              ],
              if (widget.tipoAnnuncio == TipoAnnuncio.vendita) ...[
                const Text(
                  'Dettagli Vendita',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ResQPetColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                ..._venditaFields(),
              ],

              const SizedBox(height: 24),

              // Pulsante Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: state is! AnnuncioLoading ? ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(widget.isEdit ? Icons.save : Icons.send),
                  label: Text(
                    widget.isEdit ? 'Salva modifiche' : 'Crea annuncio',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResQPetColors.accent,
                    foregroundColor: ResQPetColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ) : const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _adozioneFields() => [
    _field(
      _storiaCtrl,
      'Storia', 
      Icons.book,
      validator: (value) {
        return !isLengthBetween(value ?? '', 3, 200)
          ? 'La storia deve essere tra 3 e 200 caratteri'
          : null;
      }
    ),
    _field(
      _noteSanitarieCtrl,
      'Note sanitarie',
      Icons.medical_information,
      validator: (value) {
        return !isLengthBetween(value ?? '', 3, 150)
          ? 'Le note sanitarie devono essere tra 3 e 150 caratteri'
          : null;
      }
    ),
    _field(
      _contributoCtrl,
      'Contributo spese sanitarie',
      Icons.euro,
      keyboard: TextInputType.number,
      validator: (value) {
        final contributo = double.tryParse(value ?? '') ?? -1.0;
        
        return contributo < 0
          ? 'Il contributo alle spese sanitarie deve essere un numero decimale maggiore o uguale a zero'
          : null;
      }
    ),
    _field(
      _carattereCtrl,
      'Carattere',
      Icons.emoji_emotions,
      validator: (value) {
        return !isLengthBetween(value ?? '', 3, 100)
          ? 'Il carattere deve essere tra 3 e 100 caratteri'
          : null;
      }
    ),
  ];

  List<Widget> _venditaFields() => [
    _field(
      _prezzoCtrl,
      'Prezzo',
      Icons.payments,
      keyboard: TextInputType.number,
      validator: (value) {
        final prezzo = double.tryParse(value ?? '') ?? -1;

        return prezzo <= 0
          ? 'Il prezzo deve essere un numero positivo'
          : null;
      }
    ),
    _field(
      _dataNascitaCtrl, 
      'Data di nascita', 
      Icons.cake,
      validator: (value) {
        return !dataRegex.hasMatch(value ?? '')
          ? 'Data di nascita deve essere nel formato gg/mm/aaaa'
          : null;
      }
    ),
    _field(
      _microchipCtrl,
      'Numero microchip',
      Icons.qr_code,
      validator: (value) {
        return !microchipRegex.hasMatch(value ?? '')
          ? 'Il numero di microchip deve contenere esattamente 15 cifre'
          :  null;
      }
    ),
  ];

  Widget _field(
    TextEditingController c,
    String label,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ResQPetTextField(
        controller: c,
        label: label,
        prefixIcon: Icon(icon, color: ResQPetColors.primaryDark),
        textInputType: keyboard,
        validator: validator,
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(annuncioControllerProvider.notifier);

    final nome = _nomeCtrl.text;
    final sesso = _sessoCtrl.text;
    final peso = double.tryParse(_pesoCtrl.text.trim()) ?? 0.0;
    final colorePelo = _coloreCtrl.text;
    final isSterilizzato = _sterilizzato;
    final specie = _specieCtrl.text;
    final razza = _razzaCtrl.text;
    final statoAnnuncio = _salvaComeBozza ? StatoAnnuncio.inAttesa : StatoAnnuncio.attivo;

    final prezzo = double.tryParse(_prezzoCtrl.text) ?? 0;
    final dataNascita =  _dataNascitaCtrl.text;
    final numeroMicrochip = _microchipCtrl.text;

    final storia = _storiaCtrl.text;
    final noteSanitarie = _noteSanitarieCtrl.text;
    final contributoSpeseSanitarie = double.tryParse(_contributoCtrl.text.trim()) ?? 0.0;
    final carattere = _carattereCtrl.text;

    if(!widget.isEdit) {
      
      controller.creaAnnuncio(
        tipo: widget.tipoAnnuncio, 
        nome: nome, 
        sesso: sesso, 
        peso: peso, 
        colorePelo: colorePelo,
        isSterilizzato: isSterilizzato, 
        specie: specie, 
        razza: razza, 
        foto: _foto, 
        statoAnnuncio: statoAnnuncio,

        // Adozione
        storia: storia,
        noteSanitarie: noteSanitarie,
        contributoSpeseSanitarie: contributoSpeseSanitarie,
        carattere: carattere,

        // Vendita
        prezzo: prezzo,
        dataNascita: dataNascita,
        numeroMicrochip: numeroMicrochip
      );

      return;
    }

    Annuncio annuncio;

    if(widget.annuncio is AnnuncioVendita) {

      final vendita = widget.annuncio as AnnuncioVendita;

      annuncio = vendita.copyWith(
        nome: nome,
        sesso: sesso,
        peso: peso,
        colorePelo: colorePelo,
        isSterilizzato: isSterilizzato,
        specie: specie,
        razza: razza,
        statoAnnuncio: statoAnnuncio,
        prezzo: double.tryParse(_prezzoCtrl.text) ?? 0,
        dataNascita: _dataNascitaCtrl.text,
        numeroMicrochip: _microchipCtrl.text
      );
    } else {
      final adozione = widget.annuncio as AnnuncioAdozione;

      annuncio = adozione.copyWith(
        nome: nome,
        sesso: sesso,
        peso: peso,
        colorePelo: colorePelo,
        isSterilizzato: isSterilizzato,
        specie: specie,
        razza: razza,
        statoAnnuncio: statoAnnuncio,
        storia: _storiaCtrl.text,
        noteSanitarie: _noteSanitarieCtrl.text,
        contributoSpeseSanitarie: double.tryParse(_contributoCtrl.text.trim()) ?? 0.0,
        carattere: _carattereCtrl.text,
      );
    }

    controller.aggiornaAnnuncio(annuncio);
  }
}