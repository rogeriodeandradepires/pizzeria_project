import 'dart:convert';

import 'package:dom_marino_app/src/bottomNavigationView/bottomBarView.dart';
import 'package:dom_marino_app/src/models/category_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/models/tabIconData.dart';
import 'package:flutter/material.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/fryo_icons.dart';
import './ProductPage.dart';
import '../shared/ProductOld.dart';
import '../shared/partials.dart';
import 'package:http/http.dart';

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
  var _selectedCategory = "";
  var _selectedCategoryName = "";
  AnimationController animationController;
  List<TabIconData> tabIconsList = TabIconData.tabIconsList;
  ListView globalProductsListView;
  ScrollController _controller;

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
      Text('Tab2'),
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
          changeIndex: (index) {

            if(index == 1){
              Navigator.pushNamed(context, '/signin');
            }

            if(index == 2){
              Navigator.pushNamed(context, '/signup');
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

  Future getProducts() async {
    String category = _selectedCategoryName;
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

    all_categories_obj_list = all_categories_obj_list.reversed.toList();

    if (_selectedCategory=="") {
      setState(() {
        _selectedCategory = all_categories_obj_list.elementAt(0).description;
        _selectedCategoryName = all_categories_obj_list.elementAt(0).name;
      });
    }

//    getProducts();

    return all_categories_obj_list;
  }

  Widget storeTab(BuildContext context) {
    // will pick it up from here
    // am to start another template
    List<ProductOld> foods = [
      ProductOld(
          name: "Hamburger",
          image: "images/3.png",
          price: "\$25.00",
          ingredients: "",
          userLiked: true,
          discount: null),
      ProductOld(
          name: "Pasta",
          image: "images/5.png",
          price: "\$150.00",
          ingredients: "",
          userLiked: false,
          discount: null),
      ProductOld(
        name: "Akara",
        image: 'images/2.png',
        price: '\$10.99',
        ingredients: "",
        userLiked: false,
      ),
      ProductOld(
          name: "Strawberry",
          image: "images/1.png",
          price: '\$50.00',
          ingredients: "",
          userLiked: true,
          discount: null)
    ];

    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          headerTopCategories(),
          deals(_selectedCategory, onViewMore: () {}, items: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              child: FutureBuilder(
                builder: (context, productSnap) {
                  if (productSnap.connectionState == ConnectionState.none &&
                      productSnap.hasData == null) {
                    //print('product snapshot data is: ${productSnap.data}');
                    return Container();
                  }

                  globalProductsListView = ListView.builder(
                    controller: _controller,
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount:
                    productSnap.data != null ? productSnap.data.length+1 : 0,
                    itemBuilder: (context, index) {
                      Product product;

                      if (index<productSnap.data.length) {
                        product = productSnap.data[index];

                        return foodItem(context, product, onTapped: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return new ProductPage(
                                  productData: product,
                                );
                              },
                            ),
                          );
                        }, onLike: () {});
                      }else{
                        return generateDummyListItem();
                      }

                    },
                  );

                  return globalProductsListView;
                },
                future: getProducts(),
              ),
            )
          ]),
        ]);
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
  Widget headerTopCategories() {
//  List<Widget> all_header_categories = new List();
    List<Widget> all_header_categories = [];

//    all_categories_obj_list.forEach((category) {
//      all_header_categories.add(
//          headerCategoryItem(category.title, Fryo.dinner, onPressed: () {}));
////    print(category.title);
//    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        sectionHeader('Todas as Categorias', onViewMore: () {}),
        SizedBox(
            height: 100,
            child: FutureBuilder(
              builder: (context, categorySnap) {
                if (categorySnap.connectionState == ConnectionState.none &&
                    categorySnap.hasData == null) {
                  //print('category snapshot data is: ${categorySnap.data}');
                  return Container();
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount:
                  categorySnap.data != null ? categorySnap.data.length : 0,
                  itemBuilder: (context, index) {
                    Category category = categorySnap.data[index];
                    if (index == 0) {
                      if (_selectedCategory=="") {
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

  Widget generateDummyListItem() {
    return new SizedBox(
      height: 320,
      child: Container(
//        color: Colors.red,
      ),
    );
  }
}