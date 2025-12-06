import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

// Run | Debug | Profile
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Quita el banner de "DEBUG" en la esquina
      debugShowCheckedModeBanner: false,

      // Título de la aplicación
      title: 'Mi Portafolio',

      // Tema de colores de la app
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ), // ThemeData

      // Pantalla inicial
      home: const HomeScreen(),
    ); // MaterialApp
  }
}
