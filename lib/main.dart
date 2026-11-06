import 'package:flutter/material.dart';

import 'screens/inicio_screen.dart';

void main() {
  // Punto de entrada de la aplicación.
  runApp(const CuentaClaraApp());
}

class CuentaClaraApp extends StatelessWidget {
  const CuentaClaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuentaClara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF12715D)),
        useMaterial3: true,
      ),
      home: const InicioScreen(),
    );
  }
}
