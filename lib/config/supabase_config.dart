import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Leer variables de entorno
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  
  // Nombres de las tablas
  static const String productosTable = 'productos';
  static const String carritoTable = 'carrito';
  static const String ordenesTable = 'ordenes';
  static const String ordenItemsTable = 'orden_items';
  
  // Configuración adicional
  static const Duration timeoutDuration = Duration(seconds: 30);
}