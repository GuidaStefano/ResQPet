import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/annuncio_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/annuncio_adozione.dart';
import 'package:resqpet/models/annuncio/annuncio_vendita.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';

class AdminAnnunciScreen extends ConsumerWidget {

  const AdminAnnunciScreen({ super.key });

  Widget annunciListView(
    List<Annuncio> annunci,
    { required void Function(Annuncio) onDelete }
  ) {

    if(annunci.isEmpty) {
      return const Center(
        child: Text("Non sono presenti annunci per questa categoria"),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: annunci.length,
      itemBuilder: (context, index) {

        final annuncio = annunci[index];

        return AdminAnnuncioCard(
          annuncio: annuncio,
          onDelete: onDelete,
        );
      }
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final annunciVenditaAsyncValue = ref.watch(annunciProvider(tipo: TipoAnnuncio.vendita));
    final annunciAdozioneAsyncValue = ref.watch(annunciProvider(tipo: TipoAnnuncio.adozione));

    ref.listen(annuncioControllerProvider, (_, state) {
      if(state is AnnuncioError) {
        showErrorSnackBar(context, state.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gestione Annunci"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vendita",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            annunciVenditaAsyncValue.when(
              data: (annunci) => annunciListView(
                annunci, 
                onDelete: (annuncio) {
                  ref.read(annuncioControllerProvider.notifier)
                    .deleteAnnuncio(annuncio);
                }
              ), 
              error: (error, _) => Center(
                child: Text(error.toString()),
              ), 
              loading: () => const Center(
                child: CircularProgressIndicator(),
              )
            ),
            const SizedBox(height: 20),
            const Text(
              "Adozioni",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            annunciAdozioneAsyncValue.when(
              data: (annunci) => annunciListView(
                annunci, 
                onDelete: (annuncio) {
                  ref.read(annuncioControllerProvider.notifier)
                    .deleteAnnuncio(annuncio);
                }
              ), 
              error: (error, _) => Center(
                child: Text(error.toString()),
              ), 
              loading: () => const Center(
                child: CircularProgressIndicator(),
              )
            )
          ],
        ),
      ),
    );
  }
}

class AdminAnnuncioCard extends StatelessWidget {
  final Annuncio annuncio;
  final void Function(Annuncio annuncio)? onDelete;

  const AdminAnnuncioCard({
    super.key,
    required this.annuncio,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annuncio.nome,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text("${annuncio.specie} - ${annuncio.razza}"),
            const SizedBox(height: 4),
            Text("Stato: ${annuncio.statoAnnuncio.value}"),
            const SizedBox(height: 8),
            if (annuncio is AnnuncioVendita)
              Text("Prezzo: ${(annuncio as AnnuncioVendita).prezzo} €"),
            if (annuncio is AnnuncioAdozione)
              Text("Carattere: ${(annuncio as AnnuncioAdozione).carattere}"),
            const SizedBox(height: 8),
            SizedBox(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text("Elimina"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  if(onDelete != null) {
                    onDelete!(annuncio);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}