import 'package:flutter/material.dart';

class ProyectoExpandible extends StatelessWidget {
  final String titulo;
  final String descripcion;
  final String tecnologias;
  final String detalles;

  const ProyectoExpandible({
    super.key,
    required this.titulo,
    required this.descripcion,
    required this.tecnologias,
    required this.detalles,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          tecnologias,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.folder, color: Colors.blue[700]),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descripcion,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Text(
                  'Detalles técnicos:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detalles,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
