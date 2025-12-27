import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/dati_utente_controller.dart';
import 'package:resqpet/controllers/image_controller.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/image_carousel.dart';

class AnnuncioCard extends ConsumerWidget {
  final Annuncio annuncio;
  final List<Widget> Function(Annuncio, Utente)? actions;

  const AnnuncioCard({
    required this.annuncio,
    this.actions,
    super.key,
  });

  String _getAnnuncioDescrizione() {
    if(annuncio is AnnuncioAdozione) {
      return (annuncio as AnnuncioAdozione).storia;
    }

    return annuncio.specie;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imagesAsyncValue = ref.watch(getImagesFromCloudProvider(annuncio.foto));
    final datiUtenteAsyncValue = ref.watch(datiUtenteByIdProvider(annuncio.creatoreRef));

    return Card(
      color: ResQPetColors.surface,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          datiUtenteAsyncValue.when(
            data: (utente) => Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: ResQPetColors.primaryDark.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_circle,
                      color: ResQPetColors.primaryDark,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          annuncio.tipo == TipoAnnuncio.vendita ? "Privato" : "Canile",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: ResQPetColors.primaryDark,
                          ),
                        ),
                        const Text(
                          "Fisciano",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Badge Tipo Annuncio
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: annuncio.tipo == TipoAnnuncio.vendita
                        ? ResQPetColors.primaryDark.withValues(alpha: 0.1)
                        : ResQPetColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      annuncio.tipo == TipoAnnuncio.vendita ? "Vendita" : "Adozione",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: annuncio.tipo == TipoAnnuncio.vendita
                          ? ResQPetColors.primaryDark
                          : ResQPetColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => Center(
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(),
              )
            ) ,
            error: (error, _) => SizedBox()
          ),
          imagesAsyncValue.when(
            data: (images) => ImageCarousel(
              images: images,
              isSourceNetwork: true
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => SizedBox(),
          ),
          Padding(
            padding: EdgeInsetsGeometry.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Row(
                  children: [
                    Icon(Icons.pets, size: 16, color: ResQPetColors.accent),
                    const SizedBox(width: 6),
                    Text(
                      annuncio.nome,
                      style: const TextStyle(
                        color: ResQPetColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                Text(
                  annuncio.razza,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ResQPetColors.onBackground,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _getAnnuncioDescrizione(),
                  style: TextStyle(
                    fontSize: 17, 
                    color: Colors.grey.shade600
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 7),
                datiUtenteAsyncValue.whenOrNull(
                  data: (utente) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: actions?.call(annuncio, utente) ?? []
                  ),
                ) ?? SizedBox()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
