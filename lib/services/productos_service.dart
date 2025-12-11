import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/producto.dart';
import '../config/supabase_config.dart';

class ProductosService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener todos los productos
  Future<List<Producto>> obtenerProductos() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos: $e');
    }
  }

  // Obtener producto por ID
  Future<Producto?> obtenerProductoPorId(String id) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .select()
          .eq('id', id)
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Obtener productos por categoría
  Future<List<Producto>> obtenerProductosPorCategoria(String categoria) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .select()
          .eq('categoria', categoria)
          .order('titulo', ascending: true);

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener productos por categoría: $e');
    }
  }

  // Obtener todas las categorías únicas
  Future<List<String>> obtenerCategorias() async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .select('categoria')
          .order('categoria', ascending: true);

      final categorias = (response as List)
          .map((item) => item['categoria'] as String)
          .toSet()
          .toList();

      return categorias;
    } catch (e) {
      throw Exception('Error al obtener categorías: $e');
    }
  }

  // Crear nuevo producto
  Future<Producto> crearProducto(Producto producto) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .insert(producto.toInsertJson())
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw Exception('Error al crear producto: $e');
    }
  }

  // Actualizar producto
  Future<Producto> actualizarProducto(Producto producto) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .update(producto.toJson())
          .eq('id', producto.id)
          .select()
          .single();

      return Producto.fromJson(response);
    } catch (e) {
      throw Exception('Error al actualizar producto: $e');
    }
  }

  // Eliminar producto
  Future<void> eliminarProducto(String id) async {
    try {
      await _supabase
          .from(SupabaseConfig.productosTable)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al eliminar producto: $e');
    }
  }

  // Actualizar stock del producto
  Future<void> actualizarStock(String productoId, int nuevoStock) async {
    try {
      await _supabase
          .from(SupabaseConfig.productosTable)
          .update({
            'stock_disponible': nuevoStock,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', productoId);
    } catch (e) {
      throw Exception('Error al actualizar stock: $e');
    }
  }

  // Buscar productos por término
  Future<List<Producto>> buscarProductos(String termino) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.productosTable)
          .select()
          .or('titulo.ilike.%$termino%,descripcion.ilike.%$termino%')
          .order('titulo', ascending: true);

      return (response as List)
          .map((json) => Producto.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar productos: $e');
    }
  }
}