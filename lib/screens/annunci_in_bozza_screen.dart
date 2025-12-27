import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/annuncio/stato_annuncio.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/annuncio_card.dart';
import 'package:resqpet/widgets/info_message.dart';
import 'package:resqpet/widgets/resqpet_button.dart';

class AnnunciInBozzaScreen extends ConsumerStatefulWidget {
  const AnnunciInBozzaScreen({
    super.key
  });
  
  @override
  ConsumerState<AnnunciInBozzaScreen> createState() {
    return _AnnunciInBozzaScreenState();
  }
}

class _AnnunciInBozzaScreenState extends ConsumerState<AnnunciInBozzaScreen> {

  Future<bool?> showConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Conferma'),
          content: const Text("Sicuro di voler cancellare l'annuncio?"),
          actions: [
            TextButton(
              onPressed: () {
                context.pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                context.pop(true);
              },
              child: const Text('Si'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final annunciAsyncValue = ref.watch(annunciPubblicatiProvider);

    ref.listen(annuncioControllerProvider, (_, state) {
      if(state is AnnuncioError) {
        showErrorSnackBar(context, state.message);
      }
    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [ 
          Positioned.fill(
            child: Image.asset(
              'assets/home_background.png', 
              fit: BoxFit.cover
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              spacing: 10,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if(context.canPop()) IconButton(
                      onPressed: () => context.pop(), 
                      icon: Icon(Icons.arrow_back)
                    ), 
                    Text(
                      "Bozze",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800
                      ),
                    )
                  ]
                ),
                annunciAsyncValue.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, _) => Center(
                    child: Center(
                      child: InfoMessage(message: error.toString()),
                    ),
                  ),
                  data: (annunci) {

                    final filtered = annunci
                      .where((annuncio) => annuncio.statoAnnuncio == StatoAnnuncio.inAttesa)
                      .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: InfoMessage(message: "Non sono presenti Bozze :("),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {

                        final annuncio = filtered[index];
                        return AnnuncioCard(
                          annuncio: annuncio, 
                          actions: (annuncio, utente) => [
                            Expanded(
                              child: ResQPetButton(
                                text: "Modifica",
                                onPressed: () {
                                  context.pushNamed(
                                    Routes.aggiornaAnnuncio.name,
                                    pathParameters: {
                                      'tipo': annuncio.tipo.toFirestore()
                                    },
                                    extra: annuncio,
                                  );
                                },
                              )
                            ),
                          ]
                        );
                      }
                    );
                  }
                )
              ]
            ),
          )
        ]
      ),
    );
  }
}
