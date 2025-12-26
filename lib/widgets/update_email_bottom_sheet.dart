import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/utente_controller.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/resqpet_button.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class UpdateEmailBottomSheet extends ConsumerStatefulWidget {

  final Utente utente;

  const UpdateEmailBottomSheet({ 
    super.key,
    required this.utente
  });

  @override
  ConsumerState<UpdateEmailBottomSheet> createState() => _UpdateEmailBottomSheetState();
}

class _UpdateEmailBottomSheetState extends ConsumerState<UpdateEmailBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
  }

  Future<void> _updateEmail() async {
    
    if(_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    ref.read(updateAccountControllerProvider.notifier)
      .updateEmail(
        newEmail: _emailController.text.trim(),
        utente: widget.utente
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

    ref.listen(updateAccountControllerProvider, (_, state) {

      if(state is UpdateAccountError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is UpdateAccountSuccess) {
        showSnackBar(context, "Email Aggiornata!");
      }

      context.pop();
    });

    final state = ref.watch(updateAccountControllerProvider);

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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              _buildSectionTitle("Aggiorna Email"),

              const SizedBox(height: 20),

              ResQPetTextField(
                label: 'Email Attuale',
                controller: _emailController,
                validator: (value) => !emailRegex.hasMatch(value ?? '')
                  ? "Email non valida"
                  : null,
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: (state is! UpdateAccountLoading) 
                  ? ResQPetButton(
                    text: "Aggiorna Email",
                    onPressed: _updateEmail
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
