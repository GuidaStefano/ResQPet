import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/abbonamento_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/screens/scegli_abbonamento_screen.dart';
import 'package:resqpet/theme.dart';

class AggiornaAbbonamentoScreen extends ConsumerStatefulWidget {
  
  const AggiornaAbbonamentoScreen({super.key});
  
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AggiornaAbbonamentoScreenState();
}

class _AggiornaAbbonamentoScreenState extends ConsumerState<AggiornaAbbonamentoScreen>{

  Abbonamento? _selectedAbbonamento;

  @override
  Widget build(BuildContext context) {

    ref.listen(attivaAbbonamentoControllerProvider, (_, state) {
      if(state is AbbonamentoError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is AbbonamentoSuccess) {
        showSnackBar(context, "Abbonamento Aggiornato!");
        context.pop();
      }
    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        title: const Text('Aggiorna Abbonamento'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: ScegliAbbonamentoScreen(
          onTap: (abbonamento, index) {
            setState(() {
              _selectedAbbonamento = abbonamento;
            });

            showSnackBar(context, "Abbonamento Selezionato!");
          },
        )
      ),
      floatingActionButton: _selectedAbbonamento != null
        ? FloatingActionButton.extended(
            onPressed: () {
              ref.read(attivaAbbonamentoControllerProvider.notifier)
                .attivaAbbonamento(_selectedAbbonamento!);
            },
            backgroundColor: ResQPetColors.accent,
            icon: const Icon(
              Icons.check_circle_outline_outlined,
              color: ResQPetColors.white,
            ),
            label: const Text(
              'Attiva Abbonamento',
              style: TextStyle(
                color: ResQPetColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : null,
    );
  }
}