class CartItem {
  int cartItemsId;
  String productCategory;
  String categoryName;
  String userId;
  String productId;
  String product2Id;
  String pizzaEdgeId;
  int cartId;
  int productAmount;
  String productObservations;
  String productSize;
  int isTwoFlavoredPizza;

  CartItem({
    this.cartItemsId,
    this.productCategory,
    this.categoryName,
    this.userId,
    this.productId,
    this.product2Id,
    this.pizzaEdgeId,
    this.cartId,
    this.productAmount,
    this.productObservations,
    this.productSize,
    this.isTwoFlavoredPizza,
  });

  _parseResult(List<dynamic> data) {
    List<CartItem> results = new List<CartItem>();
    data.forEach((item) {
      results.add(CartItem.fromJson(item));
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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemsId: json['cartItemsId'],
      productCategory: json['productCategory'],
      categoryName: json['categoryName'],
      productId: json['productId'],
      product2Id: json['product2Id'],
      pizzaEdgeId: json['pizzaEdgeId'],
      cartId: json['cartId'],
      productAmount: json['productAmount'],
      productObservations: json['productObservations'],
      productSize: json['productSize'],
      isTwoFlavoredPizza: json['isTwoFlavoredPizza'],
    );
  }
}