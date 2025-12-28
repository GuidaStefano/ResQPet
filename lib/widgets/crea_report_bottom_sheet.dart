import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/report_controller.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/password_text_filed.dart';
import 'package:resqpet/widgets/resqpet_button.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class CreaReportBottomSheet extends ConsumerStatefulWidget {
  final String annuncioRef;

  const CreaReportBottomSheet({
    super.key,
    required this.annuncioRef
  });

  @override
  ConsumerState<CreaReportBottomSheet> createState() => _CreaReportBottomSheetState();
}

class _CreaReportBottomSheetState extends ConsumerState<CreaReportBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _motivazioneController = TextEditingController();
  final _descrizioneController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _motivazioneController.dispose();
    _descrizioneController.dispose();
  }

  Future<void> _creaReport() async {
    
    if(_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    ref.read(reportControllerProvider.notifier)
      .creaReport(
        motivazione: _motivazioneController.text.trim(),
        descrizione: _descrizioneController.text.trim(),
        annuncioRef: widget.annuncioRef
      );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ResQPetColors.primaryDark,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(reportControllerProvider, (_, state) {

      if(state is ReportError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is ReportSuccess) {
        showSnackBar(context, "Report effettuato!");
      }

      context.pop();
    });

    final state = ref.watch(reportControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: 50
        ),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              _buildSectionTitle("Segnala Annuncio"),

              const SizedBox(height: 20),

              ResQPetTextField(
                label: 'Motivazione',
                prefixIcon: Icon(Icons.question_mark),
                controller: _motivazioneController,
                validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Campo obbligatorio"
                  : null
              ),

              ResQPetTextField(
                label: 'Descrizione',
                prefixIcon: Icon(Icons.description),
                controller: _descrizioneController,
                validator: (value) => (value == null || value.trim().isEmpty)
                  ? "Campo obbligatorio"
                  : null
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: (state is! ReportLoading) 
                  ? ResQPetButton(
                    text: "Effettua Report",
                    onPressed: _creaReport
                  ) 
                  : const Center(
                    child: CircularProgressIndicator(),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

}
