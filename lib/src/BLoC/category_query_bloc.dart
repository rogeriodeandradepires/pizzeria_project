import 'dart:async';
import 'dart:convert';

import 'package:dom_marino_app/src/BLoC/bloc.dart';
import 'package:dom_marino_app/src/models/category_result_model.dart';
import 'package:http/http.dart';

class CategoryQueryBloc implements Bloc {
  final _controller = StreamController<List<Category>>();
  Stream<List<Category>> get categoryStream => _controller.stream;

  void submitQuery() async {
    String url = 'https://dom-marino-webservice.appspot.com/list_categories';
    Response response = await get(url);
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    var results = json.decode(response.body);

    List<Category> all_categories_obj_list = new List();

    if (response.statusCode == 200) {
      results.forEach((category) {
        all_categories_obj_list.add(Category.fromJson(category));
//        print(category);
      });
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load category');
    }

//  }
    _controller.sink.add(all_categories_obj_list);
  }

  @override
  void dispose() {
    _controller.close();
  }
}