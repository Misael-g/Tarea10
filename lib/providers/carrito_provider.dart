import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';
import '../services/carrito_service.dart';

class CarritoProvider extends ChangeNotifier {
  final CarritoService _carritoService = CarritoService();
  
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CarritoItem> get items => _carritoService.obtenerItemsSync();
  int get cantidadTotal => _carritoService.obtenerCantidadTotal();
  bool get estaVacio => _carritoService.estaVacio();
  double get subtotal => _carritoService.calcularSubtotal();
  double get descuento => _carritoService.calcularDescuento();
  double get impuestos => _carritoService.calcularImpuestos();
  double get total => _carritoService.calcularTotal();

  Future<bool> agregarProducto(Producto producto, int cantidad) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.agregarProducto(producto, cantidad);
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

  Future<bool> eliminarProducto(String productoId) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.eliminarProducto(productoId);
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

  Future<bool> actualizarCantidad(String productoId, int nuevaCantidad) async {
    _setLoading(true);
    _clearError();

    try {
      await _carritoService.actualizarCantidad(productoId, nuevaCantidad);
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

  Future<bool> incrementarCantidad(String productoId) async {
    final item = items.firstWhere(
      (item) => item.producto.id == productoId,
      orElse: () => throw CarritoException('Producto no encontrado'),
    );
    return await actualizarCantidad(productoId, item.cantidad + 1);
  }

  Future<bool> decrementarCantidad(String productoId) async {
    final item = items.firstWhere(
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