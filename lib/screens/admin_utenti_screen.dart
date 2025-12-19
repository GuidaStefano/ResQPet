import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resqpet/controllers/utente_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/theme.dart';

class AdminUtentiScreen extends ConsumerWidget {

  const AdminUtentiScreen({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final utentiAsyncValue = ref.watch(utentiProvider);

    ref.listen(deleteAccountControllerProvider, (_, state) {
      if(state is DeleteAccountError) {
        showErrorSnackBar(context, state.message);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utenti'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: utentiAsyncValue.when(
          data: (utenti) {

            if(utenti.isEmpty) {
              return const Center(
                child: Text("Non sono presenti utenti in piattaforma"),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              itemCount: utenti.length,
              itemBuilder: (context, index) {

                final utente = utenti[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(5),
                          leading: CircleAvatar(
                            backgroundColor: ResQPetColors.primaryVariant,
                            child: Text(
                              utente.nominativo[0],
                              style: const TextStyle(
                                color: ResQPetColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            utente.nominativo,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(utente.email),
                              Text(utente.numeroTelefono),
                              const SizedBox(height: 6),
                              Text(
                                utente.tipo.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color:ResQPetColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.delete),
                            label: const Text('Elimina'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: () {
                              ref.read(deleteAccountControllerProvider.notifier)
                                .deleteAccount(utente);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                );
              }
            );
          }, 
          error: (error, _) => Center(
            child: Text(error.toString()),
          ), 
          loading: () => const Center(
            child: CircularProgressIndicator(),
          )
        ),
      )
    );
  }
}