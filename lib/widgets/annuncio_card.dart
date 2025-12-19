import 'package:flutter/material.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/theme.dart';

class AnnuncioCard extends StatelessWidget {
  final Annuncio annuncio;
  final void Function()? onViewDetailsClick;

  const AnnuncioCard({
    required this.annuncio,
    this.onViewDetailsClick,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              spacing: 10,
              children: [
                Icon(Icons.account_circle),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      annuncio.tipo == TipoAnnuncio.vendita ? "Privato" : "Canile",
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Text("Indirizzo"),
                  ],
                ),
                Spacer(),
                Icon(Icons.more_vert),
              ],
            ),
          ),
          SizedBox(
            child: Image.network(
              annuncio.foto.first,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
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
                        backgroundColor: ResQPetColors.white,
                      ),
                      onPressed: () {},
                      child: const Text(
                        'Vedi Dettagli',
                        style: TextStyle(
                          color: ResQPetColors.onBackground,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ResQPetColors.accent,
                      ),
                      onPressed: () {
                        onViewDetailsClick?.call();
                      },
                      child: Text(
                        annuncio.tipo == TipoAnnuncio.vendita ? "Compra" : "Adotta",
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
