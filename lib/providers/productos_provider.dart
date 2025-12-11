import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../services/productos_service.dart';

class ProductosProvider extends ChangeNotifier {
  final ProductosService _productosService = ProductosService();
  
  List<Producto> _productos = [];
  List<String> _categorias = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Producto> get productos => _productos;
  List<String> get categorias => _categorias;

  // Cargar todos los productos
  Future<void> cargarProductos() async {
    _setLoading(true);
    _clearError();

    try {
      _productos = await _productosService.obtenerProductos();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar productos: $e');
      _setLoading(false);
    }
  }

  // Cargar categorías
  Future<void> cargarCategorias() async {
    try {
      _categorias = await _productosService.obtenerCategorias();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar categorías: $e');
    }
  }

  // Obtener productos por categoría
  Future<List<Producto>> obtenerProductosPorCategoria(String categoria) async {
    try {
      return await _productosService.obtenerProductosPorCategoria(categoria);
    } catch (e) {
      _setError('Error al filtrar por categoría: $e');
      return [];
    }
  }

  // Buscar productos
  Future<List<Producto>> buscarProductos(String termino) async {
    try {
      return await _productosService.buscarProductos(termino);
    } catch (e) {
      _setError('Error al buscar productos: $e');
      return [];
    }
  }

  // Crear producto (admin)
  Future<bool> crearProducto(Producto producto) async {
    _setLoading(true);
    _clearError();

    try {
      await _productosService.crearProducto(producto);
      await cargarProductos();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear producto: $e');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar producto (admin)
  Future<bool> actualizarProducto(Producto producto) async {
    _setLoading(true);
    _clearError();

    try {
      await _productosService.actualizarProducto(producto);
      await cargarProductos();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al actualizar producto: $e');
      _setLoading(false);
      return false;
    }
  }

  // Eliminar producto (admin)
  Future<bool> eliminarProducto(String id) async {
    _setLoading(true);
    _clearError();

    try {
      await _productosService.eliminarProducto(id);
      await cargarProductos();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al eliminar producto: $e');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}