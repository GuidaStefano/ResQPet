import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/signup_controller.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/password_text_filed.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class CreaEnteScreen extends ConsumerStatefulWidget {

  const CreaEnteScreen({super.key});

  @override
  ConsumerState<CreaEnteScreen> createState() => _CreaEnteScreenState();
}

class _CreaEnteScreenState extends ConsumerState<CreaEnteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nominativoController = TextEditingController();
  final _numeroTelefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _sedeLegaleController = TextEditingController();
  final _partitaIVAController = TextEditingController();


  @override
  void dispose() {
    super.dispose();

    _nominativoController.dispose();
    _numeroTelefonoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _sedeLegaleController.dispose();
    _partitaIVAController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ref.listen(signUpControllerProvider, (_, state) {
      if(state is SignUpError) {
        showErrorSnackBar(context, state.error);
        return;
      }

      if(state is SignUpSuccess) {
        showSnackBar(context, "Ente registrato con successo!");
        context.pop();
        return;
      }
    });    
    
    final state = ref.watch(signUpControllerProvider);

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: ResQPetColors.primaryDark),
        title: Text(
          "Registra Ente",
          style: const TextStyle(
            color: ResQPetColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Informazioni Ente',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ResQPetColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              ResQPetTextField(
                controller: _nominativoController,
                label: 'Nominativo',
                prefixIcon: Icon(Icons.account_box_outlined),
                validator: (value) =>
                  (value == null || value.trim().isEmpty) 
                    ? 'Campo richiesto.' 
                    : null,
              ),
              const SizedBox(height: 20),
              ResQPetTextField(
                controller: _numeroTelefonoController,
                textInputType: TextInputType.phone,
                label: 'Numero Telefono',
                prefixIcon: Icon(Icons.phone_outlined),
                validator: (value) => !italianPhoneRegex.hasMatch(value ?? '') 
                  ? 'Inserire un numero di telefono valido.' 
                  : null,
              ),
              const SizedBox(height: 20),
              ResQPetTextField(
                controller: _emailController,
                textInputType: TextInputType.emailAddress,
                label: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                validator: (value) => 
                  (value == null || !emailRegex.hasMatch(value)) 
                    ? 'Inserire un email valida.' 
                    : null,
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                controller: _passwordController,
                validator: (value) => 
                  (value == null || !min8PasswordRegex.hasMatch(value))
                    ? 'La password deve avere almeno 8 caratteri.' 
                    : null,
              ),
              const SizedBox(height: 20),
              PasswordTextField(
                label: 'Conferma Password',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo richiesto.';
                  }

                  if(value != _passwordController.text) {
                    return "Le password non corrispondono.";
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),
              ResQPetTextField(
                controller: _partitaIVAController,
                textInputType: TextInputType.text,
                label: 'Partita IVA',
                prefixIcon: Icon(Icons.badge_outlined),
                validator: (value) => 
                  !partitaIvaRegex.hasMatch(value ?? '')
                    ? 'Partita IVA non valida.' 
                    : null,
              ),
              const SizedBox(height: 20),
              ResQPetTextField(
                controller: _sedeLegaleController,
                textInputType: TextInputType.streetAddress,
                label: 'Sede Legale',
                prefixIcon: Icon(Icons.location_on_outlined),
                validator: (value) => 
                  (value == null || value.trim().isEmpty)
                    ? 'Campo richiesto.'
                    : null,
              ),
              const SizedBox(height: 24),
              // Pulsante Submit
              SizedBox(
                width: double.infinity,
                height: 50,
                child: (state is! SignUpLoading) ? ElevatedButton.icon(
                  onPressed: _submit,
                  icon: Icon(Icons.send),
                  label: Text(
                    'Registra',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ResQPetColors.accent,
                    foregroundColor: ResQPetColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ) : const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final dati = {
      'nominativo': _nominativoController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'numeroTelefono': _numeroTelefonoController.text.trim(),
      'partitaIVA': _partitaIVAController.text.trim(),
      'sedeLegale': _sedeLegaleController.text.trim()
    };

    ref.read(signUpControllerProvider.notifier)
      .registraUtente(TipoUtente.ente, dati);
  }
}