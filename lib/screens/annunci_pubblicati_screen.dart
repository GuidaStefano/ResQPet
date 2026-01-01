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

class AnnunciPubblicatiScreen extends ConsumerStatefulWidget {

  const AnnunciPubblicatiScreen({ super.key });
  
  @override
  ConsumerState<AnnunciPubblicatiScreen> createState() {
    return _AnnunciPubblicatiScreenState();
  }
}

class _AnnunciPubblicatiScreenState extends ConsumerState<AnnunciPubblicatiScreen> {

  StatoAnnuncio _filtroStatoAnnuncio = StatoAnnuncio.attivo;
  String _searchQuery = '';

  Widget _buildFilterTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(StatoAnnuncio.attivo),
          const SizedBox(width: 8),
          _buildFilterChip(StatoAnnuncio.concluso),
        ],
      ),
    );
  }

  Widget _buildFilterChip(StatoAnnuncio stato) {
    final isSelected = _filtroStatoAnnuncio == stato;

    return FilterChip(
      label: Text(stato.value.toLowerCase(),),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroStatoAnnuncio = stato;
        });
      },
      backgroundColor: ResQPetColors.white,
      selectedColor: ResQPetColors.primaryDark,
      labelStyle: TextStyle(
        color: isSelected ? ResQPetColors.white : ResQPetColors.primaryDark,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
            ? ResQPetColors.primaryDark
            : ResQPetColors.primaryDark.withValues(alpha: 0.3),
        ),
      )
    );
  }

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

    ref.listen(annuncioControllerProvider, (prev, state) {
      if(state is AnnuncioError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is AnnuncioRimossoSuccess) {
        showSnackBar(context, "Annuncio rimosso!");
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
                      "Pubblicati",
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
                _buildFilterTabs(),
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

                    final filtered = annunci
                      .where((annuncio) => annuncio.statoAnnuncio == _filtroStatoAnnuncio)
                      .where((annuncio) {
                        return annuncio.nome.toLowerCase().contains(query);
                      })
                      .toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: InfoMessage(message: "La ricerca non ha prodotto risultati :("),
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
                              )
                            ),
                            Expanded(
                              child: ResQPetButton(
                                onPressed: () async {
                                  
                                  final confirmed = await showConfirmDialog(context) ?? false;

                                  if(confirmed) {
                                    ref.read(annuncioControllerProvider.notifier)
                                      .deleteAnnuncio(annuncio);
                                  }

                                },
                                text: 'Cancella',
                                background: Color(0xFFFF5722),
                              )
                            )
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
