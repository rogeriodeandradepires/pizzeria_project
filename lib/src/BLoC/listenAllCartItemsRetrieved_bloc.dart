import 'dart:async';

import 'package:dom_marino_app/src/BLoC/bloc.dart';
import 'package:flutter/widgets.dart';

class ListenAllCartItemsReceivedBloc implements Bloc {
  final controller = StreamController<int>();
  Stream<int> get listenAllCartItemsReceivedBlocStream => controller.stream;
  Sink<int> get listenAllCartItemsReceivedBlocSink => controller.sink;

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