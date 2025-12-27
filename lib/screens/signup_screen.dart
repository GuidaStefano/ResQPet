import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/signup_controller.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/core/utils/snackbar.dart';
import 'package:resqpet/core/utils/theme.dart';
import 'package:resqpet/models/abbonamento.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/screens/scegli_abbonamento_screen.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/password_text_filed.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {

  // internal state
  int _currentPage = 0;
  TipoUtente selectedAccount = TipoUtente.cittadino;
  Abbonamento? selectedSubscription;

  int get _totalSteps => selectedAccount == TipoUtente.venditore ? 3 : 1;
  
  // widget controllers
  final PageController _pageController = PageController();
  final _formTextControllers = {
    'nominativo': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'numeroTelefono': TextEditingController(),
    'partitaIVA': TextEditingController(),
    'indirizzo': TextEditingController()
  };

  // form keys
  final GlobalKey<FormState> _commonAccountInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _vendorInfoFormKey = GlobalKey<FormState>();

  final allowedAccountType = TipoUtente.values
    .where((t) => t != TipoUtente.admin && t != TipoUtente.ente)
    .map((t) => 
      DropdownMenuEntry<TipoUtente>(
        value: t, label: t.value
      )
    )
    .toList();

  void _goToNextStep() {

    GlobalKey<FormState>? currentFormKey = switch(_currentPage) {
      0 => _commonAccountInfoFormKey,
      1 => selectedAccount == TipoUtente.venditore ? _vendorInfoFormKey : null,
      _ => null
    };

    if (currentFormKey != null && !currentFormKey.currentState!.validate()) {
      return;
    }

    if (_currentPage == 2 && selectedSubscription == null) {
      showErrorSnackBar(context, 'Seleziona un abbonamento per continuare.');
      return;
    }

    if (_currentPage < _totalSteps - 1) {
      setState(() {
        _currentPage++;
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    } else {
      _confirmSignUp();
    }
  }

  void _goToPreviousStep() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSubscriptionSelection(Abbonamento subscription, int index) {
    setState(() {
      selectedSubscription = subscription;
    });

    showSnackBar(context, 'Abbonamento selezionato!');
  }

  void _confirmSignUp() {

    

    final Map<String, dynamic> dataToUpload = {
      'nominativo': _formTextControllers['nominativo']!.text.trim(),
      'email': _formTextControllers['email']!.text.trim(),
      'password': _formTextControllers['password']!.text.trim(),
      'numeroTelefono': _formTextControllers['numeroTelefono']!.text.trim()
    };

    if (selectedAccount == TipoUtente.venditore) {

      dataToUpload.addAll({
        'partitaIVA': _formTextControllers['partitaIVA']!.text,
        'indirizzo': _formTextControllers['indirizzo']!.text,
        'abbonamentoRef': selectedSubscription!.id,
        'prezzoAbbonamento': selectedSubscription!.prezzo,
      });
    }

    ref.read(signUpControllerProvider.notifier)
      .registraUtente(selectedAccount, dataToUpload);
  }

  List<Widget> _getSteps() {

    final List<Widget> steps = [_commonAccountInfo()];

    if (selectedAccount == TipoUtente.venditore) {
      steps.add(_sellerSpecificInfo());
      steps.add(
        ScegliAbbonamentoScreen(
          onTap: _handleSubscriptionSelection,
        )
      );
    }
    
    return steps;
  }

  @override
  void dispose() {
    _pageController.dispose();

    for(final controller in _formTextControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final int currentTotalSteps = _totalSteps; 
    
    final state = ref.watch(signUpControllerProvider);

    ref.listen(signUpControllerProvider, (_, state) {
      if(state is SignUpError) {
        showErrorSnackBar(context, state.error);
        _pageController.jumpToPage(0);
        return;
      }

      if(state is SignUpSuccess) {
        context.goNamed(Routes.signIn.name);
      }
    });

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      appBar: AppBar(
        title: const Text('Registrati'),
        leading: _currentPage > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goToPreviousStep,
            )
          : null,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0, 
              vertical: 16.0
            ),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / currentTotalSteps,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: _getSteps(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToNextStep,
        label: (state is SignUpLoading) 
          ? const CircularProgressIndicator()
          : Text(_currentPage == currentTotalSteps - 1 ? 'Registrati' : 'Avanti'),
        icon: Icon(
          (_currentPage == currentTotalSteps - 1)
            ? Icons.check
            : Icons.arrow_forward
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _commonAccountInfo() {

    final theme = themeOf(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _commonAccountInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 1 di $_totalSteps: Dettagli Account',
              style: theme.textTheme.titleLarge,
            ),
            const Divider(height: 32),
            DropdownMenu<TipoUtente>(
              expandedInsets: EdgeInsets.zero,
              initialSelection: TipoUtente.cittadino,
              requestFocusOnTap: true,
              label: const Text('Tipo Account'),
              onSelected: (TipoUtente? type) {
                setState(() {
                  selectedAccount = type ?? TipoUtente.cittadino;

                  if (_currentPage != 0) {
                    _currentPage = 0;
                    _pageController.jumpToPage(0);
                  }
                });
              },
              dropdownMenuEntries: allowedAccountType,
            ),
            const SizedBox(height: 20),
            ResQPetTextField(
              controller: _formTextControllers['nominativo'],
              label: 'Nominativo',
              prefixIcon: Icon(Icons.account_box_outlined),
              validator: (value) =>
                (value == null || value.trim().isEmpty) 
                  ? 'Campo richiesto.' 
                  : null,
            ),
            const SizedBox(height: 20),
            ResQPetTextField(
              controller: _formTextControllers['numeroTelefono'],
              textInputType: TextInputType.phone,
              label: 'Numero Telefono',
              prefixIcon: Icon(Icons.phone_outlined),
              validator: (value) => !italianPhoneRegex.hasMatch(value ?? '') 
                ? 'Inserire un numero di telefono valido.' 
                : null,
            ),
            const SizedBox(height: 20),
            ResQPetTextField(
              controller: _formTextControllers['email'],
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
              controller: _formTextControllers['password'],
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

                if(value != _formTextControllers['password']!.text) {
                  return "Le password non corrispondono.";
                }

                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Form specifico per il venditore
  Widget _sellerSpecificInfo() {

    final theme = themeOf(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _vendorInfoFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Step 2 di 3: Dettagli Venditore',
              style: theme.textTheme.titleLarge,
            ),
            const Divider(height: 32),
            ResQPetTextField(
              controller: _formTextControllers['partitaIVA'],
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
              controller: _formTextControllers['indirizzo'],
              textInputType: TextInputType.streetAddress,
              label: 'Indirizzo Sede',
              prefixIcon: Icon(Icons.location_on_outlined),
              validator: (value) => 
                (value == null || value.trim().isEmpty)
                  ? 'Campo richiesto.'
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}