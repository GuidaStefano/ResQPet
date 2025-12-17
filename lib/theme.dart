import 'package:flutter/material.dart';

class ResQPetColors {
  static const Color primaryDark = Color(0xFF633E1E);
  static const Color primaryVariant = Color(0xFF9c7f63);
  static const Color accent = Color(0xFFCD8D34);
  static const Color background = Color(0xFFE5CAB1);
  static const Color onBackground = Color(0xFF49454E);
  static const Color surface = Color(0xFFEAE8E9);
  static const Color white = Color(0xFFFFFFFF);
}

// Definizione del Tema Flutter
final ThemeData resqpetTheme = ThemeData(
  colorScheme: const ColorScheme(
    primary: ResQPetColors.primaryDark,
    secondary: ResQPetColors.accent,
    surface: ResQPetColors.background,
    surfaceContainer: ResQPetColors.background,
    onPrimary: ResQPetColors.white,
    onSecondary: ResQPetColors.white,
    onSurface: ResQPetColors.onBackground,
    onSurfaceVariant: ResQPetColors.onBackground,
    error: Colors.red,
    onError: ResQPetColors.white,
    brightness: Brightness.light,
  ),

  // 3. Aspetto Generale
  scaffoldBackgroundColor: ResQPetColors.background,
  
  // 4. Stile dei Componenti
  appBarTheme: const AppBarTheme(
    backgroundColor: ResQPetColors.primaryDark,
    foregroundColor: ResQPetColors.white, // Colore testo/icone su AppBar
    elevation: 3.0,
    shadowColor: ResQPetColors.onBackground,
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: ResQPetColors.accent,
    foregroundColor: ResQPetColors.white, // Icona scura su bottone chiaro
    elevation: 8.0,
  ),

  cardTheme: const CardThemeData(
    color: ResQPetColors.background,
    elevation: 2.0,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: ResQPetColors.primaryDark
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(12.0)
      ),
    ),
  ),

  buttonTheme: const ButtonThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(8.0)
      ),
    ),
  ),
  
  navigationBarTheme: NavigationBarThemeData(
    elevation: 30,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(
        color: ResQPetColors.white
      )
    ),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(
        color: ResQPetColors.white
      )
    ),
    indicatorColor: ResQPetColors.primaryDark,
    backgroundColor: ResQPetColors.primaryVariant
  ),

  // Stile per i campi di testo
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: ResQPetColors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0)
      ),
      borderSide: BorderSide(
        color: ResQPetColors.primaryDark,
        width: 1.0
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(10.0)
      ),
      borderSide: BorderSide(
        color: ResQPetColors.accent,
        width: 2.0
      ),
    ),
    labelStyle: TextStyle(
      color: ResQPetColors.primaryDark
    ),
  ),
  
  listTileTheme: const ListTileThemeData(
    tileColor: ResQPetColors.background,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: ResQPetColors.primaryDark
      ),
      borderRadius: BorderRadius.all(
        Radius.circular(12.0)
      ),
    ),
  ),
);