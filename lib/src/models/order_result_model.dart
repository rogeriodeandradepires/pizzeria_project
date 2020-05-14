class Order {
  String coupon_id;
  String dateTime;
  String id;
  String delivery;
  String payment_method;
  String total;
  String userId;
  String deliveryAddress;
  String paymentChange;
  List<dynamic> products_id;

  Order({
    this.coupon_id,
    this.dateTime,
    this.id,
    this.delivery,
    this.deliveryAddress,
    this.payment_method,
    this.paymentChange,
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
      delivery: json['delivery'],
      deliveryAddress: json['delivery_address'],
      payment_method: json['payment_method'],
      paymentChange: json['payment_change'],
      total: json['total'],
      dateTime: json['dateTime'],
      userId: json['userId'],
      products_id: orders,
    );
  }
}