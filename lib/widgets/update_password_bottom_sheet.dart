import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/utente_controller.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/password_text_filed.dart';
import 'package:resqpet/widgets/resqpet_button.dart';

class UpdateBottomPasswordSheet extends ConsumerStatefulWidget {
  final String email;

  const UpdateBottomPasswordSheet({
    super.key,
    required this.email
  });

  @override
  ConsumerState<UpdateBottomPasswordSheet> createState() => _UpdateBottomPasswordSheetState();
}

class _UpdateBottomPasswordSheetState extends ConsumerState<UpdateBottomPasswordSheet> {
  final _formKey = GlobalKey<FormState>();

  final _currentController = TextEditingController();
  final _newController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _currentController.dispose();
    _newController.dispose();
  }

  Future<void> _updatePassword() async {
    
    if(_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    ref.read(updateAccountControllerProvider.notifier)
      .updatePassword(
        email: widget.email, 
        currentPassword: _currentController.text.trim(), 
        newPassword: _newController.text.trim()
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

              _buildSectionTitle("Aggiorna Password"),

              const SizedBox(height: 20),

              PasswordTextField(
                label: 'Password Attuale',
                controller: _currentController,
                validator: (value) => !min8PasswordRegex.hasMatch(value ?? '')
                  ? "La password deve avere almeno 8 caratteri"
                  : null,
              ),

              PasswordTextField(
                label: 'Nuova Password',
                controller: _newController,
                validator: (value) => !min8PasswordRegex.hasMatch(value ?? '')
                  ? "La nuova password deve avere almeno 8 caratteri"
                  : null,
              ),

              PasswordTextField(
                label: 'Conferma Password',
                validator: (value) { 
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo richiesto.';
                  }

                  if(value != _newController.text) {
                    return "Le password non corrispondono.";
                  }

                  return null;
                }
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: (state is! UpdateAccountLoading) 
                  ? ResQPetButton(
                    text: "Aggiorna Password",
                    onPressed: _updatePassword
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
