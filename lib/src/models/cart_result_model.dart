class Cart {
  String userID;
  String dateRegister;
  String id;

  Cart({
    this.userID,
    this.dateRegister,
    this.id,
  });

  _parseResult(List<dynamic> data) {
    List<Cart> results = new List<Cart>();
    data.forEach((item) {
      results.add(Cart.fromJson(item));
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

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userID: json['userID'],
      dateRegister: json['dateRegister'],
      id: json['id'],
    );
  }
}