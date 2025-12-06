import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/carrito_item.dart';
import '../providers/carrito_provider.dart';

class CarritoItemWidget extends StatelessWidget {
  final CarritoItem item;

  const CarritoItemWidget({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  item.producto.imagen,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.producto.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.producto.precio.toStringAsFixed(2)} c/u',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[400],
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _eliminarItem(context),
                ),
                const SizedBox(height: 8),
                
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildBotonCantidad(
                        context,
                        Icons.remove,
                        () => _decrementarCantidad(context),
                      ),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '${item.cantidad}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      _buildBotonCantidad(
                        context,
                        Icons.add,
                        () => _incrementarCantidad(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  'Stock: ${item.producto.stockDisponible}',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotonCantidad(BuildContext context, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20),
      ),
    );
  }

  void _incrementarCantidad(BuildContext context) async {
    final carrito = Provider.of<CarritoProvider>(context, listen: false);
    await carrito.incrementarCantidad(item.producto.id);
  }

  void _decrementarCantidad(BuildContext context) async {
    final carrito = Provider.of<CarritoProvider>(context, listen: false);
    await carrito.decrementarCantidad(item.producto.id);
  }

  void _eliminarItem(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar Producto'),
          content: Text('¿Deseas eliminar "${item.producto.titulo}" del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar == true && context.mounted) {
      final carrito = Provider.of<CarritoProvider>(context, listen: false);
      final success = await carrito.eliminarProducto(item.producto.id);
      
      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.producto.titulo} eliminado del carrito'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}