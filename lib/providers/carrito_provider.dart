import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';

class CarritoProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();
  
  List<CarritoItem> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CarritoItem> get items => _items;
  
  int get cantidadTotal => _carritoService.obtenerCantidadTotal(_items);
  bool get estaVacio => _carritoService.estaVacio(_items);
  double get subtotal => _carritoService.calcularSubtotal(_items);
  double get descuento => _carritoService.calcularDescuento(_items);
  double get impuestos => _carritoService.calcularImpuestos(_items);
  double get total => _carritoService.calcularTotal(_items);

  // Cargar items del carrito desde Supabase
  Future<void> cargarCarrito() async {
    _setLoading(true);
    _clearError();

    try {
      _items = await _carritoService.obtenerItems();
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar el carrito: $e');
      _setLoading(false);
    }
  }

  Future<bool> agregarProducto(Producto producto, int cantidad) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.agregarProducto(producto, cantidad);
      await cargarCarrito(); // Recargar items
      _setLoading(false);
      return true;
    } on CarritoException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> eliminarProducto(String productoId) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.eliminarProducto(productoId);
      await cargarCarrito();
      _setLoading(false);
      return true;
    } on CarritoException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> actualizarCantidad(String productoId, int nuevaCantidad) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.actualizarCantidad(productoId, nuevaCantidad);
      await cargarCarrito();
      _setLoading(false);
      return true;
    } on CarritoException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> incrementarCantidad(String productoId) async {
    final item = _items.firstWhere(
      (item) => item.producto.id == productoId,
      orElse: () => throw CarritoException('Producto no encontrado'),
    );
    return await actualizarCantidad(productoId, item.cantidad + 1);
  }

  Future<bool> decrementarCantidad(String productoId) async {
    final item = _items.firstWhere(
      (item) => item.producto.id == productoId,
      orElse: () => throw CarritoException('Producto no encontrado'),
    );
    
    if (item.cantidad <= 1) {
      return await eliminarProducto(productoId);
    }
    
    return await actualizarCantidad(productoId, item.cantidad - 1);
  }

  Future<bool> vaciarCarrito() async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.vaciarCarrito();
      _items = [];
      _setLoading(false);
      notifyListeners();
      return true;
    } on CarritoException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> procesarCompra() async {
    _setLoading(true);
    _clearError();

    try {
      final resultado = await _carritoService.procesarCompra(_items);
      _items = [];
      _setLoading(false);
      notifyListeners();
      return resultado;
    } on CarritoException catch (e) {
      _setError(e.mensaje);
      _setLoading(false);
      return null;
    } catch (e) {
      _setError('Error inesperado: $e');
      _setLoading(false);
      return null;
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