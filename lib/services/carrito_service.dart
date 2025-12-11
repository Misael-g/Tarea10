import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';
import '../models/carrito_item.dart';
import '../config/supabase_config.dart';

class CarritoException implements Exception {
  final String mensaje;
  CarritoException(this.mensaje);

  @override
  String toString() => mensaje;
}

class CarritoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener el ID del usuario actual (usaremos un ID temporal si no hay autenticación)
  String get _userId {
    final user = _supabase.auth.currentUser;
    return user?.id ?? 'guest_user';
  }

  // Obtener items del carrito desde Supabase
  Future<List<CarritoItem>> obtenerItems() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.carritoTable)
          .select('''
            *,
            productos:producto_id (*)
          ''')
          .eq('user_id', _userId)
          .order('created_at', ascending: false);

      final items = <CarritoItem>[];
      for (var item in response as List) {
        if (item['productos'] != null) {
          final producto = Producto.fromJson(item['productos']);
          items.add(CarritoItem(
            producto: producto,
            cantidad: item['cantidad'] ?? 1,
          ));
        }
      }
      return items;
    } catch (e) {
      throw CarritoException('Error al cargar el carrito: $e');
    }
  }

  // Versión síncrona para compatibilidad (usa caché local)
  List<CarritoItem> obtenerItemsSync() {
    // Esto debería ser manejado por el provider con una caché local
    return [];
  }

  // Agregar producto al carrito
  Future<void> agregarProducto(Producto producto, int cantidad) async {
    if (cantidad < 1) {
      throw CarritoException('La cantidad debe ser al menos 1');
    }

    try {
      // Verificar si el producto ya existe en el carrito
      final existente = await _supabase
          .from(SupabaseConfig.carritoTable)
          .select()
          .eq('user_id', _userId)
          .eq('producto_id', producto.id)
          .maybeSingle();

      if (existente != null) {
        // Actualizar cantidad
        final nuevaCantidad = (existente['cantidad'] ?? 0) + cantidad;
        
        if (nuevaCantidad > producto.stockDisponible) {
          throw CarritoException(
            'Stock insuficiente. Disponible: ${producto.stockDisponible}'
          );
        }

        await _supabase
            .from(SupabaseConfig.carritoTable)
            .update({
              'cantidad': nuevaCantidad,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existente['id']);
      } else {
        // Crear nuevo item
        if (cantidad > producto.stockDisponible) {
          throw CarritoException(
            'Stock insuficiente. Disponible: ${producto.stockDisponible}'
          );
        }

        await _supabase
            .from(SupabaseConfig.carritoTable)
            .insert({
              'user_id': _userId,
              'producto_id': producto.id,
              'cantidad': cantidad,
            });
      }
    } catch (e) {
      if (e is CarritoException) rethrow;
      throw CarritoException('Error al agregar al carrito: $e');
    }
  }

  // Eliminar producto del carrito
  Future<void> eliminarProducto(String productoId) async {
    try {
      await _supabase
          .from(SupabaseConfig.carritoTable)
          .delete()
          .eq('user_id', _userId)
          .eq('producto_id', productoId);
    } catch (e) {
      throw CarritoException('Error al eliminar del carrito: $e');
    }
  }

  // Actualizar cantidad de un producto
  Future<void> actualizarCantidad(String productoId, int nuevaCantidad) async {
    if (nuevaCantidad < 1) {
      throw CarritoException('La cantidad debe ser al menos 1');
    }

    try {
      // Verificar stock disponible
      final producto = await _supabase
          .from(SupabaseConfig.productosTable)
          .select('stock_disponible')
          .eq('id', productoId)
          .single();

      final stockDisponible = producto['stock_disponible'] ?? 0;
      if (nuevaCantidad > stockDisponible) {
        throw CarritoException(
          'Stock insuficiente. Disponible: $stockDisponible'
        );
      }

      await _supabase
          .from(SupabaseConfig.carritoTable)
          .update({
            'cantidad': nuevaCantidad,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', _userId)
          .eq('producto_id', productoId);
    } catch (e) {
      if (e is CarritoException) rethrow;
      throw CarritoException('Error al actualizar cantidad: $e');
    }
  }

  // Vaciar carrito
  Future<void> vaciarCarrito() async {
    try {
      await _supabase
          .from(SupabaseConfig.carritoTable)
          .delete()
          .eq('user_id', _userId);
    } catch (e) {
      throw CarritoException('Error al vaciar el carrito: $e');
    }
  }

  // Calcular subtotal
  double calcularSubtotal(List<CarritoItem> items) {
    return items.fold(0.0, (total, item) => total + item.subtotal);
  }

  // Calcular descuento (10% si el subtotal es mayor a $100)
  double calcularDescuento(List<CarritoItem> items) {
    final subtotal = calcularSubtotal(items);
    return subtotal > 100 ? subtotal * 0.10 : 0.0;
  }

  // Calcular impuestos (12%)
  double calcularImpuestos(List<CarritoItem> items) {
    final subtotal = calcularSubtotal(items);
    return subtotal * 0.12;
  }

  // Calcular total
  double calcularTotal(List<CarritoItem> items) {
    final subtotal = calcularSubtotal(items);
    final descuento = calcularDescuento(items);
    final impuestos = calcularImpuestos(items);
    return subtotal - descuento + impuestos;
  }

  // Obtener cantidad total de items
  int obtenerCantidadTotal(List<CarritoItem> items) {
    return items.fold(0, (total, item) => total + item.cantidad);
  }

  // Verificar si el carrito está vacío
  bool estaVacio(List<CarritoItem> items) {
    return items.isEmpty;
  }

  // Procesar compra (crear orden)
  Future<Map<String, dynamic>> procesarCompra(List<CarritoItem> items) async {
    if (items.isEmpty) {
      throw CarritoException('El carrito está vacío');
    }

    try {
      final total = calcularTotal(items);
      final subtotal = calcularSubtotal(items);
      final descuento = calcularDescuento(items);
      final impuestos = calcularImpuestos(items);

      // Crear orden
      final ordenResponse = await _supabase
          .from(SupabaseConfig.ordenesTable)
          .insert({
            'user_id': _userId,
            'total': total,
            'subtotal': subtotal,
            'descuento': descuento,
            'impuestos': impuestos,
            'estado': 'pendiente',
          })
          .select()
          .single();

      final ordenId = ordenResponse['id'];

      // Crear items de la orden
      for (var item in items) {
        await _supabase
            .from(SupabaseConfig.ordenItemsTable)
            .insert({
              'orden_id': ordenId,
              'producto_id': item.producto.id,
              'cantidad': item.cantidad,
              'precio_unitario': item.producto.precio,
              'subtotal': item.subtotal,
            });

        // Actualizar stock del producto
        final nuevoStock = item.producto.stockDisponible - item.cantidad;
        await _supabase
            .from(SupabaseConfig.productosTable)
            .update({'stock_disponible': nuevoStock})
            .eq('id', item.producto.id);
      }

      // Vaciar carrito después de la compra
      await vaciarCarrito();

      return {
        'orden_id': ordenId,
        'total': total,
        'items_count': items.length,
      };
    } catch (e) {
      throw CarritoException('Error al procesar la compra: $e');
    }
  }
}