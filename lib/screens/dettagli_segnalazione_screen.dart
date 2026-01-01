import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/image_controller.dart';
import 'package:resqpet/controllers/segnalazioni_controller.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/segnalazione.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/image_carousel.dart';
import 'package:url_launcher/url_launcher.dart';

class DettagliSegnalazioneScreen extends ConsumerWidget {

  final Segnalazione segnalazione;
  final bool isEnte;
  final bool isCittadino;

  const DettagliSegnalazioneScreen({
    super.key, 
    required this.segnalazione,
    this.isEnte = false,
    this.isCittadino = false
  });

  // Helper per determinare il colore basato sullo stato
  Color _getStatoColor(StatoSegnalazione stato) {
    return switch (stato) {
      StatoSegnalazione.inAttesa => const Color(0xFFF59E0B),
      StatoSegnalazione.presoInCarica => const Color(0xFF3B82F6),
      StatoSegnalazione.risolto => const Color(0xFF10B981),
    };
  }

  // Helper per l'icona dello stato
  IconData _getStatoIcon(StatoSegnalazione stato) {
    return switch (stato) {
      StatoSegnalazione.inAttesa => Icons.schedule,
      StatoSegnalazione.presoInCarica => Icons.local_shipping,
      StatoSegnalazione.risolto => Icons.check_circle,
    };
  }

  String _getTempoTrascorso(DateTime dataCreazione) {

    final diff = DateTime.now().difference(dataCreazione);

    if (diff.inMinutes < 1) return 'ora';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min fa';
    if (diff.inHours < 24) return '${diff.inHours} h fa';
    if (diff.inDays < 7) return '${diff.inDays} g fa';

    return '${diff.inDays ~/ 7} sett fa';
  }


  Widget? _buildFab(
    BuildContext context, 
    WidgetRef ref
  ) {

    if(segnalazione.stato == StatoSegnalazione.inAttesa && !isEnte && !isCittadino) {
      return FloatingActionButton.extended(
        onPressed: () async {
          ref.read(segnalazioneControllerProvider.notifier)
            .prendiInCarico(segnalazione.id);

          if(context.mounted) context.pop();
        },
        backgroundColor: ResQPetColors.accent,
        icon: const Icon(
          Icons.volunteer_activism,
          color: ResQPetColors.white,
        ),
        label: const Text(
          'Prendi in carico',
          style: TextStyle(
            color: ResQPetColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if(isEnte && segnalazione.stato == StatoSegnalazione.presoInCarica) {
      return FloatingActionButton.extended(
        onPressed: () async {
          ref.read(segnalazioneControllerProvider.notifier)
            .risolviSegnalazione(segnalazione.id);

          if(context.mounted) context.pop();
        },
        backgroundColor: ResQPetColors.accent,
        icon: const Icon(
          Icons.check,
          color: ResQPetColors.white,
        ),
        label: const Text(
          'Finalizza',
          style: TextStyle(
            color: ResQPetColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if(isCittadino && segnalazione.stato == StatoSegnalazione.inAttesa) {
      return FloatingActionButton.extended(
        onPressed: () async {
          ref.read(segnalazioneControllerProvider.notifier)
            .cancellaSegnalazione(segnalazione.id);

          if(context.mounted) context.pop();
        },
        backgroundColor: Colors.red,
        icon: const Icon(
          Icons.cancel,
          color: ResQPetColors.white,
        ),
        label: const Text(
          'Cancella',
          style: TextStyle(
            color: ResQPetColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color statoColor = _getStatoColor(segnalazione.stato);

    final imagesAsyncValue = ref.watch(getImagesFromCloudProvider(segnalazione.foto));

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
        iconTheme: IconThemeData(color: statoColor),
        title: const Text(
          'Dettagli Segnalazione',
          style: TextStyle(color: ResQPetColors.primaryDark),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imagesAsyncValue.when(
              data: (urls) => _buildImageGallery(urls),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (_, _) => _buildImageGallery([])
            ),
            const SizedBox(height: 20),

            _buildHeroStatoCard(segnalazione.stato, statoColor),
            const SizedBox(height: 20),
            _buildSectionBox(
              title: 'Timeline Segnalazione ⏱️',
              children: [_buildTimeline(segnalazione)],
            ),
            _buildSectionBox(
              title: 'Descrizione 📝',
              children: [_buildDescrizione(segnalazione.descrizione)],
            ),
            _buildSectionBox(
              title: 'Posizione 📍',
              children: [_buildLocationCard(context, segnalazione)],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _buildFab(context, ref)
    );
  }

  Widget _buildImageGallery(List<String> fotoUrls) {
    if (fotoUrls.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Nessuna foto disponibile',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ImageCarousel(
      images: fotoUrls, 
      isSourceNetwork: true
    );
  }

  Widget _buildHeroStatoCard(StatoSegnalazione stato, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getStatoIcon(stato), color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATO ATTUALE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stato.value.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTempoTrascorso(segnalazione.dataCreazione.toDate()),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: ResQPetColors.white,
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
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ResQPetColors.primaryDark,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimeline(Segnalazione segnalazione) {
    return Column(
      children: [
        _buildTimelineItem(
          'Segnalazione Creata',
          formatDate(segnalazione.dataCreazione.toDate()),
          Icons.add_alert,
          true,
          Colors.green,
        ),
        if (segnalazione.stato == StatoSegnalazione.presoInCarica ||
            segnalazione.stato == StatoSegnalazione.risolto)
          _buildTimelineItem(
            'Presa in Carico',
            'Da determinare',
            Icons.local_shipping,
            true,
            Colors.blue,
          ),
        if (segnalazione.stato == StatoSegnalazione.risolto)
          _buildTimelineItem(
            'Risolto',
            'Da determinare',
            Icons.check_circle,
            true,
            Colors.green,
          ),
        if (segnalazione.stato == StatoSegnalazione.inAttesa)
          _buildTimelineItem(
            'In Attesa',
            'In corso...',
            Icons.schedule,
            false,
            Colors.grey,
          ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time,
    IconData icon,
    bool completed,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: completed ? color : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: completed ? Colors.white : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: completed ? Colors.black87 : Colors.grey,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: completed ? Colors.black54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescrizione(String testo) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResQPetColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        testo.isEmpty ? 'Nessuna descrizione fornita.' : testo,
        style: const TextStyle(fontSize: 15, height: 1.5),
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Segnalazione segnalazione) {
    return Column(
      children: [
        // Mini mappa interattiva
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  segnalazione.posizione.latitude,
                  segnalazione.posizione.longitude,
                ),
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.resqpet.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        segnalazione.posizione.latitude,
                        segnalazione.posizione.longitude,
                      ),
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoCard(
          'Indirizzo',
          segnalazione.indirizzo,
          Icons.location_on,
          ResQPetColors.accent,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Latitudine',
                segnalazione.posizione.latitude.toStringAsFixed(4),
                Icons.south,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Longitudine',
                segnalazione.posizione.longitude.toStringAsFixed(4),
                Icons.east,
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {

            final latitude = segnalazione.posizione.latitude;
            final longitude = segnalazione.posizione.longitude;

            final googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
            if (await canLaunchUrl(Uri.parse(googleUrl))) {
              await launchUrl(Uri.parse(googleUrl));
              return;
            } 

            if(!context.mounted) return;
            showErrorSnackBar(context, "Impossibile aprire la mappa esterna.");
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Apri in Maps'),
          style: ElevatedButton.styleFrom(
            backgroundColor: ResQPetColors.primaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color.withValues(alpha: 0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
