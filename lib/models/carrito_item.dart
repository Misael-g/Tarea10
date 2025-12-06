import 'producto.dart';

class CarritoItem {
  final Producto producto;
  final int cantidad;

  CarritoItem({
    required this.producto,
    required this.cantidad,
  });

  double get subtotal => producto.precio * cantidad;

  CarritoItem copyWith({
    Producto? producto,
    int? cantidad,
  }) {
    return CarritoItem(
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'producto': producto.toMap(),
      'cantidad': cantidad,
    };
  }

  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      producto: Producto.fromMap(map['producto']),
      cantidad: map['cantidad'] ?? 1,
    );
  }
}