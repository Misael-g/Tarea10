class Producto {
  final String id;
  final String titulo;
  final String descripcion;
  final double precio;
  final String imagen;
  final String categoria;
  final int stockDisponible;

  Producto({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precio,
    required this.imagen,
    required this.categoria,
    this.stockDisponible = 10, // Stock mock por defecto
  });

  // Constructor para crear desde Map (útil para datos mock)
  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'] ?? '',
      titulo: map['titulo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0).toDouble(),
      imagen: map['imagen'] ?? '',
      categoria: map['categoria'] ?? '',
      stockDisponible: map['stockDisponible'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'precio': precio,
      'imagen': imagen,
      'categoria': categoria,
      'stockDisponible': stockDisponible,
    };
  }

  // Crear copia con modificaciones
  Producto copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    double? precio,
    String? imagen,
    String? categoria,
    int? stockDisponible,
  }) {
    return Producto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      precio: precio ?? this.precio,
      imagen: imagen ?? this.imagen,
      categoria: categoria ?? this.categoria,
      stockDisponible: stockDisponible ?? this.stockDisponible,
    );
  }
}