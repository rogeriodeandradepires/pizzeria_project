import 'dart:convert';

import 'package:dom_marino_app/src/bottomNavigationView/bottomBarView.dart';
import 'package:dom_marino_app/src/models/category_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/models/tabIconData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/fryo_icons.dart';
import './ProductPage.dart';
import '../shared/ProductOld.dart';
import '../shared/partials.dart';
import 'package:http/http.dart';
import 'package:dom_marino_app/src/shared/database_helper.dart';

List<Category> all_categories_obj_list = new List();
List<Product> all_products_obj_list = new List();

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
  ScrollController _controller;
  final dbHelper = DatabaseHelper.instance;
  List<Map<String, dynamic>> allFavorites;
  FirebaseUser user;
  FirebaseAuth fbAuth = FirebaseAuth.instance;

  Widget tabBody = new Container(
    decoration: new BoxDecoration(
      image: new DecorationImage(
        image: new AssetImage("images/main_bg.png"),
        fit: BoxFit.cover,
      ),
    ),
  );

  @override
  void initState() {
    fbAuth.onAuthStateChanged.listen((newUser) {
      setState(() {
        user = newUser;
      });
    });

    retrieveAllFavorites(null);

    _controller = ScrollController();

    tabIconsList.forEach((tab) {
      tab.isSelected = false;
    });
    tabIconsList[0].isSelected = true;

    animationController =
        AnimationController(duration: Duration(milliseconds: 600), vsync: this);
    super.initState();
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => getProducts());
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _tabs = [
      storeTab(context),
      favoritesTab(context),
      Text('Tab3'),
      Text('Tab4'),
      Text('Tab5'),
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
              fit: BoxFit.cover,
              height: 40.0,
            ),
//              Container(
//                  padding: const EdgeInsets.all(8.0),
//              )
          ],
        ),
//              Text('Fryo', style: logoWhiteStyle, textAlign: TextAlign.center),
        actions: <Widget>[
//          IconButton(
//            padding: EdgeInsets.all(0),
//            onPressed: () {},
//            iconSize: 21,
//            icon: Icon(Fryo.magnifier),
//          ),
          IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {},
            iconSize: 21,
            icon: Icon(Fryo.location),
          )
        ],
      ),
      body: new Stack(
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
      ),
    );
  }

  Widget bottomBar() {
    return Column(
      children: <Widget>[
        Expanded(
          child: SizedBox(),
        ),
        BottomBarView(
          tabIconsList: tabIconsList,
          addClick: () {
            print("clicou no carrinho");
            //WHRS
          },
          changeIndex: (index) async {
//
            if (index != 0) {
              bool isLogged = await checkIfUserIsLoggedIn();
              if (!isLogged) {
                Navigator.pushNamed(context, '/signin');
              }
            }

            if (index == 0 || index == 2) {
              animationController.reverse().then((data) {
                if (!mounted) return;
                setState(() {
                  _selectedIndex = index;
//                  tabBody =
//                      MyDiaryScreen(animationController: animationController);
                });
              });
            } else if (index == 1 || index == 3) {
              animationController.reverse().then((data) {
                if (index == 3) {
                  FirebaseAuth.instance.signOut();
                  user = null;
                }

                if (!mounted) return;
                setState(() {
                  _selectedIndex = index;
//                  tabBody =
//                      MyDiaryScreen(animationController: animationController);
                });
              });
            }
          },
        ),
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

            await dbHelper.update(row);
            await retrieveAllFavorites(user.uid);

            setState(() {
              retrievedProduct.userLiked = false;
              thisList.remove(thisItem);
            });
          } //se é favorito

        } else {
          //não está logado
          Navigator.pushNamed(context, '/signin');
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

    String url = 'https://dom-marino-webservice.appspot.com/list_' + category;
    var uri = Uri.https(
        'dom-marino-webservice.appspot.com', 'list_$category', queryParameters);
//    print(url);

    Response response = await get(uri);
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
  }

  Future getProducts(String category) async {
//    String category = _selectedCategoryName;
    String url = 'https://dom-marino-webservice.appspot.com/list_' + category;
//    print(url);

    Response response = await get(url);
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
      return a.description.toLowerCase().compareTo(b.description.toLowerCase());
    });

    return all_products_obj_list;
  }

  Future getCategories() async {
    String url = 'https://dom-marino-webservice.appspot.com/list_categories';
    Response response = await get(url);
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    dynamic all_categories = json.decode(response.body);

    if (response.statusCode == 200) {
      all_categories_obj_list = new List();
      all_categories.forEach((category) {
        all_categories_obj_list.add(Category.fromJson(category));
//        print(category);
      });
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load category');
    }

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
    }

//    getProducts();

    return all_categories_obj_list;
  }

  Widget storeTab(BuildContext context) {
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          headerTopCategories('Todas as Categorias'),
          deals(_selectedCategory, onViewMore: () {}, items: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder(
                builder: (context, productSnap) {
                  if (productSnap.connectionState == ConnectionState.none &&
                      productSnap.hasData == null) {
                    //print('product snapshot data is: ${productSnap.data}');
                    return Container();
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

                                  await dbHelper.insert(row);

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

                                    await dbHelper.update(row);

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

                                    await dbHelper.update(row);

                                    setState(() {
                                      product.userLiked = true;
                                    });
                                  }
                                } //else se ainda não é favorito
                              } //else se o favorito está no db

                              retrieveAllFavorites(user.uid);
                            } else {
                              //não está logado
                              Navigator.pushNamed(context, '/signin');
                            }
                          }); //onLike
                        } else {
                          //se é o ultimo item da lista de produtos
                          return generateDummyListItem(320);
                        }
                      },
                    );

                    return globalProductsListView;
                  }

                  return Container(
                    margin: EdgeInsets.only(left: 110, right: 110, bottom: 300),
                    child: _showOverlay(context),
                  );
                },
                future: getProducts(_selectedCategoryName),
              ),
            )
          ]),
        ]);
  }

  Widget favoritesTab(BuildContext context) {
    List<Widget> favoritesWidgetLists = <Widget>[];
    favoritesWidgetLists.add(sectionHeader('Favoritos', onViewMore: () {}));
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
                  return Container();
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
                        }
                      }
                      return headerCategoryItem(
                          category.description, category.icon, onPressed: () {
                        setState(() {
                          globalProductsListView.controller.jumpTo(0);
                          _selectedCategory = category.description;
                          _selectedCategoryName = category.name;
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
              future: getCategories(),
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

//    print(isLogged ? user.uid : null);
    return isLogged;
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
//                print("builder");
//                print(productSnap);
            if (productSnap.connectionState == ConnectionState.none &&
                productSnap.hasData == null) {
//                  print("null");
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

//    Column createdLists = new Column(
//        mainAxisAlignment: MainAxisAlignment.center,
//        crossAxisAlignment: CrossAxisAlignment.center,
//        mainAxisSize: MainAxisSize.min,
//        children: columnChildren);

    columnChildren.add(generateDummyListItem(60));

    bool isFavoritesEmpty = false;

    if (columnChildren.length==1) {
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
      child: isFavoritesEmpty ? Center(child: Text('Nenhum item disponível neste momento.', textAlign: TextAlign.center,style: noneItemText)) : createdLists,
    );
  }

//  List<Widget> buildFavoritesLists() {
//    List<FutureBuilder> thisList = new List();
//
//    List<Widget> favoritesWidgetLists = <Widget>[];
//
//    if (user != null && allFavorites != null) {
//      retrieveAllFavorites(user.uid);
//      List<Map<String, dynamic>> orderedFavorites = new List();
//      orderedFavorites.addAll(allFavorites);
//      List<List<Map<String, dynamic>>> finalFavorites = new List();
//      orderedFavorites.sort((a, b) => a['category'].compareTo(b['category']));
//      int start = 0, end = 0;
//
//      for (int i = 0; i < orderedFavorites.length; i++) {
//        if (i != orderedFavorites.length - 1) {
//          if (orderedFavorites[i]['category'] !=
//              orderedFavorites[i + 1]['category']) {
//            end = i + 1;
//            finalFavorites.add(orderedFavorites.sublist(start, end));
//            start = end;
//          }
//        } else {
//          finalFavorites
//              .add(orderedFavorites.sublist(end, orderedFavorites.length));
//        }
//      }
//
//      for (List<Map<String, dynamic>> favoriteList in finalFavorites) {
////        Map<String, dynamic> section = favoriteList[0];
////        sectionHeader(section['category']);
//        FutureBuilder thisFuture = FutureBuilder(
//          builder: (context, productSnap) {
//            print("builder");
//            print(productSnap);
//            if (productSnap.connectionState == ConnectionState.none &&
//                productSnap.hasData == null) {
//              print("null");
//              return Container();
//            } else if (productSnap.hasData) {
//              print("hasData");
//              return ListView.builder(
//                scrollDirection: Axis.horizontal,
//                shrinkWrap: true,
//                itemCount: favoriteList.length,
//                itemBuilder: (context, index) {
//                  Product product = productSnap.data[index];
//                  return productSnap.data[index];//foodItem(context, product);
//                },
//              );
//            } else {
//              print("outro");
//              return Container();
//            }
//          },
//          future: getFavoritedProducts(favoriteList),
//        );
//        thisList.add(thisFuture);
//      }
//    }
//
//    return thisList;
//  }
}
