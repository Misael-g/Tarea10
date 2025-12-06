import 'dart:math';
import '../models/producto.dart';
import '../models/carrito_item.dart';

class CarritoException implements Exception {
  final String mensaje;
  CarritoException(this.mensaje);

  @override
  String toString() => mensaje;
}

class CarritoService {
  final List<CarritoItem> _items = [];
  static const double _probabilidadError = 0.2;
  static const List<String> _mensajesError = [
    'Stock insuficiente',
    'Error de conexión',
    'Producto no disponible',
    'Sesión expirada',
  ];

  Future<void> _simularDelay() async {
    final random = Random();
    final delay = 1000 + random.nextInt(1000);
    await Future.delayed(Duration(milliseconds: delay));
  }

  void _verificarErrorAleatorio() {
    final random = Random();
    if (random.nextDouble() < _probabilidadError) {
      final mensajeAleatorio = _mensajesError[random.nextInt(_mensajesError.length)];
      throw CarritoException(mensajeAleatorio);
    }
  }

  Future<void> agregarProducto(Producto producto, int cantidad) async {
    await _simularDelay();
    _verificarErrorAleatorio();

    if (cantidad < 1) {
      throw CarritoException('La cantidad debe ser al menos 1');
    }

    final itemExistente = _items.firstWhere(
      (item) => item.producto.id == producto.id,
      orElse: () => CarritoItem(producto: producto, cantidad: 0),
    );

    final cantidadTotal = itemExistente.cantidad + cantidad;
    
    if (cantidadTotal > producto.stockDisponible) {
      throw CarritoException(
        'Stock insuficiente. Disponible: ${producto.stockDisponible}'
      );
    }

    final index = _items.indexWhere(
      (item) => item.producto.id == producto.id,
    );

    if (index != -1) {
      _items[index] = _items[index].copyWith(
        cantidad: _items[index].cantidad + cantidad,
      );
    } else {
      _items.add(CarritoItem(producto: producto, cantidad: cantidad));
    }
  }

  Future<void> eliminarProducto(String productoId) async {
    await _simularDelay();
    _verificarErrorAleatorio();
    _items.removeWhere((item) => item.producto.id == productoId);
  }

  Future<void> actualizarCantidad(String productoId, int nuevaCantidad) async {
    await _simularDelay();
    _verificarErrorAleatorio();

    if (nuevaCantidad < 1) {
      throw CarritoException('La cantidad debe ser al menos 1');
    }

    final index = _items.indexWhere(
      (item) => item.producto.id == productoId,
    );

    if (index == -1) {
      throw CarritoException('Producto no encontrado en el carrito');
    }

    if (nuevaCantidad > _items[index].producto.stockDisponible) {
      throw CarritoException(
        'Stock insuficiente. Disponible: ${_items[index].producto.stockDisponible}'
      );
    }

    _items[index] = _items[index].copyWith(cantidad: nuevaCantidad);
  }

  Future<List<CarritoItem>> obtenerItems() async {
    await _simularDelay();
    return List.unmodifiable(_items);
  }

  List<CarritoItem> obtenerItemsSync() {
    return List.unmodifiable(_items);
  }

  Future<void> vaciarCarrito() async {
    await _simularDelay();
    _verificarErrorAleatorio();
    _items.clear();
  }

  double calcularSubtotal() {
    return _items.fold(0.0, (total, item) => total + item.subtotal);
  }

  double calcularDescuento() {
    final subtotal = calcularSubtotal();
    return subtotal > 100 ? subtotal * 0.10 : 0.0;
  }

  double calcularImpuestos() {
    final subtotal = calcularSubtotal();
    return subtotal * 0.12;
  }

  double calcularTotal() {
    final subtotal = calcularSubtotal();
    final descuento = calcularDescuento();
    final impuestos = calcularImpuestos();
    return subtotal - descuento + impuestos;
  }

  int obtenerCantidadTotal() {
    return _items.fold(0, (total, item) => total + item.cantidad);
  }

  bool estaVacio() {
    return _items.isEmpty;
  }

  Map<String, double> obtenerResumenTotales() {
    return {
      'subtotal': calcularSubtotal(),
      'descuento': calcularDescuento(),
      'impuestos': calcularImpuestos(),
      'total': calcularTotal(),
    };
  }
}