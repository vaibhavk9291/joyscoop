import 'product.dart';

class ProductSalesState {
  final Product product;
  final int unitsSold;

  const ProductSalesState({
    required this.product,
    this.unitsSold = 0,
  });

  int get revenue => unitsSold * product.price;

  ProductSalesState copyWith({
    Product? product,
    int? unitsSold,
  }) {
    return ProductSalesState(
      product: product ?? this.product,
      unitsSold: unitsSold ?? this.unitsSold,
    );
  }
}

