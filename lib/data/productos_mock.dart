import '../models/producto.dart';

class ProductosMock {
  static final List<Producto> productos = [
    Producto(
      id: '1',
      titulo: 'Laptop HP Pavilion',
      descripcion: 'Laptop con procesador Intel Core i5, 8GB RAM, 256GB SSD',
      precio: 699.99,
      imagen: '💻',
      categoria: 'Electrónica',
      stockDisponible: 10,
    ),
    Producto(
      id: '2',
      titulo: 'Mouse Logitech MX',
      descripcion: 'Mouse inalámbrico ergonómico con sensor de alta precisión',
      precio: 49.99,
      imagen: '🖱️',
      categoria: 'Accesorios',
      stockDisponible: 10,
    ),
    Producto(
      id: '3',
      titulo: 'Teclado Mecánico',
      descripcion: 'Teclado mecánico RGB con switches blue',
      precio: 89.99,
      imagen: '⌨️',
      categoria: 'Accesorios',
      stockDisponible: 10,
    ),
    Producto(
      id: '4',
      titulo: 'Monitor LG 27"',
      descripcion: 'Monitor Full HD IPS de 27 pulgadas',
      precio: 249.99,
      imagen: '🖥️',
      categoria: 'Electrónica',
      stockDisponible: 10,
    ),
    Producto(
      id: '5',
      titulo: 'Audífonos Sony',
      descripcion: 'Audífonos bluetooth con cancelación de ruido',
      precio: 149.99,
      imagen: '🎧',
      categoria: 'Audio',
      stockDisponible: 10,
    ),
    Producto(
      id: '6',
      titulo: 'Webcam Logitech',
      descripcion: 'Cámara web Full HD 1080p con micrófono integrado',
      precio: 79.99,
      imagen: '📹',
      categoria: 'Accesorios',
      stockDisponible: 10,
    ),
    Producto(
      id: '7',
      titulo: 'Tablet Samsung',
      descripcion: 'Tablet Android de 10.1 pulgadas, 64GB',
      precio: 299.99,
      imagen: '📱',
      categoria: 'Electrónica',
      stockDisponible: 10,
    ),
    Producto(
      id: '8',
      titulo: 'Router WiFi 6',
      descripcion: 'Router de alta velocidad con tecnología WiFi 6',
      precio: 129.99,
      imagen: '📡',
      categoria: 'Redes',
      stockDisponible: 10,
    ),
  ];

  static List<Producto> obtenerProductos() {
    return List.from(productos);
  }

  static Producto? obtenerProductoPorId(String id) {
    try {
      return productos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Producto> obtenerProductosPorCategoria(String categoria) {
    return productos.where((p) => p.categoria == categoria).toList();
  }

  static List<String> obtenerCategorias() {
    return productos.map((p) => p.categoria).toSet().toList();
  }
}