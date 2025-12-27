import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/controllers/image_controller.dart';
import 'package:resqpet/controllers/utente_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/image_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class DettagliAnnuncioScreen extends ConsumerWidget {

  final Annuncio annuncio;
  final Utente creatore;

  const DettagliAnnuncioScreen({
    super.key, 
    required this.annuncio,
    required this.creatore
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imagesAsyncValue = ref.watch(getImagesFromCloudProvider(annuncio.foto));
    final currentUID = ref.read(currentUserIdProvider);

    ref.listen(annuncioControllerProvider, (_, state) {
      if(state is AnnuncioError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is AnnuncioFinalizzatoSuccess) {
        showSnackBar(context, "Annuncio Finalizzato!");
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(
          color: annuncio.tipo == TipoAnnuncio.vendita
              ? ResQPetColors.primaryDark
              : ResQPetColors.accent,
        ),
        actions: [
          if(currentUID != annuncio.creatoreRef) IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.report)
          ),
          if(currentUID == annuncio.creatoreRef 
            && annuncio.statoAnnuncio != StatoAnnuncio.concluso) 
            IconButton(
              onPressed: () {
                context.pushNamed(
                  Routes.aggiornaAnnuncio.name,
                  pathParameters: {
                    'tipo': annuncio.tipo.toFirestore()
                  },
                  extra: annuncio,
                );
              }, 
              icon: Icon(Icons.edit)
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            imagesAsyncValue.whenOrNull(
              data: (urls) => _buildImageGallery(urls),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              )
            ) ?? _buildImageGallery(annuncio.foto),
            const SizedBox(height: 16),

            // Nome dell'animale
            Text(
              annuncio.nome,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: ResQPetColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // Dettagli Specifici (Vendita o Adozione) - Contiene la Hero Card
            if (annuncio is AnnuncioVendita)
              _buildDettagliVendita(annuncio as AnnuncioVendita),

            if (annuncio is AnnuncioAdozione)
              _buildDettagliAdozione(annuncio as AnnuncioAdozione),

            const SizedBox(height: 20),

            // Informazioni Principali (Comuni a tutti gli Annunci)
            _buildSectionBox(
              title: 'Informazioni Generali 🐾',
              children: [
                _buildDettaglio('Specie:', annuncio.specie),
                _buildDettaglio('Razza:', annuncio.razza),
                _buildDettaglio('Sesso:', annuncio.sesso),
                _buildDettaglio('Peso:', "${annuncio.peso} Kg"),
                _buildDettaglio('Colore Pelo:', annuncio.colorePelo),
                _buildDettaglio(
                  'Sterilizzato:',
                  annuncio.isSterilizzato ? 'Sì' : 'No',
                ),
                _buildDettaglio(
                  'Stato Annuncio:',
                  annuncio.statoAnnuncio.toString().split('.').last,
                  color: annuncio.statoAnnuncio == StatoAnnuncio.attivo
                      ? Colors.green
                      : Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionBox(
              title: 'Informazioni ${annuncio.tipo == TipoAnnuncio.vendita ? 'Venditore' : 'Ente'}',
              children: [
                if(creatore is Venditore) _buildDettaglio(
                  'Indirizzo:', (creatore as Venditore).indirizzo 
                ),
                if(creatore is Ente) _buildDettaglio(
                  'Indirizzo:', (creatore as Ente).sedeLegale 
                ),
                _buildDettaglio('Nome:', creatore.nominativo),
                _buildDettaglio('Email:', creatore.email),
                _buildDettaglio('Telefono:', creatore.numeroTelefono),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: (currentUID != annuncio.creatoreRef) 
        ? FloatingActionButton.extended(
            onPressed: () async {
              
              final telephoneUri = Uri(
                scheme: 'tel',
                path: creatore.numeroTelefono
              );

              if(await canLaunchUrl(telephoneUri)) {
                await launchUrl(telephoneUri);
                return;
              } 
                
              if(!context.mounted) return;
              showErrorSnackBar(context, "Si e' verificato un errore.");
            },
            backgroundColor: ResQPetColors.accent,
            icon: const Icon(Icons.phone, color: ResQPetColors.white),
            label: const Text(
              'Contatta',
              style: TextStyle(
                color: ResQPetColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : FloatingActionButton.extended(
            onPressed: (annuncio.statoAnnuncio != StatoAnnuncio.concluso) 
              ? () async {
                ref.read(annuncioControllerProvider.notifier)
                  .finalizzaAnnuncio(annuncio);
              } 
              : null,
            backgroundColor: (annuncio.statoAnnuncio != StatoAnnuncio.concluso) 
              ? const Color(0xFF4CAF50)
              : Color(0xFFFF5722),
            icon: const Icon(Icons.check, color: ResQPetColors.white),
            label: Text(
              (annuncio.statoAnnuncio != StatoAnnuncio.concluso) 
                ? 'Finalizza'
                : 'Concluso',
              style: TextStyle(
                color: ResQPetColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
    );
  }

  // --- Metodi Costruttori per Sezioni ---

  Widget _buildImageGallery(List<String> fotoUrls) {
    if (fotoUrls.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Icon(Icons.photo_library, size: 50, color: Colors.grey),
        ),
      );
    }

    return ImageCarousel(
      images: fotoUrls, 
      isSourceNetwork: true
    );
  }

  Widget _buildSectionBox({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ResQPetColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSezione(title), ...children],
      ),
    );
  }

  Widget _buildSezione(String titolo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        titolo,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ResQPetColors.primaryDark,
        ),
      ),
    );
  }

  Widget _buildDettaglio(
    String etichetta,
    String valore, {
    Color? color,
    bool isImportant = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$etichetta ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isImportant ? Colors.black87 : Colors.black54,
            ),
          ),
          Expanded(
            child: Text(
              valore,
              style: TextStyle(
                fontWeight: isImportant ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
                color: color ?? Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDettagliVendita(AnnuncioVendita vendita) {
    return Column(
      children: [
        // Hero Price Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ResQPetColors.primaryDark,
                ResQPetColors.primaryDark.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ResQPetColors.primaryDark.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'PREZZO DI VENDITA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '€ ${vendita.prezzo.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Other Details Grid
        _buildSectionBox(
          title: 'Specifiche Tecniche 📋',
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildHeroInfo(
                    'Data Nascita',
                    vendita.dataNascita,
                    Icons.cake,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildHeroInfo(
                    'Microchip',
                    vendita.numeroMicrochip,
                    Icons.qr_code,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroInfo(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ResQPetColors.primaryDark.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ResQPetColors.primaryDark.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ResQPetColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: ResQPetColors.primaryDark.withValues(alpha: 0.6),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: ResQPetColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDettagliAdozione(AnnuncioAdozione adozione) {
    return Column(
      children: [
        // Hero Adoption Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ResQPetColors.accent,
                ResQPetColors.accent.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ResQPetColors.accent.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.white, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ADOZIONE DEL CUORE',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adozione.contributoSpeseSanitarie == 0
                          ? 'Adozione Gratuita'
                          : 'Richiesto contributo: ${adozione.contributoSpeseSanitarie} Euro',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildSectionBox(
          title: 'Storia dell\'Animale 📖',
          children: [
            _buildDescrizione(adozione.storia),
            const SizedBox(height: 16),
            _buildSezioneDescrizione('Carattere 😺'),
            _buildDescrizione(adozione.carattere),
            const SizedBox(height: 16),
            _buildSezioneDescrizione('Note Sanitarie 🩺'),
            _buildDescrizione(adozione.noteSanitarie),
          ],
        ),
      ],
    );
  }

  Widget _buildSezioneDescrizione(String titolo) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        titolo,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDescrizione(String testo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ResQPetColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Text(
        testo.isEmpty ? 'Nessuna informazione aggiuntiva fornita.' : testo,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}