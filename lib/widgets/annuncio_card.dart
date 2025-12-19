import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/dati_utente_controller.dart';
import 'package:resqpet/controllers/image_controller.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/image_carousel.dart';

class AnnuncioCard extends ConsumerWidget {
  final Annuncio annuncio;
  final void Function()? onViewDetailsClick;

  const AnnuncioCard({
    required this.annuncio,
    this.onViewDetailsClick,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final imagesAsyncValue = ref.watch(getImagesFromCloudProvider(annuncio.foto));
    final datiUtenteAsyncValue = ref.watch(datiUtenteByIdProvider(annuncio.creatoreRef));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          datiUtenteAsyncValue.when(
            data: (utente) => Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                spacing: 10,
                children: [
                  CircleAvatar(
                    backgroundColor: ResQPetColors.primaryVariant,
                    child: Text(
                      utente.nominativo[0],
                      style: const TextStyle(
                        color: ResQPetColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        utente.nominativo,
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      if(utente is Ente) Text(utente.sedeLegale),
                      if(utente is Venditore) Text(utente.indirizzo)
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.more_vert),
                ],
              ),
            ),
            loading: () => CircularProgressIndicator(),
            error: (error, _) => SizedBox()
          ),
          imagesAsyncValue.when(
            data: (images) => ImageCarousel(
              images: images, isSourceNetwork: true
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
              spacing: 4,
              children: [
                Text(
                  annuncio.nome,
                  style: TextStyle(
                    color: ResQPetColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(annuncio.razza),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  spacing: 10,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ResQPetColors.accent,
                      ),
                      onPressed: () {
                        onViewDetailsClick?.call();
                      },
                      child: Text(
                        "Vedi Dettagli",
                        style: TextStyle(
                          color: ResQPetColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
