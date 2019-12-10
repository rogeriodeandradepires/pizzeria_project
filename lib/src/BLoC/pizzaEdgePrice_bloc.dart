import 'dart:async';

import 'package:dom_marino_app/src/BLoC/bloc.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';

class PizzaEdgePriceBloc implements Bloc {
  final controller = StreamController<Product>();
  Stream<Product> get pizzaEdgePriceBlocStream => controller.stream;
  Sink<Product> get pizzaEdgePriceBlocSink => controller.sink;

//  void sinkString(String newTotal) async {
//
//
//    totalPriceStream.sink = newTotal;
//  }

  @override
  void dispose() {
    controller.close();
  }
}