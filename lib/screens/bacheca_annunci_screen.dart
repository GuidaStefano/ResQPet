import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/annuncio_card.dart';
import 'package:resqpet/widgets/info_message.dart';
import 'package:resqpet/widgets/resqpet_button.dart';

class BachecaAnnunciScreen extends ConsumerStatefulWidget {
  final TipoAnnuncio? tipoAnnuncio;

  const BachecaAnnunciScreen({
    super.key,
    this.tipoAnnuncio
  });
  
  @override
  ConsumerState<BachecaAnnunciScreen> createState() {
    return _BachecaAnnunciScreenState();
  }
}

class _BachecaAnnunciScreenState extends ConsumerState<BachecaAnnunciScreen> {

  String _searchQuery = '';

  String _getTitoloSezione() {
    return switch (widget.tipoAnnuncio) {
      TipoAnnuncio.adozione => "Adozioni",
      TipoAnnuncio.vendita => "Vendita",
      _ => "Annunci",
    };
  }

  @override
  Widget build(BuildContext context) {
    
    final annunciAsyncValue = ref.watch(annunciProvider(
      tipo: widget.tipoAnnuncio
    ));

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
                      _getTitoloSezione(),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w800
                      ),
                    )
                  ]
                ),
                SearchAnchor(
                  builder: (context, controller) => SearchBar(
                    backgroundColor: const WidgetStatePropertyAll<Color>(ResQPetColors.white),
                    hintText: "Cerca Annuncio",
                    controller: controller,
                    leading: const Icon(Icons.search),
                    trailing: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                          });
                        }, 
                        icon: Icon(Icons.clear)
                      )
                    ],
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onChanged: (query) {
                      setState(() {
                        _searchQuery = query;
                      });
                    },
                  ), 
                  suggestionsBuilder: (context, controller) => []
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

                    final query = _searchQuery.trim().toLowerCase();

                    final filtered = annunci.where((annuncio) {
                      return annuncio.colorePelo.toLowerCase().contains(query) 
                        || annuncio.nome.toLowerCase().contains(query)
                        || annuncio.sesso.toLowerCase().contains(query)
                        || annuncio.razza.toLowerCase().contains(query);
                    })
                    .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: InfoMessage(message: "Non ci sono annunci da visualizzare :("),
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
                          actions: (annuncio, utente) {

                            return [
                              SizedBox(
                                width: double.infinity,
                                child: ResQPetButton(
                                  text: "Dettagli",
                                  onPressed: () {
                                    context.pushNamed(
                                      Routes.dettagliAnnuncio.name,
                                      extra:  {
                                        'annuncio': annuncio,
                                        'creatore': utente
                                      }
                                    );
                                  },
                                ),
                              )
                            ];
                          },
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
