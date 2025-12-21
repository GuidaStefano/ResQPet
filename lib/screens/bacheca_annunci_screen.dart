import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/widgets/annuncio_card.dart';

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

  @override
  Widget build(BuildContext context) {
    
    final annunciAsyncValue = ref.watch(annunciProvider(
      tipo: widget.tipoAnnuncio
    ));

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 50
        ),
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
                  "Annunci",
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800
                  ),
                )
              ]
            ),
            SearchAnchor(
              builder: (context, controller) => SearchBar(
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
                child: Text("Errore: $error"),
              ),
              data: (annunci) {

                if (annunci.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50),
                      child: Text("Non ci sono annunci da visualizzare :("),
                    ),
                  );
                }
                
                final filtered = annunci.where((annuncio){
                  return annuncio.colorePelo.contains(_searchQuery) 
                    || annuncio.nome.contains(_searchQuery)
                    || annuncio.sesso.contains(_searchQuery)
                    || annuncio.razza.contains(_searchQuery);
                })
                .toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {

                    final annuncio = filtered[index];
                    return AnnuncioCard(
                      annuncio: annuncio, 
                      onViewDetailsClick: (utente, annuncio) {
                        context.pushNamed(
                          Routes.dettagliAnnuncio.name,
                          extra:  {
                            'annuncio': annuncio,
                            'creatore': utente
                          }
                        );
                      }
                    );
                  }
                );
              }
            )
          ]
        ),
      ),
    );
  }
}
