import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/widgets/annuncio_card.dart';

class BachecaAnnunciScreen extends ConsumerWidget {

  const BachecaAnnunciScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final stato = ref.watch(annunciProvider());

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
            Text(
              "Annunci",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800
              ),
            ),
            TextField(
              enableSuggestions: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.filter_alt_outlined),
                suffixIcon: Icon(Icons.search),
                hintText: 'Cerca ...',
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(30)
                ),
              ),
            ),
            
            stato.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: CircularProgressIndicator(),
                ),
              ),
              
              error: (error, stackTrace) => Center(
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
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: annunci.length,
                  itemBuilder: (context, index) {

                    final annuncio = annunci[index];
                    return AnnuncioCard(annuncio: annuncio, onViewDetailsClick: () {
                      //TODO visualizza dettagli
                    });
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
