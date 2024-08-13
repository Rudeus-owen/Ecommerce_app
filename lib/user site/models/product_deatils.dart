class Product {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'] ?? '',
    );
  }
}

class ItemImage {
  final int id;
  final String imageUrl;

  ItemImage({required this.id, required this.imageUrl});

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      id: json['id'],
      imageUrl: json['image_url'],
    );
  }
}

class ProductVariation {
  final int id;
  final String variationName;
  final double price;
  final double? promotionPrice;
  final String? endDate;
  final int colorId;

  ProductVariation({
    required this.id,
    required this.variationName,
    required this.price,
    this.promotionPrice,
    this.endDate,
    required this.colorId,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      id: json['id'],
      variationName: json['variation_name'],
      price: json['price'].toDouble(),
      promotionPrice: json['promotion_price']?.toDouble(),
      endDate: json['end_date'],
      colorId: json['color_id'],
    );
  }
}

class ProductColor {
  final int id;
  final String colorName;

  ProductColor({required this.id, required this.colorName});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      id: json['id'],
      colorName: json['color_name'],
    );
  }
}

class ProductDetail {
  final Product product;
  final List<ItemImage> itemImages;
  final List<ProductVariation> productVariations;
  final List<ProductColor> productColors;

  ProductDetail({
    required this.product,
    required this.itemImages,
    required this.productVariations,
    required this.productColors,
  });
}
