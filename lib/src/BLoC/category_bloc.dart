import 'dart:async';

import 'package:dom_marino_app/src/models/category_result_model.dart';

import 'bloc.dart';

class CategoryBloc implements Bloc {
  Category _category;
  Category get selectedCategory => _category;

  // 1
  final _categoryController = StreamController<Category>();

  // 2
  Stream<Category> get categoryStream => _categoryController.stream;

  // 3
  void selectLocation(Category _category) {
    _category = _category;
    _categoryController.sink.add(_category);
  }

  // 4
  @override
  void dispose() {
    _categoryController.close();
  }
}