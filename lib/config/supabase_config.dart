class SupabaseConfig {
  // IMPORTANTE: Reemplaza estos valores con los de tu proyecto Supabase
  // Los puedes encontrar en: Project Settings > API
  static const String supabaseUrl = 'TU_SUPABASE_URL';
  static const String supabaseAnonKey = 'TU_SUPABASE_ANON_KEY';
  
  // Nombres de las tablas
  static const String productosTable = 'productos';
  static const String carritoTable = 'carrito';
  static const String ordenesTable = 'ordenes';
  static const String ordenItemsTable = 'orden_items';
  
  // Configuración adicional
  static const Duration timeoutDuration = Duration(seconds: 30);
}