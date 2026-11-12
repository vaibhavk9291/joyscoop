class Product {
  final String id;
  final String name;
  final int price;
  final int sortOrder;
  final bool isActive;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.sortOrder,
    this.isActive = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toInt(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'sort_order': sortOrder,
    'is_active': isActive,
  };

  /// Asset path based on product name
  String get assetPath {
    final lower = name.toLowerCase();
    if (lower.contains('choco') || lower.contains('dip')) {
      return 'assets/products/softy_choco_dip.png';
    } else if (lower.contains('vanilla')) {
      return 'assets/products/cold_coffee_vanilla.png';
    } else if (lower.contains('crush')) {
      return 'assets/products/cold_coffee_crush.png';
    } else if (lower.contains('coffee')) {
      return 'assets/products/cold_coffee.png';
    } else {
      return 'assets/products/softy.png';
    }
  }

  /// Default fixed catalog for initial seed / fallback
  static List<Product> defaultProducts() => const [
    Product(id: 'prod-softy', name: 'Softy', price: 25, sortOrder: 1),
    Product(
      id: 'prod-softy-choco-dip',
      name: 'Softy Choco Dip',
      price: 40,
      sortOrder: 2,
    ),
    Product(
      id: 'prod-cold-coffee',
      name: 'Cold Coffee',
      price: 40,
      sortOrder: 3,
    ),
    Product(
      id: 'prod-coffee-crush',
      name: 'Coffee with Crush',
      price: 50,
      sortOrder: 4,
    ),
    Product(
      id: 'prod-coffee-vanilla',
      name: 'Coffee with Vanilla',
      price: 55,
      sortOrder: 5,
    ),
  ];
}
