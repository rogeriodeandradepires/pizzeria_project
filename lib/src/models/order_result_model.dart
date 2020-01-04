class Order {
  String coupon_id;
  String dateTime;
  String id;
  String delivery;
  String payment_method;
  String total;
  String userId;
  List<dynamic> products_id;

  Order({
    this.coupon_id,
    this.dateTime,
    this.id,
    this.delivery,
    this.payment_method,
    this.total,
    this.userId,
    this.products_id,
  });

  _parseResult(List<dynamic> data) {
    List<Order> results = new List<Order>();
    data.forEach((item) {
      results.add(Order.fromJson(item));
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

  factory Order.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> all_orders = json['products_id'];
    List<dynamic> orders = all_orders.values.toList();

//    print(orders.length.toString());


//    orders.forEach((product) {
//      print(product['category']);
//    });

    return Order(
      coupon_id: json['coupon_id'],
      id: json['id'],
      delivery: json['image'],
      payment_method: json['payment_method'],
      total: json['total'],
      dateTime: json['dateTime'],
      userId: json['userId'],
      products_id: orders,
    );
  }
}