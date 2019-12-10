import 'dart:async';

import 'package:dom_marino_app/src/BLoC/bloc.dart';
import 'package:flutter/widgets.dart';

class AllCartItemsBloc implements Bloc {
  final controller = StreamController<List<Widget>>();
  Stream<List<Widget>> get allCartItemsStream => controller.stream;
  Sink<List<Widget>> get allCartItemsSink => controller.sink;

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