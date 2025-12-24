import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/image_controller.dart';
import 'package:resqpet/models/segnalazione.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/image_carousel.dart';

class SegnalazioneCard extends ConsumerWidget {

  final Segnalazione segnalazione;
  final List<Widget>? actions;

  const SegnalazioneCard({
    super.key,
    required this.segnalazione,
    this.actions
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final images = ref.watch(getImagesFromCloudProvider(segnalazione.foto));

    return Container(
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
          // Header Utente
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                images.when(
                  data: (urls) => ImageCarousel(
                    images: urls,
                    isSourceNetwork: true
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, _) => ImageCarousel(images: [], isSourceNetwork: false)
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pets, size: 16, color: ResQPetColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            segnalazione.indirizzo,
                            style: const TextStyle(
                              color: ResQPetColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        segnalazione.descrizione,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ResQPetColors.onBackground,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Pulsanti
                      if(actions != null) SizedBox(
                        width: double.infinity,
                        child: Column(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: actions ?? []
                        ),
                      )
                    ],
                  ),
                )
              ]
            )
          )
        ]
      )
    );
  }
}
