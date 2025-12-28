import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/segnalazioni_controller.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/photo_upload_card.dart';
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

  final List<File> selectedFile = [];

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

  Future<void> selectImage(BuildContext context, { bool fromCamera = false}) async {

    try {
      final file = await pickImage(context, fromCamera: fromCamera);

      setState(() {
        selectedFile.add(File(file.path));
      });

      if(context.mounted) {
        showSnackBar(context, "Immaggine caricata.");
      }
    } on StateError catch(e) {
      if(context.mounted) {
        showErrorSnackBar(
          context,
          e.message
        );
      }
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
          spacing: 10,
          children: [
            SizedBox(
              width: 140,
              child: Image.asset('assets/logo-con-scritta.png'),
            ),
            PhotoUploadCard(
              onPickImageFromCamera: () {
                selectImage(context, fromCamera: true);
              }, 
              onPickImageFromGallery: () {
                selectImage(context);
              }, 
              selectedImages: selectedFile
            ),
            const SizedBox(height: 5),
            _buildFormSection(),
            const SizedBox(height: 20),
            _buildGPSInfoCard(),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.send),
                label: const Text(
                  'Invia Segnalazione',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ResQPetColors.accent,
                  foregroundColor: ResQPetColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      )
    );
  }

  Widget _buildGPSInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.gps_fixed, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Posizione Automatica',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'La posizione GPS verrà registrata automaticamente al momento dell\'invio',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dettagli Segnalazione',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ResQPetColors.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          ResQPetTextField(
            controller: _labelController,
            label: 'Titolo',
            prefixIcon: const Icon(Icons.title),
            validator: (value) => (value == null || value.trim().isEmpty) 
              ? 'Inserisci un titolo' 
              : null,
          ),
          const SizedBox(height: 12),
          ResQPetTextField(
            controller: _descrizioneController,
            maxLines: 4,
            label: 'Descrizione',
            prefixIcon: const Icon(Icons.description),
            validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Inserisci una descrizione'
              : null,
          ),
          const SizedBox(height: 12),
          ResQPetTextField(
            label: 'Indirizzo',
            controller: _indirizzoController,
            prefixIcon: Icon(Icons.location_on),
            validator: (value) => (value == null || value.trim().isEmpty)
              ? 'Inserisci un indirizzo'
              : null,
          ),
        ],
      ),
    );
  }
}