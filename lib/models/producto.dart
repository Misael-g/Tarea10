class Producto {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String imagen;
  final String categoria;
  final int stockDisponible;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Producto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.categoria,
    this.stockDisponible = 10,
    this.createdAt,
    this.updatedAt,
  });

  // Constructor desde JSON de Supabase
  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id']?.toString() ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      precio: (json['precio'] ?? 0).toDouble(),
      imagen: json['imagen'] ?? '📦',
      categoria: json['categoria'] ?? '',
      stockDisponible: json['stock_disponible'] ?? 10,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  // Convertir a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stock_disponible': stockDisponible,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  // Para inserción (sin id ni timestamps)
  Map<String, dynamic> toInsertJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stock_disponible': stockDisponible,
    };
  }

  // Métodos heredados del código original
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto.fromJson(map);
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }

  Producto copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    double? precio,
    String? imagen,
    String? categoria,
    int? stockDisponible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Producto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}