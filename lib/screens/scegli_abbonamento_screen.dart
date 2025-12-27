import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/abbonamento_controller.dart';
import 'package:resqpet/core/utils/theme.dart';
import 'package:resqpet/models/abbonamento.dart';

class ScegliAbbonamentoScreen extends ConsumerWidget {

  final void Function(Abbonamento, int) onTap;

  const ScegliAbbonamentoScreen({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final theme = themeOf(context);

    final abbonamentiAsyncValue = ref.watch(abbonamentiProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Scegli l'Abbonamento:", 
            style: theme.textTheme.titleLarge
          ),
          const Divider(height: 12),
          Expanded(
            child: abbonamentiAsyncValue.when(
              data: (abbonamenti) {
                return ListView.builder(
                  itemCount: abbonamenti.length,
                  itemBuilder: (context, index){
                    final abbonamento = abbonamenti[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(abbonamento.descrizione, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("Prezzo: ${abbonamento.prezzo}"),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => onTap(abbonamento, index),
                      ),
                    );
                  }
                );
              }, 
              error: (error, _) {
                return Center(
                  child: Text('Errore nel caricamento: ${error.toString()}')
                );
              }, 
              loading: () => const Center(
                child: CircularProgressIndicator()
              )
            )
          ),
        ]
      ),
    );
  }
}
