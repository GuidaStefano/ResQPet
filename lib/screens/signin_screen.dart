import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/controllers/signin_controller.dart';
import 'package:resqpet/core/utils/regex.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'package:resqpet/widgets/password_text_filed.dart';
import 'package:resqpet/widgets/resqpet_button.dart';
import 'package:resqpet/widgets/resqpet_text_field.dart';

class SignInScreen extends ConsumerStatefulWidget {
  
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {

  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final state = ref.watch(signInControllerProvider);

    return Scaffold(
      backgroundColor: ResQPetColors.surface,
      body: Expanded(
        child: Padding(
          padding: EdgeInsets.all(25),
          child: Column(
            spacing: 40,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 70,
                child: Image.asset("assets/logo-con-scritta.png"),
              ),
              SizedBox(height: 30,),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ResQPetTextField(
                      controller: _emailController,
                      prefixIcon: Icon(Icons.email_outlined),
                      textInputType: TextInputType.emailAddress,
                      label: 'Email',
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
                  ],
                )
              ),
              ResQPetButton(
                text: "Effettua Login",
                onPressed: () async {
                  if(_formKey.currentState == null || !_formKey.currentState!.validate()) {
                    return;
                  }

                  await ref.read(signInControllerProvider.notifier)
                    .signIn(
                      _emailController.text.trim(),
                      _passwordController.text.trim()
                    );
                }
              ),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: "Non sei registrato? "),
                    TextSpan(
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: ResQPetColors.accent
                      ),
                      text: "Registati",
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => context.pushNamed(Routes.signUp.name)
                    )
                  ]
                )
              ),
              switch(state) {
                SignInError(:final error) => Text(error),
                SignInLoading() => const CircularProgressIndicator(),
                _ => const SizedBox()
              }
            ],
          )
        ),
      ),
    );
  }
}