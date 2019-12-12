import 'dart:convert';

import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/screens/Dashboard.dart';
import 'package:dom_marino_app/src/shared/colors.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ChoosePizzaDialog extends StatefulWidget {
  final String title, description, buttonText;
  final Image image;
  final Product returnedProduct;

  final ValueChanged<Product> onReturnedProductChanged;

  ChoosePizzaDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    @required this.returnedProduct,
    this.image, this.onReturnedProductChanged,
  });

  @override
  _ChoosePizzaDialogState createState() => _ChoosePizzaDialogState();

}

class _ChoosePizzaDialogState extends State<ChoosePizzaDialog>  with TickerProviderStateMixin {
  ListView globalProductsListView;

  Product productToReturn;

  ScrollController _controller;
  TabController _tabController;

  @override
  void initState(){
    _controller = ScrollController();
    _tabController = new TabController(length: 3, vsync: this);

    productToReturn = widget.returnedProduct;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height,
      margin: EdgeInsets.only(top: 10),
      decoration: new BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: const Offset(0.0, 10.0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(8.0),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text("Escolha um Sabor"),
              bottom: TabBar(
                tabs: [
                  Tab(icon: Image.network("https://storage.googleapis.com/dom-marino-ws.appspot.com/categories/traditional_pizzas/pizza.png", height: 20, width: 20)),
                  Tab(icon: Image.network("https://storage.googleapis.com/dom-marino-ws.appspot.com/categories/gourmet_pizzas/gourmet_pizza.png", height: 20, width: 20)),
                  Tab(icon: Image.network("https://storage.googleapis.com/dom-marino-ws.appspot.com/categories/candy_pizzas/candy_pizza.png", height: 20, width: 20)),
                ],
                controller: _tabController,
              ),
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
                TabBarView(
                  children: [
                    choosePizzaFlavorCategoryList("Pizzas Tradicionais", "traditional_pizzas", context),
                    choosePizzaFlavorCategoryList("Pizzas Gourmet", "gourmet_pizzas", context),
                    choosePizzaFlavorCategoryList("Pizzas Doces", "candy_pizzas", context),
//                    new Text("Pizzas Doces"),
//                    new Text("Pizzas Gourmet"),
//                    new Text("Pizzas Tradicionais"),
                  ],
                  controller: _tabController,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget choosePizzaFlavorCategoryList(String title, String selectedCategory, BuildContext context) {
    return ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          deals(title, onViewMore: () {}, items: <Widget>[
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
                          product = productSnap.data[index];
                          return foodItem(context, product, onTapped: () {
                            print(product.id);
                            product.categoryName = selectedCategory;
                            productToReturn = product;
                            widget.onReturnedProductChanged(productToReturn);
                            Navigator.of(context, rootNavigator: true).pop();
                          });
                        } else {
                          return generateDummyListItem();
                        }
                      },
                    );

                    return globalProductsListView;
                  }

                  return Container(
                    margin: EdgeInsets.only(left:110, right:110, bottom:300),
                    child: _showOverlay(context),
                  );

                },
                future: getProducts(selectedCategory),
              ),
            )
          ]),
        ]);
  }

  Future getProducts(String selectedCategory) async {
    String category = selectedCategory;
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

  Widget _showOverlay(BuildContext context) {
//    Navigator.of(context).push(TutorialOverlay());

    return Image.asset(
      'images/loading_pizza_faster.gif',
      fit: BoxFit.scaleDown,
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

  Widget foodItem(BuildContext context, Product product,
      {double imgWidth, onTapped, bool isProductPage = false}) {
    return InkWell(
        onTap: onTapped,
        child: Card(
          color: Color(0xfffff2ca).withOpacity(0.65),
          elevation: 5,
          //Color.fromRGBO(255, 0, 0, 0.5),
          child: getContainer(
              context, imgWidth, product, isProductPage, onTapped),
        ));
  }

  getContainer(BuildContext context,double imgWidth, Product product,
      bool isProductPage, onTapped) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 8.0,
      children: <Widget>[
        Container(
          //quadrado branco fictício do conjunto imagem
          width: 50,
          height: 50,
          child: Stack(
            // para fazer a sombra
            children: <Widget>[
              Container(
                //quadrado branco da imagem para fazer a sombra
                  margin: EdgeInsets.only(left: (!isProductPage) ? 0 : 10),
                  width: 50,
                  height: 50,
                  decoration: new BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: Offset(1.0, 6.0),
                          blurRadius: 5.0,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius:
                      new BorderRadius.all(const Radius.circular(5.0))),
                  child: Hero(
                      transitionOnUserGestures: true,
                      tag: product.description +
                          (product.ingredients != null
                              ? product.ingredients
                              : ""),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(8.0),
                        child: Image.network(
                          product.imageUrl,
                          fit: BoxFit.contain,
                        ),
                      ))),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width/2,
          child: Stack(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(product.description, style: chooseFlavorFoodNameText),
//                  checkIngredients(context, product),
//                  checkNotes(context, product),
//                  checkSizes(context, product),
                  getProductPrice(product),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getProductPrice(Product product) {
    String retorno;
    if (!product.description.contains("Escolha")) {
      if (product.price != null && product.price != "") {
        retorno = "R\$ " + product.price.replaceAll(".", ",");
        return Text(retorno, style: chooseFlavorFoodNotesText);
      }

      if (product.price_broto != null) {
        return generatePricesGrid(product.price_broto, product.price_inteira);
      }
    }else{
      return Text(product.price, style: foodNameText);
    }
  }


  Widget checkSizes(BuildContext context, Product product) {
    var retorno;

    if (product.size != null && product.size != "") {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text(product.size, style: foodIngredientsText),
      );
    } else {
      retorno = Container();
    }

    return retorno;
  }

  Widget checkNotes(BuildContext context, Product product) {
    var retorno;

    if (product.notes != null && product.notes != "") {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text(product.notes, style: chooseFlavorFoodNotesText),
      );
    } else {
      retorno = Container();
    }

    return retorno;
  }

  Widget checkIngredients(BuildContext context, product) {
    var retorno;

    if (product.ingredients != null && product.ingredients != "") {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text(product.ingredients, style: chooseFlavorFoodNotesText),
      );
    } else {
      retorno = Container();
    }

    return retorno;
  }

  Widget generatePricesGrid(String price_broto, String price_inteira) {

    return new Container(
      child: new Row(
        children: <Widget>[
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Text("Broto", style: chooseFlavorFoodNotesText),
                ),
                new Container(
                  child: new Text("R\$ " + price_broto.replaceAll(".", ","),
                      style: chooseFlavorFoodNotesText),
                ),
              ],
            ),
          ),
          Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Text("Inteira", style: chooseFlavorFoodNotesText),
                ),
                new Container(
                  child: new Text("R\$ " + price_inteira.replaceAll(".", ","),
                      style: chooseFlavorFoodNotesText),
                )
              ],
            ),
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