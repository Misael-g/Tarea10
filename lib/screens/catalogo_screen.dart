import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/auth_provider.dart';
import '../providers/carrito_provider.dart';
import '../providers/productos_provider.dart';
import '../widgets/producto_card.dart';
import 'login_screen.dart';
import 'carrito_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String? _categoriaSeleccionada;
  List<Producto> _productosFiltrados = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final productosProvider = Provider.of<ProductosProvider>(context, listen: false);
    final carritoProvider = Provider.of<CarritoProvider>(context, listen: false);
    
    await Future.wait([
      productosProvider.cargarProductos(),
      productosProvider.cargarCategorias(),
      carritoProvider.cargarCarrito(),
    ]);
    
    setState(() {
      _isInitialized = true;
      _productosFiltrados = productosProvider.productos;
    });
  }

  void _filtrarProductos() {
    final productosProvider = Provider.of<ProductosProvider>(context, listen: false);
    setState(() {
      if (_categoriaSeleccionada == null) {
        _productosFiltrados = productosProvider.productos;
      } else {
        _productosFiltrados = productosProvider.productos
            .where((p) => p.categoria == _categoriaSeleccionada)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catálogo de Productos'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // Menú de usuario
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) async {
                  if (value == 'logout') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );
                    
                    if (confirm == true && context.mounted) {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName ?? 'Usuario',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          authProvider.userEmail ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 12),
                        Text('Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
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
                        decoration: const BoxDecoration(
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
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ProductosProvider>(
              builder: (context, productosProvider, child) {
                if (productosProvider.isLoading && !_isInitialized) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productosProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          productosProvider.errorMessage!,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _cargarDatos,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    // Filtro de categorías
                    _buildFiltroCategories(productosProvider.categorias),
                    
                    // Lista de productos
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _cargarDatos,
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
                                      'No hay productos disponibles',
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
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildFiltroCategories(List<String> categorias) {
    final categoriasConTodas = ['Todas', ...categorias];

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
        itemCount: categoriasConTodas.length,
        itemBuilder: (context, index) {
          final categoria = categoriasConTodas[index];
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
                  _filtrarProductos();
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