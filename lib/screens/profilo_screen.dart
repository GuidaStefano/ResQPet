import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/abbonamento_controller.dart';
import 'package:resqpet/controllers/dati_utente_controller.dart';
import 'package:resqpet/controllers/logout_controller.dart';
import 'package:resqpet/controllers/utente_controller.dart';
import 'package:resqpet/core/utils/functions.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/info_message.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';
import 'package:resqpet/widgets/update_email_bottom_sheet.dart';
import 'package:resqpet/widgets/update_password_bottom_sheet.dart';

class AbbonamentoField extends ConsumerWidget {
  
  const AbbonamentoField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final abbonamentoAsyncValue = ref.watch(abbonamentoProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ResQPetColors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ResQPetColors.primaryDark.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.card_membership, 
              color: ResQPetColors.primaryDark.withValues(alpha: 0.6)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Abbonamento",
                    style: TextStyle(
                      fontSize: 12,
                      color: ResQPetColors.primaryDark.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  abbonamentoAsyncValue.when(
                    data: (abbonamento) => Text(
                      abbonamento.descrizione,
                      style: const TextStyle(
                        fontSize: 16,
                        color: ResQPetColors.onBackground,
                      ),
                    ),
                    loading: () => Text(
                      "Caricamento dati abbonamento",
                      style: const TextStyle(
                        fontSize: 16,
                        color: ResQPetColors.onBackground,
                      ),
                    ),
                    error: (_, _) => Text(
                      "Errore durante il caricamento dell'abbonamento",
                      style: const TextStyle(
                        fontSize: 16,
                        color: ResQPetColors.onBackground,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: ResQPetColors.primaryDark.withValues(alpha: 0.5),
            ),
          ],
        ),
      )
    );
  }
}

class ProfiloScreen extends ConsumerStatefulWidget {
  const ProfiloScreen({ super.key });

  @override
  ConsumerState<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends ConsumerState<ProfiloScreen> {

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nominativoController;
  late TextEditingController _telefonoController;

  // Campi specifici per Venditore ed Ente
  late TextEditingController _partitaIVAController;
  late TextEditingController _indirizzoController;

  @override
  void initState() {
    super.initState();

    _nominativoController = TextEditingController();
    _telefonoController = TextEditingController();
    _indirizzoController = TextEditingController();
    _partitaIVAController = TextEditingController();
  }

  @override
  void dispose() {

    _nominativoController.dispose();
    _telefonoController.dispose();
    _partitaIVAController.dispose();
    _indirizzoController.dispose();

    super.dispose();
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String? value)? validator
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ResQPetTextField(
        label: label,
        prefixIcon: Icon(icon),
        controller: controller,
        textInputType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {

    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ResQPetColors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ResQPetColors.primaryDark.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ResQPetColors.primaryDark.withValues(alpha: 0.6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: ResQPetColors.primaryDark.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: ResQPetColors.onBackground,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null) Icon(
            Icons.chevron_right,
            color: ResQPetColors.primaryDark.withValues(alpha: 0.5),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: onTap != null
        ? InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: content,
          )
        : content,
    );
  }

  List<Widget> _buildCampiEnte() {
    return [
      _buildSectionTitle("Dettagli Ente"),
      _buildTextField(
        controller: _indirizzoController,
        label: "Sede Legale",
        icon: Icons.location_city,
        validator: (value) => (value == null || value.trim().isEmpty) 
          ? "Campo obbligatorio"
          : null
      ),
      _buildTextField(
        controller: _partitaIVAController,
        label: "Partita IVA",
        icon: Icons.business,
        validator: (value) => !partitaIvaRegex.hasMatch(value ?? '')
          ? "Partita IVA non valida"
          : null
      ),
    ];
  }

  List<Widget> _buildCampiVenditore(Venditore utente) {

    return [
      _buildSectionTitle("Dettagli Venditore"),
      _buildTextField(
        controller: _partitaIVAController,
        label: "Partita IVA",
        icon: Icons.business,
        validator: (value) => !partitaIvaRegex.hasMatch(value ?? '')
          ? "Partita IVA non valida"
          : null
      ),
      _buildTextField(
        controller: _indirizzoController,
        label: "Indirizzo",
        icon: Icons.location_on,
        validator: (value) => (value == null || value.trim().isEmpty) 
          ? "Campo obbligatorio"
          : null
      ),
      _buildReadOnlyField(
        label: "Data Sottoscrizione Abbonamento",
        value: formatDate(utente.dataSottoscrizioneAbbonamento.toDate()),
        icon: Icons.calendar_today,
      ),
      GestureDetector(
        child: const AbbonamentoField(),
        onTap: () {
          context.pushNamed(Routes.aggiornaAbbonamento.name);
        },
      )
    ];
  }

  Future<void> _salvaProfilo(Utente utente) async {

    if(_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    Utente copy;

    if(utente is Venditore) {
      Venditore venditore = utente;
      copy = venditore.copyWith(
        nominativo: _nominativoController.text.trim(),
        numeroTelefono: _telefonoController.text.trim(),
        partitaIVA: _partitaIVAController.text.trim(),
        indirizzo: _indirizzoController.text.trim()
      );
    } else if(utente is Ente) {
      Ente ente = utente;
      copy = ente.copyWith(
        nominativo: _nominativoController.text.trim(),
        numeroTelefono: _telefonoController.text.trim(),
        partitaIVA: _partitaIVAController.text.trim(),
        sedeLegale: _indirizzoController.text.trim()
      );
    } else {
      copy = utente.copyWith(
        nominativo: _nominativoController.text.trim(),
        numeroTelefono: _telefonoController.text.trim()
      );
    }

    ref.read(updateAccountControllerProvider.notifier)
      .update(copy);
  }

  Widget body(Utente utente) {

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo pagina
              const Text(
                "Modifica Profilo",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ResQPetColors.primaryDark,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Aggiorna le tue informazioni personali",
                style: TextStyle(
                  fontSize: 14,
                  color: ResQPetColors.onBackground.withValues(alpha: 0.7),
                ),
              ),

              // Sezione dati comuni
              _buildSectionTitle("Informazioni Personali"),
              _buildTextField(
                controller: _nominativoController,
                label: "Nominativo",
                icon: Icons.person,
                validator: (value) => (value == null || value.trim().isEmpty) 
                  ? "Campo obbligatorio"
                  : null
              ),
              _buildTextField(
                controller: _telefonoController,
                label: "Numero di Telefono",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) => !italianPhoneRegex.hasMatch(value ?? '')
                  ? "Numero di telefono non valido"
                  : null,
              ),
              _buildReadOnlyField(
                label: "Email",
                value: utente.email,
                icon: Icons.email,
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: ResQPetColors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => UpdateEmailBottomSheet(utente: utente),
                  );
                }
              ),
              // Campo per modifica password
              _buildReadOnlyField(
                label: "Password",
                value: "••••••••",
                icon: Icons.lock,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: ResQPetColors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => UpdateBottomPasswordSheet(email: utente.email),
                  );
                },
              ),

              // Campo di sola lettura per data creazione
              _buildReadOnlyField(
                label: "Data Creazione Account",
                value: formatDate(utente.dataCreazione.toDate()),
                icon: Icons.calendar_today,
              ),

              // Campi specifici per tipo utente
              if(utente is Ente) ..._buildCampiEnte(),
              if(utente is Venditore) ..._buildCampiVenditore(utente),

              const SizedBox(height: 20),
            ],
          )
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final utenteAsyncValue = ref.watch(datiUtenteProvider);

    ref.listen(updateAccountControllerProvider, (_, state) {

      if(state is UpdateAccountError) {
        showErrorSnackBar(context, state.message);
      }

      if(state is UpdateAccountSuccess) {
        showSnackBar(context, "Dati Aggiornati!");
        context.pop();
        return;
      }

      if(state is UpdateAccountPasswordSuccess) {
        showSnackBar(context, "Password Aggiornata!");
      }

      if(state is UpdateAccountEmailSuccess) {
        showSnackBar(context, "Email Aggiornata!");
      }

    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        title: const Text("Modifica Profilo"),
        actions: [
          IconButton(
            onPressed: () async {
              await ref.read(logoutControllerProvider.notifier)
                .logout();
            }, 
            icon: Icon(Icons.logout_outlined)
          )
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          utenteAsyncValue.when(
            data: (utente) {

              _nominativoController.text = utente.nominativo;
              _telefonoController.text = utente.numeroTelefono;

              if(utente is Ente) {
                _indirizzoController.text = utente.sedeLegale;
                _partitaIVAController.text = utente.partitaIVA;
              }

              if(utente is Venditore) {
                _indirizzoController.text = utente.indirizzo;
                _partitaIVAController.text = utente.partitaIVA;
              }

              return body(utente);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: InfoMessage(
                  message: "Errore durante il caricamento dei dati utente"
                ),
              ),
            )
          )
          
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ResQPetColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: utenteAsyncValue.whenOrNull(
                data: (utente) => () => _salvaProfilo(utente)
              ),
              icon: const Icon(Icons.save),
              label: const Text(
                "Salva Modifiche",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ResQPetColors.accent,
                foregroundColor: ResQPetColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}