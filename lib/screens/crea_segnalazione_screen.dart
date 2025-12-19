import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:resqpet/controllers/segnalazioni_controller.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class CreaSegnalazioneScreen extends ConsumerStatefulWidget {

  const CreaSegnalazioneScreen({super.key});

  @override
  ConsumerState<CreaSegnalazioneScreen> createState() {
    return _CreaSegnalazioneScreenState();
  }

}

class _CreaSegnalazioneScreenState extends ConsumerState<CreaSegnalazioneScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _labelController;
  late TextEditingController _descrizioneController;
  late TextEditingController _indirizzoController;

  final List<XFile> selectedFile = [];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
    _descrizioneController = TextEditingController();
    _indirizzoController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _labelController.dispose();
    _descrizioneController.dispose();
    _indirizzoController.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if(selectedFile.isEmpty) {
      showErrorSnackBar(context, "Fornire almeno un'immagine!");
      return;
    }

    final currentLocation = await getCurrentLocation(context);

    await ref.read(segnalazioneControllerProvider.notifier)
      .creaSegnalazione(
        descrizione: "${_labelController.text.trim()}\n${_descrizioneController.text.trim()}", 
        coordinate: currentLocation, 
        indirizzo: _indirizzoController.text.trim(), 
        foto: selectedFile.map((xfile) => File(xfile.path)).toList()
      );
  }

  Future<void> pickImage(BuildContext context, { bool fromCamera = false}) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery
    );

    if(image == null) {

      if(context.mounted) {
        showErrorSnackBar(
          context,
          "Impossibile caricare l'immagine"
        );
      }
      return;
    }

    setState(() {
      selectedFile.add(image);
    });

    if(context.mounted) {
      showSnackBar(context, "Immaggine caricata.");
    }
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(segnalazioneControllerProvider, (_, state) {

      if(state is SegnalazioneError) {
        showErrorSnackBar(context, state.message);
        return;
      }

      if(state is SegnalazioneSuccess) {
        showSnackBar(context, "Segnalazione effettuata!");
        context.pop();
        return;
      }

    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        title: const Text('Nuova Segnalazione'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          spacing: 30,
          children: [
            SizedBox(
              width: 140,
              child: Image.asset('assets/logo-con-scritta.png'),
            ),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    offset: Offset(5, 5),
                    color: Colors.black12
                  )
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: AlignmentGeometry.center,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    height: 150,
                    child: Image.asset(
                      "assets/card1.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                  Align(
                    alignment: AlignmentGeometry.center,
                    child: Container(
                      height: 150,
                      color: Color.fromARGB(95, 0, 0, 0)
                    )
                  ),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) => Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 70
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ResQPetColors.accent
                                    ),
                                    onPressed: () async {

                                      try {
                                        await pickImage(context, fromCamera: true);
                                      } catch(_) {
                                        if(context.mounted) {
                                          showErrorSnackBar(
                                            context, 
                                            "Si e' verificato un errore durante l'acquisizione della foto."
                                          );
                                        }
                                      } finally {
                                        if(context.mounted) {
                                          context.pop();
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Scatta una Foto',
                                      style: TextStyle(
                                        color: ResQPetColors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ResQPetColors.white
                                      ),
                                      onPressed: () async {
                                        try {
                                          await pickImage(context);
                                        } catch(_) {
                                          if(context.mounted) {
                                            showErrorSnackBar(
                                              context, 
                                              "Si e' verificato un errore durante il caricamento della foto dalla galleria."
                                            );
                                          }
                                        } finally {
                                          if(context.mounted) {
                                            context.pop();
                                          }
                                        }
                                      },
                                      child: const Text(
                                        'Carica dalla Galleria',
                                        style: TextStyle(
                                          color: ResQPetColors.onBackground,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          );
                        },
                        color: ResQPetColors.white,
                        iconSize: 35,
                        icon: Icon(Icons.cloud_upload_outlined)
                      ),
                      Text(
                        "Carica una foto!",
                        style: TextStyle(
                          color: ResQPetColors.white,
                          fontWeight: FontWeight.w800
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                spacing: 20,
                children: [
                  ResQPetTextField(
                    controller: _labelController,
                    label: 'Etichetta',
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Inserisci un\'etichetta.'
                            : null,
                  ),
                  ResQPetTextField(
                    controller: _descrizioneController,
                    maxLines: 4,
                    label: 'Descrizione',
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Inserisci una descrizione'
                            : null,
                  ),
                  ResQPetTextField(
                    controller: _indirizzoController,
                    label: 'Indirizzo',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    validator: (value) =>
                        (value == null || value.isEmpty)
                            ? 'Inserisci un indirizzo'
                            : null,
                  ),
                  Text("L'applicazione oltre all'indirizzo registra anche la posizione attuale da cui la segnalazione viene effettuata.")
                ],
              ),
            ),
            const Divider(height: 12),
            Row(
              spacing: 10,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResQPetColors.accent
                  ),
                  onPressed: () async {
                    try { 
                      await _submit();
                    } catch (_) {
                      if(!context.mounted) return;
                      showErrorSnackBar(context, "Si e' verificato un errore");
                    }
                  },
                  child: const Text(
                    'Invia Segnalazione',
                    style: TextStyle(
                      color: ResQPetColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResQPetColors.white
                  ),
                  onPressed: (){
                    context.pop();
                  },
                  child: const Text(
                    'Annulla',
                    style: TextStyle(
                      color: ResQPetColors.onBackground,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}