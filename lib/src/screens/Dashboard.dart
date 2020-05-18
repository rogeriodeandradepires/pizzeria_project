import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dom_marino_app/src/bottomNavigationView/bottomBarView.dart';
import 'package:dom_marino_app/src/models/category_result_model.dart';
import 'package:dom_marino_app/src/models/order_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/models/tabIconData.dart';
import 'package:dom_marino_app/src/shared/buttons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/fryo_icons.dart';
import './ProductPage.dart';
import '../shared/partials.dart';
import 'package:http/http.dart';
import 'package:dom_marino_app/src/shared/database_helper.dart';

import 'AboutPage.dart';
import 'CartPage.dart';

import 'package:dio/dio.dart' as diolib;

import 'SignInMainPage.dart';
import 'SignUpMainPage.dart';

List<Category> all_categories_obj_list = new List();
List<Product> all_products_obj_list = new List();
List<Order> all_orders_obj_list = new List();

class Dashboard extends StatefulWidget {
  final String pageTitle;

  Dashboard({Key key, this.pageTitle}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  var _selectedCategory = "Promoções";
  var _selectedCategoryName = "promotions";
  AnimationController animationController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  ListView globalProductsListView;
  ListView globalStoreTabListView;
  ScrollController _controller;
  var dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> allFavorites = new List();
  List<Map<String, dynamic>> allOrders = new List();
  FirebaseUser user;
  FirebaseAuth fbAuth = FirebaseAuth.instance;
  BuildContext globalContext;
  BuildContext globalScaffoldContext;
  ListView ordersTab;
  var _tabs;
  bool isSnackbarVisible = false;

  Future<dynamic> futureCategories;
  Future<dynamic> futureProducts;

  int storeTabsErrorCount = 1;
  bool isErrorShown = false;

  CollectionReference _collection = Firestore.instance.collection('webservice_address');
  SharedPreferences prefs;

  Widget tabBody = new Container(
    decoration: new BoxDecoration(
      image: new DecorationImage(
        image: new AssetImage("images/main_bg.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  Map<String, dynamic> thisUser = new Map();

  int dioErrorCount = 0;

  BottomBarView bottomBarView;

  String uri;
  String url;

  @override
  void initState() {

    fbAuth.onAuthStateChanged.listen((newUser) {
      setState(() {
        user = newUser;
      });

//      if (newUser != null) {
////        setBottombarView();
//
//        retrieveAllOrders(user.uid);
//      }
    });

    retrieveAllFavorites(null);

    _controller = ScrollController();

    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);

//    futureCategories = getCategories();
//    futureProducts = getProducts(_selectedCategoryName);

    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      checkRegisterComplete();

      checkWebserviceSharedPreferences();

    });
  }

  @override
  void dispose() {
    animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    _tabs = [
      storeTab(context),
      favoritesTab(context),
      buildOrdersTab(globalContext),
      profileTab(context),
    ];

    return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'images/leading_logo_icon_wide.png',
              fit: BoxFit.cover,
            ),
          ),
          backgroundColor: primaryColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'images/title_logo_icon_wide_minor.png',
                fit: BoxFit.contain,
                height: 40.0,
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              padding: EdgeInsets.all(0),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => new AboutPage()),
                );
              },
              iconSize: 21,
              icon: Icon(Fryo.location),
            )
          ],
        ),
        body: new Builder(builder: (BuildContext context) {
          globalScaffoldContext = context;
          return Stack(
            children: <Widget>[
              new Container(
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    image: new AssetImage("images/main_bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _tabs[_selectedIndex],
              bottomBar(),
            ],
          );
        }));
  }

  Widget bottomBar() {

    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        bottomBarView == null ? Container() : bottomBarView,
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<Widget> getFavoritedProducts(
      List<Map<String, dynamic>> favoriteList) async {
    ScrollController _thisController = ScrollController();
    ListView retorno;
//    print("entrou na lista");
    String subListTitle = "";
//    List<Product> favoritedProducts = new List();
    List<Widget> thisList = new List();

    for (Map<String, dynamic> favorited in favoriteList) {
      if (subListTitle != favorited['category']) {
        subListTitle = favorited['category'];
        thisList.add(sectionHeader(subListTitle, onViewMore: () {}));
      }
      Product retrievedProduct =
          await getProduct(favorited['categoryName'], favorited['productId']);
      retrievedProduct.userLiked = true;
      Widget thisItem;
      thisItem = foodItem(context, retrievedProduct, onTapped: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return new ProductPage(
                productData: retrievedProduct,
                category: favorited['category'],
                categoryName: _selectedCategoryName,
                dbHelper: dbHelper,
                user: user,
              );
            },
          ),
        );
      }, onLike: () async {
        bool isLogged = await checkIfUserIsLoggedIn();
        if (isLogged) {
          Map<String, dynamic> favorite;
          try {
            favorite =
                await dbHelper.searchFavorite(user.uid, retrievedProduct.id);
          } on Exception catch (e, s) {
            print(
                "Exception: " + e.toString() + ", Stacktrace: " + s.toString());
          }

          //se o favorito está no db
          if (favorite['isUserLiked'] == 1) {
            //se é favorito
            Map<String, dynamic> row = {
              DatabaseHelper.columnId: user.uid + retrievedProduct.id,
              DatabaseHelper.columnCategory: favorited['category'],
              DatabaseHelper.columnCategoryName: favorited['categoryName'],
              DatabaseHelper.columnUserId: user.uid,
              DatabaseHelper.columnProductId: retrievedProduct.id,
              DatabaseHelper.columnIsLiked: 0
            };

            await dbHelper.update(row, "favorites", "_id");
            await retrieveAllFavorites(user.uid);

            setState(() {
              retrievedProduct.userLiked = false;
              thisList.remove(thisItem);
            });
          } //se é favorito

        } else {
          //não está logado
//          final result = await Navigator.pushNamed(context, '/signin');
          final result = await Navigator.push(context,
            MaterialPageRoute(
                builder: (context) =>
                new SignInMainPage(uri: uri, url: url)),
          );
//          print(" 3 Result=" + result);

          if (result == "Ok") {
            checkRegisterComplete();
          }
        }
      });
      thisList.add(thisItem);
    }

//    favoritedProducts.forEach((product) {
//      thisList.add(foodItem(context, product));
//    });

//    favoritedProducts.sort((a, b) {
//      return a.description.toLowerCase().compareTo(b.description.toLowerCase());
//    });

//    Container retorno = new Container(
//        child: Column(
//      mainAxisAlignment: MainAxisAlignment.center,
//      crossAxisAlignment: CrossAxisAlignment.center,
//      mainAxisSize: MainAxisSize.min,
//      children: thisList,
//    ));

    retorno = ListView(
        key: UniqueKey(),
        controller: _thisController,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        children: thisList);

    return retorno;
  }

  Future<Product> getProduct(String category, String id) async {
//    String category = _selectedCategoryName;

    var queryParameters = {
      'id': '$id',
    };

    String thisUrl = url + 'list_' + category;
    var thisUri = Uri.https(
        uri, 'list_$category', queryParameters);

    try {
      Response response = await get(thisUri);
      // sample info available in response
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];
      dynamic allProducts = json.decode(response.body);

//    print(all_products.toString());

      if (response.statusCode == 200) {
        all_products_obj_list = new List();

        all_products_obj_list.add(Product.fromJson(allProducts));

        return Product.fromJson(allProducts);
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load product');
      }
    } catch (e) {
//      showSnackbarError();
      print("Aqui getProduct erro: " + e.toString());
    }
  }

  Future getProducts(String category) async {
//    String category = _selectedCategoryName;
    String thisUrl = url+'list_' + category;
//    print(url);

    try {
      Response response = await get(thisUrl);
      // sample info available in response
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];
      dynamic all_products = json.decode(response.body);

      if (response.statusCode == 200) {
        all_products_obj_list = new List();
        all_products.forEach((product) {
          all_products_obj_list.add(Product.fromJson(product));
//        print(product);
        });
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load products');
      }

      all_products_obj_list.sort((a, b) {
        return a.description
            .toLowerCase()
            .compareTo(b.description.toLowerCase());
      });
    } catch (e) {
//      print("Aqui getProducts erro: " + e.toString());
    }

    return all_products_obj_list;
  }

  Future getCategories() async {
//    String url = 'https://dom-marino-webservice.appspot.com/list_categories';
//    Response response;
//    final client = Client();

    var thisUrl = url+"list_categories";
//      var url = "http://192.168.63.1:8080/makeorder";

    diolib.Dio dio = new diolib.Dio();
    final cancelToken = diolib.CancelToken();

    try {
//      response = await client.get(url);
//      client.close();
      diolib.Response apiResponse =
          await dio.get(thisUrl, cancelToken: cancelToken);
//      print(apiResponse.data.toString());
      // sample info available in response
//      int statusCode = response.statusCode;
//      Map<String, String> headers = response.headers;
//      String contentType = headers['content-type'];
      var response = apiResponse.data;
      dynamic all_categories = response; //json.decode(response);

//      dynamic all_categories = json.decode(response.body);

//      print("Aqui getCategories: " + response.statusCode.toString());

//      if (response.statusCode == 200) {
//      } else {
//
//      }

      all_categories_obj_list = new List();
      all_categories.forEach((category) {
        all_categories_obj_list.add(Category.fromJson(category));
//        print(category);
      });
//      } else {
//        print("Erro "+response.toString());
//        // If that response was not OK, throw an error.
//        throw Exception('Failed to load category');
//      }

      all_categories_obj_list.sort((a, b) {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      });

      List<Category> temp_all_categories_obj_list = new List();
      temp_all_categories_obj_list.addAll(all_categories_obj_list);
      Category temp_last_category = temp_all_categories_obj_list
          .elementAt(temp_all_categories_obj_list.length - 1);
      temp_all_categories_obj_list
          .removeAt(temp_all_categories_obj_list.length - 1);
      Category temp_category;

      for (Category category in all_categories_obj_list) {
        if (category.name == "two_flavored_pizzas") {
          Category other_category = category;
          temp_category = category;
          temp_all_categories_obj_list.remove(other_category);
        }
      }

      temp_all_categories_obj_list.add(temp_category);
      temp_all_categories_obj_list.add(temp_last_category);

      all_categories_obj_list = temp_all_categories_obj_list.reversed.toList();

      if (_selectedCategory == "") {
        setState(() {
          _selectedCategory = all_categories_obj_list.elementAt(0).description;
          _selectedCategoryName = all_categories_obj_list.elementAt(0).name;
        });
        futureProducts = getProducts(_selectedCategoryName);
      }

//      setState(() {
//        isErrorShown = false;
//      });

    } on TimeoutException catch (_) {
      print("timeoutException: " + _.toString());
//      dio.close();
//      setState(() {
//        isErrorShown = true;
//      });
    } on SocketException catch (_) {
//      client.close();

//    dio.close();

//      getCategories();

//      if (storeTabsErrorCount < 3) {
//        setState(() {
//          storeTabsErrorCount++;
//          getCategories();
////          _tabs[0] = storeTab(context);
//        });
//      } else {
//        storeTabsErrorCount = 1;
////          showSnackbarError();
//        print("Mostrou o erro getCategories");
//
//        setState(() {
//          isErrorShown = true;
//        });
//      }

      print("Aqui socket erro:" + _.toString());
    } catch (e) {
//    dio.close(force: true);

      if (e is diolib.DioError) {
//        if(!cancelToken.isCancelled){
//          cancelToken.cancel();

        print("is dioerror:$e");

        dioErrorCount++;

        if (dioErrorCount >= 2) {
          if (!cancelToken.isCancelled) {
            cancelToken.cancel("cancelled");
            setState(() {
              isErrorShown = true;
            });
          }
        }
      } else {}

      print("Aqui getCategories erro:" + e.toString());
    }

    return all_categories_obj_list;
  }

  Widget storeTab(BuildContext context) {
    globalStoreTabListView = ListView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _controller,
        children: <Widget>[
          headerTopCategories('Todas as Categorias'),
          deals(_selectedCategory, onViewMore: () {}, items: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder(
                builder: (context, productSnap) {
                  if (productSnap.connectionState == ConnectionState.done) {
                    if (productSnap.data != null) {
                      if (productSnap.data.length == 0) {
                        print("deu erro nos produtos 1");
                        return showUpdateWindow(finished: true);
                      }
                    }
                  }

                  if (productSnap.connectionState == ConnectionState.none &&
                      productSnap.hasData == null) {
                    //print('product snapshot data is: ${productSnap.data}');
                    return showUpdateWindow(finished: true);
                  } else if (productSnap.hasData) {
                    globalProductsListView = ListView.builder(
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      physics: const AlwaysScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: productSnap.data != null
                          ? productSnap.data.length + 1
                          : 0,
                      itemBuilder: (context, index) {
                        Product product;

                        if (index < productSnap.data.length) {
                          //se o indice é menor que o total
                          product = productSnap.data[index];
//                          print(dbHelper.searchFavorite(product.id));

                          for (Map<String, dynamic> favorited in allFavorites) {
                            if (favorited['productId'] == product.id) {
//                              print("product.id:" + product.id + " é favorito");
                              if (user != null) {
                                if (favorited['userId'] == user.uid) {
                                  product.userLiked = true;
                                }
                              }
                            }
                          }

                          return foodItem(context, product, onTapped: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return new ProductPage(
                                    productData: product,
                                    category: _selectedCategory,
                                    categoryName: _selectedCategoryName,
                                    dbHelper: dbHelper,
                                    user: user,
                                  );
                                },
                              ),
                            );
                          }, onLike: () async {
                            bool isLogged = await checkIfUserIsLoggedIn();
                            if (isLogged) {
                              Map<String, dynamic> favorite;
                              try {
                                favorite = await dbHelper.searchFavorite(
                                    user.uid, product.id);
                              } on Exception catch (e, s) {
                                print("Exception: " +
                                    e.toString() +
                                    ", Stacktrace: " +
                                    s.toString());
                              }

                              if (favorite == null) {
//                                print("favorite is null, insert to db");
                                if (user != null) {
                                  Map<String, dynamic> row = {
                                    DatabaseHelper.columnId:
                                        user.uid + product.id,
                                    DatabaseHelper.columnCategory:
                                        _selectedCategory,
                                    DatabaseHelper.columnCategoryName:
                                        _selectedCategoryName,
                                    DatabaseHelper.columnUserId: user.uid,
                                    DatabaseHelper.columnProductId: product.id,
                                    DatabaseHelper.columnIsLiked: 1
                                  };

                                  await dbHelper.insert(row, "favorites");

                                  setState(() {
                                    product.userLiked = true;
                                  });
                                }
                              } else {
                                //se o favorito está no db
                                if (favorite['isUserLiked'] == 1) {
                                  //se já é favorito
//                                  print("favorite is not null, remove flag");
                                  //se é favorito
                                  if (user != null) {
                                    Map<String, dynamic> row = {
                                      DatabaseHelper.columnId:
                                          user.uid + product.id,
                                      DatabaseHelper.columnCategory:
                                          _selectedCategory,
                                      DatabaseHelper.columnCategoryName:
                                          _selectedCategoryName,
                                      DatabaseHelper.columnUserId: user.uid,
                                      DatabaseHelper.columnProductId:
                                          product.id,
                                      DatabaseHelper.columnIsLiked: 0
                                    };

                                    await dbHelper.update(
                                        row, "favorites", "_id");

                                    setState(() {
                                      product.userLiked = false;
                                    });
                                  }
                                } else {
                                  //se ainda não é favorito
//                                  print("favorite is not null, set new flag");
                                  //se não é favorito
                                  if (user != null) {
                                    Map<String, dynamic> row = {
                                      DatabaseHelper.columnId:
                                          user.uid + product.id,
                                      DatabaseHelper.columnCategory:
                                          _selectedCategory,
                                      DatabaseHelper.columnCategoryName:
                                          _selectedCategoryName,
                                      DatabaseHelper.columnUserId: user.uid,
                                      DatabaseHelper.columnProductId:
                                          product.id,
                                      DatabaseHelper.columnIsLiked: 1
                                    };

                                    await dbHelper.update(
                                        row, "favorites", "_id");

                                    setState(() {
                                      product.userLiked = true;
                                    });
                                  }
                                } //else se ainda não é favorito
                              } //else se o favorito está no db

                              retrieveAllFavorites(user.uid);
                            } else {
                              //não está logado
//                              final result =
//                                  await Navigator.pushNamed(context, '/signin');
                              final result = await Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                    new SignInMainPage(uri: uri, url: url)),
                              );

//                              print("4 Result=" + result);

                              if (result == "Ok") {
                                checkRegisterComplete();
                              }
                            }
                          }); //onLike
                        } else {
                          //se é o ultimo item da lista de produtos
                          return generateDummyListItem(320);
                        }
                      },
                    );

                    if (productSnap.data.length == 0) {
                      print("deu erro nos produtos 2");
                      return showUpdateWindow(finished: true);
                    } else {
                      return globalProductsListView;
                    }
                  }

                  return Container(
                    margin: EdgeInsets.only(left: 110, right: 110, bottom: 300),
                    child: _showOverlay(context),
                  );
                },
                future: futureProducts,
              ),
            )
          ]),
        ]);

    if (isErrorShown) {
      return showUpdateWindow();
    } else {
      return globalStoreTabListView;
    }
  }

  Widget favoritesTab(BuildContext context) {
    List<Widget> favoritesWidgetLists = <Widget>[];
    favoritesWidgetLists
        .add(sectionHeader('Meus Favoritos', onViewMore: () {}));
//    List<Widget> thisList = buildFavoritesLists();
//    favoritesWidgetLists.addAll(thisList);
    favoritesWidgetLists.add(buildFavoritesLists());

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: favoritesWidgetLists,
    );
  }

  Widget sectionHeader(String headerTitle, {onViewMore}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 5, top: 5),
          child: Text(headerTitle, style: h4),
        ),
//      Container(
//        margin: EdgeInsets.only(left: 15, top: 2),
//        child: FlatButton(
//          onPressed: onViewMore,
//          child: Text('View all ›', style: contrastText),
//        ),
//      )
      ],
    );
  }

// wrap the horizontal listview inside a sizedBox..
  Widget headerTopCategories(String title) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        sectionHeader(title, onViewMore: () {}),
        SizedBox(
            height: 100,
            child: FutureBuilder(
              builder: (context, categorySnap) {
                if (categorySnap.connectionState == ConnectionState.none &&
                    categorySnap.hasData == null) {
                  //print('category snapshot data is: ${categorySnap.data}');

//                  if(categorySnap.connectionState==ConnectionState.done){
//                  if(categorySnap.data!=null){
//                    if(categorySnap.data.length==0){
//                      print("deu erro na categoria");
//                      setState(() {
//                        isErrorShown = true;
//                      });
//                    }
//                  }
//                }

                  return showUpdateWindow(finished: true);
                } else if (categorySnap.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: categorySnap.data != null
                        ? categorySnap.data.length
                        : 0,
                    itemBuilder: (context, index) {
                      Category category = categorySnap.data[index];
                      if (index == 0) {
                        if (_selectedCategory == "") {
                          _selectedCategory = category.description;
                          _selectedCategoryName = category.name;
                          futureProducts = getProducts(_selectedCategoryName);
                        }
                      }
                      return headerCategoryItem(
                          category.description, category.icon, onPressed: () {
                        setState(() {
                          globalProductsListView.controller.jumpTo(0);
                          _selectedCategory = category.description;
                          _selectedCategoryName = category.name;
                          futureProducts = getProducts(_selectedCategoryName);
                        });
                      });
                    },
                  );
                }

                return Container(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: _showOverlay(context),
                );
              },
              future: futureCategories,
            ))
      ],
    );
  }

  Widget headerCategoryItem(String name, String iconUrl, {onPressed}) {
    var nameRows = name.split(" ");
    var secondRowofName = "";

    if (nameRows.length > 1 && nameRows.length < 3) {
      secondRowofName = nameRows[1];
    } else {
      if (nameRows.length == 3) {
        secondRowofName = nameRows[1] + " " + nameRows[2];
      }

      if (nameRows.length > 3) {
        nameRows[0] = nameRows[0] + " " + nameRows[1];
        secondRowofName = nameRows[2] + " " + nameRows[3];
      }
    }

    return Container(
      margin: EdgeInsets.only(left: 5, right: 5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              margin: EdgeInsets.only(bottom: 5, right: 10, left: 10),
              width: 50,
              height: 50,
              child: FloatingActionButton(
                shape: CircleBorder(),
                heroTag: name,
                onPressed: onPressed,
                backgroundColor: Color(0xff4c2717),
                child: Image.network(iconUrl, height: 35, width: 35),
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(nameRows[0] + ' ›', style: categoryText),
              Text(secondRowofName, style: categoryText),
            ],
          ),
        ],
      ),
    );
  }

  Widget deals(String dealTitle, {onViewMore, List<Widget> items}) {
//    items.add(generateDummyListItem());

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          sectionHeader(dealTitle, onViewMore: onViewMore),
          ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: (items != null)
                ? items
                : <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 15),
                      child: Text('Nenhum item disponível neste momento.',
                          style: taglineText),
                    )
                  ],
          )
        ],
      ),
    );
  }

  Widget generateDummyListItem(double height) {
    return new SizedBox(
      height: height,
      child: Container(
//        color: Colors.red,
          ),
    );
  }

  Widget _showOverlay(BuildContext context) {
//    Navigator.of(context).push(TutorialOverlay());

    return Image.asset(
      'images/loading_pizza_faster.gif',
      fit: BoxFit.scaleDown,
    );
  }

  Future<bool> checkIfUserIsLoggedIn() async {
    user = await fbAuth.currentUser();
    bool isLogged = user != null;
    return isLogged;
  }

  Future<void> retrieveAllOrders(String uid, {bool update}) async {
    if (update != null) {
      if (update) {
        Dialog thisDialog = showLoadingDialog();
      }
    }
    var queryParameters = {
      'id': '$uid',
    };

    var thisUri = Uri.https(uri, 'list_user_orders',
        queryParameters);

    try {
      Response response = await get(thisUri);
      // sample info available in response
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];
      dynamic all_orders = json.decode(response.body);

      if (response.statusCode == 200) {
        all_orders_obj_list = new List();
        all_orders.forEach((order) {
          all_orders_obj_list.add(Order.fromJson(order));
        });
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load products');
      }

      all_orders_obj_list.sort((a, b) {
        var aDateTime = DateTime.parse(a.dateTime);
        var bDateTime = DateTime.parse(b.dateTime);

        return bDateTime.compareTo(aDateTime);
      });
    } catch (e) {
//      showSnackbarError();
      print("Aqui retrieveAllOrders erro: " + e.toString());
    }

    if (update != null) {
      if (update) {
        Navigator.pop(context);
        setState(() {
          _tabs[2] = buildOrdersTab(globalContext);
        });
      }
    }

    return all_orders_obj_list;
  }

  Future<void> retrieveAllFavorites(String uid) async {
    List<Map<String, dynamic>> tempAllFavorites =
        await dbHelper.retrieveAllFavorites(uid);
    allFavorites = new List();
    allFavorites.addAll(tempAllFavorites);

//    print(allFavorites.length);
  }

  Widget buildFavoritesLists() {
    List<Widget> columnChildren = new List();

    if (user != null && allFavorites != null) {
      retrieveAllFavorites(user.uid);
//      List<Map<String, dynamic>> orderedFavorites = new List();
//      orderedFavorites.addAll(allFavorites);
      List<List<Map<String, dynamic>>> finalFavorites = new List();
      allFavorites.sort((a, b) => a['category'].compareTo(b['category']));
      allFavorites = allFavorites.reversed.toList();
      int start = 0, end = 0;

      for (int i = 0; i < allFavorites.length; i++) {
        if (i != allFavorites.length - 1) {
          if (allFavorites[i]['category'] != allFavorites[i + 1]['category']) {
            end = i + 1;
            finalFavorites.add(allFavorites.sublist(start, end));
            start = end;
          }
        } else {
          finalFavorites.add(allFavorites.sublist(end, allFavorites.length));
        }
      }

      for (List<Map<String, dynamic>> favoriteList in finalFavorites) {
        Widget thisFuture = FutureBuilder(
          builder: (context, productSnap) {
            if (productSnap.connectionState == ConnectionState.none &&
                productSnap.hasData == null) {
              return Container();
            } else if (productSnap.hasData) {
//                  print("hasData");
              return Container(
                width: MediaQuery.of(context).size.width,
                child: productSnap.data,
              );
            }

            return Container(
              width: 100,
              height: 100,
              margin: EdgeInsets.only(bottom: 50),
              child: _showOverlay(context),
            );
          },
          future: getFavoritedProducts(favoriteList),
        );
        columnChildren.add(thisFuture);
      }
    }

    columnChildren.add(generateDummyListItem(60));

    bool isFavoritesEmpty = false;

    if (columnChildren.length == 1) {
      columnChildren.removeAt(0);
      isFavoritesEmpty = true;
    }

    ListView createdLists = new ListView(
      controller: null,
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: columnChildren,
    );

    return Container(
      height: 500,
      width: MediaQuery.of(context).size.width,
      child: isFavoritesEmpty
          ? Center(
              child: Text('Nenhum item disponível neste momento.',
                  textAlign: TextAlign.center, style: noneItemText))
          : createdLists,
    );
  }

  profileTab(BuildContext context) {
    List<Widget> profileWidgetLists = <Widget>[];

    profileWidgetLists.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        sectionHeader('Meu Perfil', onViewMore: () {}),
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: (() {
                FirebaseAuth.instance.signOut();

                checkRegisterComplete();

                  user = null;
                  thisUser = new Map();

              }),
              child: Text(
                'Sair >>',
                textAlign: TextAlign.center,
                style: h6,
              ),
            ),
          ),
        ),
      ],
    ));

    if (user != null && thisUser != null) {
      retrieveUser();

      profileWidgetLists.add(Padding(
        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
        child: Align(
          alignment: Alignment.center,
          child: Container(
            width: 140.0,
            height: 140.0,
            padding: const EdgeInsets.all(8.0),
            // borde width
            decoration: new BoxDecoration(
              color: Colors.white, // border color
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: thisUser['imgUrl'] != null
                  ? NetworkImage(thisUser['imgUrl'])
                  : AssetImage('images/avatar.png'),
            ),
          ),
        ),
      ));

      profileWidgetLists.add(Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 40, bottom: 10),
            child: Container(
              height: 40,
              child: Material(
                elevation: 0,
                color: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(0.0),
                        topRight: Radius.circular(30.0))),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 5, top: 0, bottom: 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: thisUser['name'] != null
                          ? AutoSizeText(
                              thisUser['name'],
                              style: h8,
                              maxLines: 1,
                            )
                          : Container()),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40, bottom: 10),
            child: Container(
              height: 40,
              child: Material(
                elevation: 0,
                color: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(0.0),
                        topRight: Radius.circular(0.0))),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 5, top: 0, bottom: 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: thisUser['email'] != null
                          ? AutoSizeText(
                              thisUser['email'],
                              style: h8,
                              maxLines: 1,
                            )
                          : Container()),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 40, bottom: 10),
            child: Container(
              height: 40,
              child: Material(
                elevation: 0,
                color: Colors.white.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(0.0),
                        topRight: Radius.circular(0.0))),
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 10, right: 5, top: 0, bottom: 0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: thisUser['phone'] != null
                          ? AutoSizeText(
                              thisUser['phone'],
                              style: h8,
                              maxLines: 1,
                            )
                          : Container()),
                ),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 5, bottom: 10),
                  child: Container(
                    height: 40,
                    child: Material(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(0.0),
                              topRight: Radius.circular(0.0))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 5, top: 0, bottom: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: thisUser['street'] != null
                                ? AutoSizeText(
                                    thisUser['street'],
                                    style: h8,
                                    maxLines: 1,
                                  )
                                : Container()),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: 40, bottom: 10),
                  child: Container(
                    height: 40,
                    child: Material(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(0.0),
                              topRight: Radius.circular(0.0))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 5, top: 0, bottom: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: thisUser['streetNumber'] != null
                                ? AutoSizeText(
                                    thisUser['streetNumber'],
                                    style: h8,
                                    maxLines: 1,
                                  )
                                : Container()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 5, bottom: 10),
                  child: Container(
                    height: 40,
                    child: Material(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(0.0),
                              topRight: Radius.circular(0.0))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 5, top: 0, bottom: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: thisUser['neighborhood'] != null
                                ? AutoSizeText(
                                    thisUser['neighborhood'],
                                    style: h8,
                                    maxLines: 1,
                                  )
                                : Container()),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 40, bottom: 10),
                  child: Container(
                    height: 40,
                    child: Material(
                      elevation: 0,
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(30.0),
                              topRight: Radius.circular(0.0))),
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: 10, right: 5, top: 0, bottom: 0),
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: thisUser['city'] != null
                                ? AutoSizeText(
                                    thisUser['city'],
                                    style: h8,
                                    maxLines: 1,
                                  )
                                : Container()),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ));

      profileWidgetLists.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Stack(
            children: <Widget>[
              Center(child: roundedRectButton("Editar", goBtnGradients, false)),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    autofocus: true,
                    customBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0)),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(globalContext).size.width / 1.2,
                      height: 35.0,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                      padding: EdgeInsets.only(top: 16, bottom: 16),
                    ),
                    onTap: (() async {
//                      final result = await Navigator.pushNamed(
//                          context, '/signup',
//                          arguments: thisUser);

                      final result = await Navigator.push(context,
                        MaterialPageRoute(
                            builder: (context) =>
                            new SignUpMainPage(uri: uri, url: url)),
                      );

                      if (result != "Ok") {
                        checkRegisterComplete();
                      }
                    }),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    } else {
      profileWidgetLists.add(Container(
        height: 500,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
                child: Text('Por favor, faça login para continuar.',
                    textAlign: TextAlign.center, style: noneItemText)),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Stack(
                children: <Widget>[
                  Center(
                      child: roundedRectButton("Login", goBtnGradients, false)),
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        autofocus: true,
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(globalContext).size.width / 1.2,
                          height: 40.0,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                        ),
                        onTap: (() async {
//                          final result =
//                              await Navigator.pushNamed(context, '/signin');

                          final result = await Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) =>
                                new SignInMainPage(uri: uri, url: url)),
                          );

//                          print("Restult 5 = "+result);

                          if (result == "Ok") {
                            checkRegisterComplete();
                          }

                        }),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ));
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: profileWidgetLists,
    );
  }

  buildOrdersTab(BuildContext context) {
    List<Widget> ordersWidgetLists = <Widget>[];
    ordersWidgetLists.add(sectionHeader('Meus Pedidos', onViewMore: () {}));
    ordersWidgetLists.add(buildOrdersLists());

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: ordersWidgetLists,
    );
  }

  Widget buildOrdersLists() {
    List<Widget> columnChildren = new List();

    if (user != null && all_orders_obj_list != null) {
      for (Order order in all_orders_obj_list) {
        Widget thisOrder = Container(
          margin: EdgeInsets.only(left: 5, bottom: 10, right: 5),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Color(0xfffff2ca).withOpacity(0.5),
              border:
                  Border.all(width: 1.0, color: Colors.black.withOpacity(0.4)),
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          child: getOrderItemContainer(context, order),
        );
        columnChildren.add(thisOrder);
      }
    }

    columnChildren.add(generateDummyListItem(60));

    bool isOrdersListEmpty = false;

    if (columnChildren.length == 1) {
      columnChildren.removeAt(0);
      isOrdersListEmpty = true;
    }

    ListView createdLists = new ListView(
      controller: null,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      scrollDirection: Axis.vertical,
      children: columnChildren,
    );

    return all_orders_obj_list.length == 0
        ? Center(
            child: Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.35),
            child: Text('Nenhum item disponível neste momento.',
                textAlign: TextAlign.center, style: noneItemText),
          ))
        : createdLists;
  }

  getOrderItemContainer(BuildContext context, Order order) {
    List<Widget> columnChildren = new List();
    List<Widget> listViewChildren = new List();
    List<Widget> listViewChildrenColumn = new List();

    listViewChildren.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: AutoSizeText(formatDateTime(order.dateTime),
              style: majorFoodNameText),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 5.0),
          child: AutoSizeText("Total: R\$ " + order.total.replaceAll(".", ","),
              style: majorFoodNameText, overflow: TextOverflow.ellipsis),
        )
      ],
    ));

    var addressSplit = order.deliveryAddress.split('-');

    listViewChildren.add(Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0),
              child: AutoSizeText(
                  "Pagamento: " +
                      (order.payment_method == "money" ? "Dinheiro" : "Cartão"),
                  style: minorCartItemObservationsText),
            ),
          ],
        ),
        Divider(
          height: 5,
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 5.0, top: 5.0),
              child: AutoSizeText(
                  "Entrega: " +
                      (order.delivery == "delivery" ? "Delivery" : "Retirada"),
                  style: minorCartItemObservationsText),
            ),
          ],
        ),
        order.delivery == "delivery"
            ? Row(
                children: <Widget>[
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: AutoSizeText("Endereço: " + addressSplit[0],
                          style: minorCartItemObservationsText,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              )
            : Container(),
        order.delivery == "delivery"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0, left: 5.0),
                      child: AutoSizeText(
                          addressSplit[1] + " - " + addressSplit[2],
                          style: minorCartItemObservationsText,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
              )
            : Container(),
        Divider(
          height: 5,
        ),
      ],
    ));

    order.products_id.forEach((item) {
      columnChildren = new List();
      columnChildren.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: AutoSizeText(item['product_description'],
                    style: minorFoodNameText, overflow: TextOverflow.ellipsis),
              ),
              (item['pizza_edge_id'] != null && item['pizza_edge_id'] != "null")
                  ? Text("Borda: " + item['pizza_edge_description'],
                      style: minorPizzaEdgeText,
                      overflow: TextOverflow.ellipsis)
                  : Container(),
              Text(
                  item["quantity"] +
                      "X " +
                      ((item["size"] != "null" &&
                              item["size"] != null &&
                              item["size"] != "" &&
                              item["size"] != "None")
                          ? item["size"]
                          : ""),
                  style: minorCartItemText),
              Text("R\$ " + item["paid_price"].replaceAll(".", ","),
                  style: minorCartItemText),
            ],
          ),
        ],
      ));

      if (item['notes'] != null &&
          item['notes'] != "" &&
          item['notes'] != "None") {
        columnChildren.add(Container(
          margin: EdgeInsets.only(top: 5, right: 4, bottom: 2),
          child: Text(
            item['notes'],
            style: minorCartItemObservationsText,
            textAlign: TextAlign.justify,
          ),
        ));
      }

      String paid_price = "0.00";

      if (item["paid_price"] != null && item["paid_price"] != "None") {
        paid_price = item["paid_price"];
      }

      columnChildren.add(Container(
        child: Text(
            "Subtotal: R\$ " +
                (double.parse(paid_price) * int.parse(item["quantity"]))
                    .toStringAsFixed(2)
                    .replaceAll(".", ","),
            style: minorCartItemText),
      ));

      listViewChildren.add(Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Card(
              color: Color(0xfffff2ca).withOpacity(0.65),
              elevation: 5,
              child: Row(
                children: <Widget>[
                  Container(
                    //quadrado branco fictício do conjunto imagem
                    width: 50,
                    height: 50,
                    margin: EdgeInsets.only(right: 2),
                    child: Stack(
                      // para fazer a sombra
                      children: <Widget>[
                        Container(
                            //quadrado branco da imagem para fazer a sombra
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            decoration: new BoxDecoration(
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.6),
                                    offset: Offset(1.0, 6.0),
                                    blurRadius: 15.0,
                                  ),
                                ],
                                color: Colors.white,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(5.0))),
                            child: ClipRRect(
                              borderRadius: new BorderRadius.circular(8.0),
                              child: Image.network(
                                item['product_image_url'],
                                fit: BoxFit.contain,
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: columnChildren,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    });

    listViewChildren.add(froyoFlatBtn('Adicionar tudo ao carrinho', () async {
      Map<String, dynamic> cartRow = {
        DatabaseHelper.columnUserId: user.uid,
        DatabaseHelper.columnDateRegister: new DateTime.now().toUtc().toString()
      };

      int cartId;
      Map<String, dynamic> cart = await dbHelper.searchCart(user.uid);
      if (cart == null) {
        //se não tem carrinho
        cartId = await dbHelper.insert(cartRow, "cart");
//        print("Não tem carrinho");
      } else {
        //se já tem carrinho
        cartId = cart['cartId'];
//        print("Já tem carrinho");
      }

      List<Map<String, dynamic>> allCartItems =
          await dbHelper.retrieveAllCartItems(cartId);
//      int equalId = null;
//      print("Entrou: ");
      order.products_id.forEach((orderItem) async {
        int equalId = null;
//        print("OrderItem: "+orderItem.toString());
        allCartItems.forEach((cartItem) {
//          print("CartItem:"+cartItem['productId'].toString()+", "+cartItem['pizzaEdgeId'].toString()+", "+cartItem['productSize'].toString());
//          print("OrderItem:"+orderItem['product_id'].toString()+", "+orderItem['pizza_edge_id'].toString()+", "+orderItem['size'].toString());
//          print("OrderItem:"+orderItem.toString());

          if (orderItem['pizza_edge_id'].toString() == "None") {
            orderItem['pizza_edge_id'] = "null";
          }

          if (orderItem['size'].toString() == "None") {
            orderItem['size'] = "null";
          }

          if ((cartItem['productId'].toString() ==
                      orderItem['product_id'].toString() ||
                  cartItem['product1Id'].toString() ==
                      orderItem['product_id'].toString()) &&
              cartItem['pizzaEdgeId'].toString() ==
                  orderItem['pizza_edge_id'].toString() &&
              cartItem['productSize'].toString() ==
                  orderItem['size'].toString()) {
            print("product 1 igual");

            if (orderItem['product2_id'].toString() == "None") {
              orderItem['product2_id'] = "null";
            }

            if (cartItem['product1Id'].toString() ==
                    orderItem['product_id'].toString() ||
                cartItem['product1Id'].toString() ==
                    orderItem['product2_id'].toString() ||
                cartItem['productId'].toString() ==
                        orderItem['product2_id'].toString() &&
                    cartItem['product2Id'].toString() ==
                        orderItem['product_id'].toString() ||
                cartItem['product2Id'].toString() ==
                    orderItem['product2_id'].toString()) {
              print("product 2 igual");
              //se já tem item igual
              equalId = cartItem['cartItemsId'];
            } else {
              print("product 2 DIFERENTE");
//              print("CartItem: "+cartItem['productId'].toString()+","+cartItem['product1Id'].toString()+", "+cartItem['product2Id'].toString());
//              print("OrderItem: "+orderItem['product_id'].toString()+","+orderItem['product_id'].toString()+", "+orderItem['product2_id'].toString());
            }
          } else {
            print("product 1 DIFERENTE");
            print("CartItem: " +
                cartItem['productId'].toString() +
                "," +
                cartItem['product1Id'].toString() +
                ", " +
                cartItem['product2Id'].toString());
            print("OrderItem: " +
                orderItem['product_id'].toString() +
                "," +
                orderItem['product_id'].toString() +
                ", " +
                orderItem['product2_id'].toString());
          }
        });

        if (equalId != null) {
//          print("já tem igual");
          //se já tem item igual
          Map<String, dynamic> productRow =
              await dbHelper.searchCartItem(equalId);
          Map<String, dynamic> tempProductRow = new Map();
          tempProductRow.addAll(productRow);
          tempProductRow["productAmount"] = tempProductRow["productAmount"] +
              int.parse(orderItem['quantity']);
          await dbHelper.update(tempProductRow, "cartItems", "cartItemsId");
        } else {
//          print("não tem igual");

//          print("orderItem: "+orderItem.toString());

          //se ainda não tem item igual
          int isTwoFlavoredPizza = 0;

          if (orderItem['product2_id'] != null &&
              orderItem['product2_id'] != "None" && orderItem['product2_id'] != "null") {
            isTwoFlavoredPizza = 1;
          }

          Map<String, dynamic> productRow = {
            DatabaseHelper.columnCartId: cartId,
            DatabaseHelper.columnProductId: orderItem['product_id'],
            DatabaseHelper.columnProduct1Id: orderItem['product_id'],
            DatabaseHelper.columnProduct2Id: orderItem['product2_id'],
            DatabaseHelper.columnProductCategory: orderItem['category'],
            DatabaseHelper.columnCategoryName: orderItem['product1_category'],
            DatabaseHelper.columnProduct2CategoryName:
                orderItem['product2_category'],
            DatabaseHelper.columnProductAmount: orderItem['quantity'],
            DatabaseHelper.columnProductObservations: orderItem['notes'],
            DatabaseHelper.columnPizzaEdgeId: orderItem['pizza_edge_id'],
            DatabaseHelper.columnProductSize: orderItem['size'],
            DatabaseHelper.columnIsTwoFlavoredPizza: isTwoFlavoredPizza
          };

          await dbHelper.insert(productRow, "cartItems");

//        print(orderItem);

        }
      });
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                new CartPage(dbHelper: dbHelper, thisUser: thisUser, uri: uri, url: url)),
      );

      if (result.toString() == "Ok") {
        retrieveAllOrders(user.uid, update: true);
      }

//      bottomBarView.createState();
      setBottombarView();

//          retrieveAllOrders(user.uid, update: true);

      print("Retorno do CartPage: " + result.toString());
    }));

    return Container(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: listViewChildren,
      ),
    );
  }

  Dialog showLoadingDialog() {
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: Builder(builder: (context) {
              return Material(
                  color: Colors.transparent,
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          height: 100.0,
                          width: 100.0,
                          child: Image.asset(
                            'images/loading_pizza_faster.gif',
                            fit: BoxFit.scaleDown,
                          ))));
            }),
          );
        },
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: const Duration(milliseconds: 150));
    return retorno;
  }

  Dialog showRegisterDialog(Map<String, dynamic> thisUser) {
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: Builder(builder: (context) {
              return WillPopScope(
                onWillPop: () {},
                child: Material(
                    color: Colors.transparent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: Container(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      "Cadastro Incompleto",
                                      style: h2,
                                    ),
                                  ),
                                  color: Colors.amber,
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Por favor, complete seu cadastro.",
                                    style: h6,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: froyoFlatBtn("Ok", () async {
//                                  final result =
//                                      await Navigator.pushReplacementNamed(
//                                          context, '/signup',
//                                          arguments: thisUser);

                                  final result = await Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        new SignUpMainPage(uri: uri, url: url)),
                                  );

//                                  print("dialog result ="+result.toString());

                                  if (result != "Ok") {
                                    checkRegisterComplete();
                                  }
                                }),
                              ),
                            ],
                          ),
                        ))),
              );
            }),
          );
        },
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: const Duration(milliseconds: 150));
    return retorno;
  }

  String formatDateTime(String dateTime) {
    var newDateTime = DateTime.parse(dateTime);
    var formatter = new DateFormat('dd\/MM\/yyyy');
    String formatted = formatter.format(newDateTime);
    return formatted;
  }

  void showSnackbarError() {
    if (!isSnackbarVisible) {
      isSnackbarVisible = true;
      Scaffold.of(globalScaffoldContext)
          .showSnackBar(SnackBar(
            content: Container(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Column(
                children: <Widget>[
                  Text(
                    "Erro de conexão.",
                    textAlign: TextAlign.center,
                    style: h6Snackbar,
                  ),
                  Text(
                    "Por favor, tente novamente mais tarde.",
                    textAlign: TextAlign.justify,
                    style: h5Snackbar,
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ))
          .closed
          .then((reason) {
        isSnackbarVisible = false;
      });
    }
  }

  Future<void> checkRegisterComplete() async {

//    print("entrou checkRegisterComplete");

    dbHelper = DatabaseHelper.instance;
    user = await fbAuth.currentUser();
    setBottombarView();

    if (user != null) {
//      print("checkRegisterComplete user!=null: " + user.uid);
      //isRegisterComplete
      Map<String, dynamic> localThisUser = await dbHelper.searchUser(user.uid);
//      print("thisuser="+thisUser['isRegComplete'].toString());

      if (localThisUser != null) {
//        print("isRegComplete="+thisUser['isRegComplete'].toString());
        if (localThisUser['isRegComplete'] == 0) {
//          print("isRegComplete="+thisUser['isRegComplete'].toString());
          showRegisterDialog(localThisUser);
        } else {
//          print(localThisUser.toString());
        retrieveUser();
          setState(() {
            thisUser = thisUser;
          });
//          print("isRegComplete="+thisUser['isRegComplete'].toString());
        }
      }
    } else {
//      print("checkRegisterComplete user==null");
    }
  }

  Future<void> retrieveUser() async {
    var queryParameters = {
      'uid': user.uid,
    };

    var thisUri = Uri.https(
        uri, 'list_users', queryParameters);

    try {
      Response response = await get(thisUri);
      // sample info available in response
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];

//      print(response.body);

      if (response.statusCode == 200) {
        dynamic existentUser = json.decode(response.body);

        if (existentUser != null) {
//          print("já existe");

          thisUser = {
            DatabaseHelper.columnUID: user.uid,
            DatabaseHelper.columnUserName: existentUser['name'],
            DatabaseHelper.columnUserEmail: existentUser['email'],
            DatabaseHelper.columnUserImgUrl: existentUser['image_url'],
            DatabaseHelper.columnUserPhone: existentUser['phone'],
            DatabaseHelper.columnUserStreet: existentUser['street'],
            DatabaseHelper.columnUserStreetNumber: existentUser['streetNumber'],
            DatabaseHelper.columnUserNeighborhood: existentUser['neighborhood'],
            DatabaseHelper.columnUserCity: existentUser['city'],
            DatabaseHelper.columnIsRegComplete:
                existentUser['isRegisterComplete']
          };
        } else {
          thisUser = new Map();
        }
//        all_products_obj_list = new List();
//
//        all_products_obj_list.add(Product.fromJson(allProducts));
//
//        return Product.fromJson(allProducts);
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print("Aqui listUsers erro: " + e.toString());
    }
  }

  Widget showUpdateWindow({bool finished}) {
    return Align(
        alignment: finished != null
            ? (finished ? Alignment.topCenter : Alignment.center)
            : Alignment.center,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: new BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: new BorderRadius.all(new Radius.circular(10.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: Container(
                  height: 50,
                  child: Center(
                    child: Text(
                      "Erro de conexão",
                      style: h2,
                    ),
                  ),
                  color: Colors.redAccent,
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Por favor, atualize ou tente novamente mais tarde.",
                              style: h5Snackbar,
                              textAlign: TextAlign.justify,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, bottom: 10.0),
                child: froyoFlatBtn("Atualizar", () async {
                  dioErrorCount = 0;
                  setState(() {
                    isErrorShown = false;
                    futureCategories = getCategories();
                    futureProducts = getProducts(_selectedCategoryName);
                  });
                }),
              ),
            ],
          ),
        ));
  }

  void setBottombarView() {
//    print("entrou setBottombarView");
//    setState(() {
//
//      bottomBarView = null;
//    });

    setState(() {
      bottomBarView = null;
      bottomBarView = BottomBarView(
        tabIconsList: tabIconsList,
        dbHelper: dbHelper,
        user: user,
        addClick: () async {
//            print("clicou no carrinho");
          bool isLogged = await checkIfUserIsLoggedIn();
          if (isLogged) {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      new CartPage(dbHelper: dbHelper, thisUser: thisUser, uri: uri, url: url)),
            );

            if (result.toString() == "Ok") {
              setState(() {
                bottomBarView.changeIndex(2);
              });
              retrieveAllOrders(user.uid, update: true);
            }

//            bottomBarView.createState();
            setBottombarView();

//              retrieveAllOrders(user.uid, update: true);

//              print("Resultado: " + result.toString());
          } else {
//            final result = await Navigator.pushNamed(context, '/signin');
            final result = await Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                  new SignInMainPage(uri: uri, url: url)),
            );

//              print("1 Result=" + result);

            if (result == "Ok") {
              checkRegisterComplete();
            }
          }
        },
        changeIndex: (index) async {
          if (index != 0) {
            bool isLogged = await checkIfUserIsLoggedIn();
            if (!isLogged) {
//              final result = await Navigator.pushNamed(context, '/signin');
              final result = await Navigator.push(context,
                MaterialPageRoute(
                    builder: (context) =>
                    new SignInMainPage(uri: uri, url: url)),
              );
//                print(" 2 Result=" + result);

              if (result == "Ok") {
//                  print("result==Ok");
                checkRegisterComplete();
              } else {
//                  print("result!=Ok");
              }
            }
          }

          if (index == 0 || index == 2) {
//            print("entrou: index="+index.toString());
            animationController.reverse().then((data) {
              if (!mounted) {
                return;
              }
//              print("entrou: passou o return");
              setState(() {
                _selectedIndex = index;
              });

              if (index == 0) {
                setState(() {
                  futureCategories = getCategories();
                  futureProducts = getProducts(_selectedCategoryName);
                });
              }

              if (index == 2) {
                if (user != null) {
                  retrieveAllOrders(user.uid, update: true);
                }
              }
            });
          } else if (index == 1 || index == 3) {
            animationController.reverse().then((data) {
              if (index == 3) {
//                  FirebaseAuth.instance.signOut();
//                  user = null;
              }

              if (!mounted) return;
              setState(() {
                _selectedIndex = index;
              });
            });
          }
        },
      );
    });
  }

  void checkWebserviceSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();

    uri = prefs.getString('webservice.uri');
    url = prefs.getString('webservice.url');

    if (uri == null && url == null) {
//      print("SharedPreferences nulas");
      _collection.document('webservice_address').get().then((DocumentSnapshot ds) {
//        print("SharedPreferences leu os documents");
        // use ds as a snapshot

        setState(() {
          uri = ds.data["uri"];
          url = ds.data["url"];
        });

        prefs.setString('webservice.uri', uri);
        prefs.setString('webservice.url', url);

        futureCategories = getCategories();
        futureProducts = getProducts(_selectedCategoryName);

        if(user!=null){
          retrieveAllOrders(user.uid);
        }

      });
    }else{

//      print("SharedPreferences NÃO nulas");

      futureCategories = getCategories();
      futureProducts = getProducts(_selectedCategoryName);

      if(user!=null){
        retrieveAllOrders(user.uid);
      }
    }
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
  return Builder(builder: (BuildContext mContext) {
    return Padding(
      padding: EdgeInsets.only(bottom: 30),
      child: Stack(
        alignment: Alignment(1.0, 0.0),
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            width: MediaQuery.of(mContext).size.width / 1.2,
            height: 35,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
              gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
            ),
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 0, bottom: 0),
          ),
        ],
      ),
    );
  });
}

const List<Color> goBtnGradients = [
  Color(0xFF643621),
  Color(0xFF391d11),
];
