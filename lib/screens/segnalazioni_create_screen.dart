import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/segnalazioni_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/info_message.dart';
import 'package:resqpet/widgets/segnalazione_card.dart';

class SegnalazioniCreateScreen extends ConsumerWidget {

  const SegnalazioniCreateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final segnalazioniAsyncValue = ref.watch(segnalazioneCreateProvider);

    ref.listen(segnalazioneControllerProvider, (_, state) {
      if(state is SegnalazioneError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is SegnalazioneSuccess) {
        showSnackBar(context, "L'operazione ha avuto successo!");
      }
    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ResQPetColors.primaryDark),
        title: Text(
          "Le tue Segnalazioni",
          style: const TextStyle(
            color: ResQPetColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            segnalazioniAsyncValue.when(
              error: (error, _) => const InfoMessage(message: "Si e' verificato un errore"),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: ResQPetColors.accent,
                  ),
                ),
              ),
              data: (segnalazioni) {

                if (segnalazioni.isEmpty) {
                  return const InfoMessage(message: "Nessuna segnalazione trovata.");
                }

                return ListView.separated(
                  shrinkWrap: true,
                  separatorBuilder: (_, _) => SizedBox(height: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: segnalazioni.length,
                  itemBuilder: (context, index) {
                    final segnalazione = segnalazioni[index];
                    return SegnalazioneCard(
                      segnalazione: segnalazione,
                      actions: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.pushNamed(
                                Routes.segnalazione.name, 
                                extra: {
                                  'segnalazione': segnalazione,
                                  'isEnte': false,
                                  'isCittadino': true
                                }
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: ResQPetColors.primaryDark,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              "Dettagli",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        )
                      ]
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
}