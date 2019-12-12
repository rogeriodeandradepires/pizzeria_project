class Product {
  String description;
  String ingredients;
  String category;
  String categoryName;
  String id;
  String imageUrl;
  String notes;
  String price;
  String promotional_price;
  String size;
  String price_broto;
  String price_inteira;
  bool userLiked;

  Product({
    this.description,
    this.ingredients,
    this.category,
    this.categoryName,
    this.id,
    this.imageUrl,
    this.notes,
    this.price,
    this.promotional_price,
    this.size,
    this.price_broto,
    this.price_inteira,
    this.userLiked,
  });

  _parseResult(List<dynamic> data) {
    List<Product> results = new List<Product>();
    data.forEach((item) {
      results.add(Product.fromJson(item));
    });
    return results;
  }

  _parseString(List<dynamic> data) {
    List<String> results = new List<String>();
    data.forEach((item) {
      results.add(item);
    });
    return results;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      description: json['description'],
      ingredients: json['ingredients'],
      id: json['id'],
      imageUrl: json['image'],
      notes: json['notes'],
      price: json['price'],
      promotional_price: json['promotional_price'],
      size: json['size'],
      price_broto: json['price_broto'],
      price_inteira: json['price_inteira'],
    );
  }
}