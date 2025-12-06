import 'package:flutter/material.dart';
import '../widgets/proyecto_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Portafolio'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      // Usar ListView para scroll
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Mis Proyectos',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Proyecto 1
          const ProyectoCard(
            titulo: 'Sistema de Biblioteca',
            descripcion: 'Aplicación web para gestionar préstamos de libros y registro de usuarios.',
            tecnologias: 'Flutter • Firebase',
            estado: 'Completado',
          ),
          
          // Proyecto 2
          const ProyectoCard(
            titulo: 'App de Tareas',
            descripcion: 'Aplicación móvil para gestionar tareas diarias con recordatorios.',
            tecnologias: 'Flutter • SQLite',
            estado: 'En desarrollo',
          ),
          
          // Proyecto 3
          const ProyectoCard(
            titulo: 'E-commerce',
            descripcion: 'Tienda virtual con carrito de compras y pasarela de pagos.',
            tecnologias: 'React • Node.js • MongoDB',
            estado: 'En pausa',
          ),
        ],
      ),
    );
  }
}
