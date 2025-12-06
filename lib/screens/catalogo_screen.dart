import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/productos_mock.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../widgets/producto_card.dart';
import 'carrito_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String? _categoriaSeleccionada;
  final List<Producto> _productos = ProductosMock.obtenerProductos();

  List<Producto> get _productosFiltrados {
    if (_categoriaSeleccionada == null) {
      return _productos;
    }
    return _productos
        .where((p) => p.categoria == _categoriaSeleccionada)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Botón del carrito con badge
          Consumer<CarritoProvider>(
            builder: (context, carrito, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CarritoScreen(),
                        ),
                      );
                    },
                  ),
                  if (carrito.cantidadTotal > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${carrito.cantidadTotal}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filtro de categorías
          _buildFiltroCategories(),
          
          // Lista de productos
          Expanded(
            child: _productosFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay productos en esta categoría',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _productosFiltrados.length,
                    itemBuilder: (context, index) {
                      return ProductoCard(
                        producto: _productosFiltrados[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltroCategories() {
    final categorias = ['Todas', ...ProductosMock.obtenerCategorias()];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final categoria = categorias[index];
          final isSeleccionada = (categoria == 'Todas' && _categoriaSeleccionada == null) ||
              categoria == _categoriaSeleccionada;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categoria),
              selected: isSeleccionada,
              onSelected: (selected) {
                setState(() {
                  _categoriaSeleccionada = categoria == 'Todas' ? null : categoria;
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              labelStyle: TextStyle(
                color: isSeleccionada ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSeleccionada ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}