import 'dart:async';

import 'package:dom_marino_app/src/BLoC/bloc.dart';

class TotalPriceBloc implements Bloc {
  final controller = StreamController<String>();
  Stream<String> get totalPriceStream => controller.stream;
  Sink<String> get totalPriceSink => controller.sink;

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