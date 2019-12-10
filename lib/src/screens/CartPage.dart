import 'dart:convert';
import 'dart:math';

import 'package:dom_marino_app/src/BLoC/totalPrice_bloc.dart';
import 'package:dom_marino_app/src/models/cart_item_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';

class CartPage extends StatefulWidget {
  final dbHelper;
  final FirebaseUser user;

  CartPage({Key key, this.dbHelper, this.user}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _quantity = 1;

  Widget firstFlavorChosen;
  Widget secondFlavorChosen;

  Product product1ToReturn;
  Product product2ToReturn;

  String brotoPrice_global;
  String inteiraPrice_global;

  Product global_pizzaEdgeChosen;
  double global_previous_pizzaEdgeBrotoPrice = 0;
  double global_previous_pizzaEdgeinteiraPrice = 0;
  Product global_product;
  String observations;
  bool hasObservations = false;
  String sizePriceSelected = "";
  String totalPrice = "0,00";

  int count = 0;

  List<Map<String, dynamic>> allCartItemsMap = new List();
  List<Map<String, dynamic>> finalAllCartItemsMap = new List();

  int cartId = 0;
  TotalPriceBloc bloc;
  List<String> includedProducts = new List();

  @override
  Future<void> initState() {
    bloc = new TotalPriceBloc();
    retrieveCartId();
  }

  @override
  Widget build(BuildContext context) {
    //página grande do produto
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          centerTitle: true,
          leading: BackButton(
            color: Colors.white,
          ),
          title: Text("Pedido", style: h2),
        ),
        body: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: bloc.totalPriceStream,
                    builder: (context, snapshot) {
                      String total = snapshot.data;

                      if (snapshot.data == null) {
                        total = "0,00";
                      }

                      return Text("R\$ $total", style: cart_title);
                    },
                  ),
                  Text("Preço Total", style: white_h4)
                ],
              ),
            ),
            Container(
              //container de fora
              color: primaryColor,
              margin: EdgeInsets.only(top: 5),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 100),
                      padding: EdgeInsets.only(top: 10, left: 10),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: FutureBuilder(
                        builder: (context, itemsCount) {
                          if (itemsCount == 0) {
                            return Container(
                                height: 500,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                    child: Text(
                                        'Nenhum item disponível neste momento.',
                                        textAlign: TextAlign.center,
                                        style: noneItemText)));
                          } else {
                            return Stack(
                              children: <Widget>[
                                FutureBuilder(
                                  builder: (context, containerSnap) {
                                    if (containerSnap.connectionState ==
                                                ConnectionState.none &&
                                            containerSnap.hasData == null ||
                                        containerSnap.data == null) {
                                      return Container();
                                    } else {
                                      return containerSnap.data;
                                    }
                                  },
                                  future: buildCartItemsList(),
                                ),
//                          Center(child: Text("Items",style: h4)),
                                Positioned(
                                  bottom: -5,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: froyoFlatBtn('Pagar', () {}),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[],
                                )
                              ],
                            );
                          }
                        },
                        future: retrieveAllCartItems(),
                      ),
                      decoration: BoxDecoration(
                          image: new DecorationImage(
                            image: new AssetImage("images/main_bg.png"),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 15,
                                spreadRadius: 5,
                                color: Color.fromRGBO(0, 0, 0, .05))
                          ]),
                    ),
                  ),
//                  Align(
//                    alignment: Alignment.center,
//                    child: SizedBox(
//                      width: 200,
//                      height: 180,
//                      //box de todos os conteudos da imagem na pagina do produto
//                      child: foodItem(context, widget.productData,
//                          isProductPage: true,
//                          onTapped: () {},
//                          imgWidth: 200,
//                          onLike: () {}),
//                    ),
//                  )
                ],
              ),
            )
          ],
        ));
  }

  Future<int> retrieveAllCartItems() async {
////    print("cartId2="+cartId.toString());
    List<Map<String, dynamic>> tempAllCartItems = new List();
    tempAllCartItems.addAll(await widget.dbHelper.retrieveAllCartItems(cartId));
    allCartItemsMap = new List();
    allCartItemsMap.addAll(tempAllCartItems);

//    print(allCartItemsMap.length);
    return allCartItemsMap.length;
  }

  Future<int> retrieveCartId() async {
    Map<String, dynamic> cart =
        await widget.dbHelper.searchCart(widget.user.uid);
    cartId = await cart['cartId'];
//    print("retrieveCart="+cartId.toString());
    retrieveAllCartItems();
    return cart['cartId'];
  }

  Future<Widget> buildCartItemsList() async {
    includedProducts = new List();
    List<Widget> columnChildren = new List();
    columnChildren.add(Text("Items", style: h4));

    allCartItemsMap
        .sort((a, b) => a['productCategory'].compareTo(b['productCategory']));
    allCartItemsMap = allCartItemsMap.reversed.toList();

    finalAllCartItemsMap = new List();
    finalAllCartItemsMap.addAll(allCartItemsMap);

    for (int i = 0; i < finalAllCartItemsMap.length; i++) {
      CartItem tempProduct = CartItem.fromJson(finalAllCartItemsMap[i]);
      tempProduct.productCategory = finalAllCartItemsMap[i]['productCategory'];
//      totalPrice = "0,00";
//
//      bloc.totalPriceSink.add("0,00");

      if (finalAllCartItemsMap[i]['isTwoFlavoredPizza'] == 1) {
      } else {
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
                child: cartItem(context, productSnap.data,
                    size: finalAllCartItemsMap[i]['productSize'],
                    ammount: finalAllCartItemsMap[i],
                    cartItemMap: allCartItemsMap[i]),
              );
            }

            return Container(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: _showOverlay(context),
            );

//            return Container(
//              width: 100,
//              height: 100,
//              margin: EdgeInsets.only(bottom: 50),
//              child: _showOverlay(context),
//            );
          },
          future: getProduct(map: finalAllCartItemsMap[i]),
        );

        columnChildren.add(thisFuture);
      }
    }

    columnChildren.add(generateDummyListItem(60));

//    print("columnChildren=" + columnChildren.length.toString());

    ListView createdLists = new ListView(
      controller: null,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: columnChildren,
    );

    return Container(
      height: 500,
      width: MediaQuery.of(context).size.width,
      child: createdLists,
    );
  }

  Future<Product> getProduct(
      {Map<String, dynamic> map, String id, String category}) async {
    if (map != null) {
      category = map['categoryName'];
      id = map['productId'];
    }

    var queryParameters = {
      'id': '$id',
    };

    var uri = Uri.https(
        'dom-marino-webservice.appspot.com', 'list_$category', queryParameters);

    Response response = await get(uri);
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    dynamic allProducts = json.decode(response.body);

    if (response.statusCode == 200) {
      Product retrievedProduct = Product.fromJson(allProducts);

      if (category == "pizza_edges") {
        retrievedProduct.description = "Borda: " + retrievedProduct.description;
      }

      if (map['productSize'] == null) {
        if (!includedProducts.contains(id)) {
          double tempPrice =
              double.parse(retrievedProduct.price) * map['productAmount'];
          String oldTotalPrice = totalPrice.replaceAll(",", ".");

          totalPrice =
              (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

          bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));

        }
      } else {
        if (!includedProducts.contains(id)) {
          if (map['productSize'] == "Broto") {
            if (retrievedProduct.price_broto != null) {
              double tempPrice = double.parse(retrievedProduct.price_broto) *
                  map['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice =
                  (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

              retrievedProduct.price_broto = tempPrice.toStringAsFixed(2);

              bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));
            }
          } else {
            //se for inteira
            if (retrievedProduct.price_inteira != null) {
              double tempPrice = double.parse(retrievedProduct.price_inteira) *
                  map['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice =
                  (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

              retrievedProduct.price_inteira = tempPrice.toStringAsFixed(2);

              bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));
            }
          }
        }
      }
      includedProducts.add(id);
      return retrievedProduct;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load product');
    }
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

  Widget cartItem(
    BuildContext context,
    Product product, {
    String size,
    Map<String, dynamic> ammount,
    double imgWidth,
    onLike,
    onTapped,
    Map<String, dynamic> cartItemMap,
    bool isProductPage = false,
  }) {
    return Card(
      color: Color(0xfffff2ca).withOpacity(0.65),
      elevation: 5,
      //Color.fromRGBO(255, 0, 0, 0.5),
      child: getCartItemContainer(context, onLike, imgWidth, product,
          isProductPage, onTapped, size, ammount, cartItemMap),
    );
  }

  getCartItemContainer(
      BuildContext context,
      onLike,
      double imgWidth,
      Product product,
      bool isProductPage,
      onTapped,
      String size,
      Map<String, dynamic> ammount,
      Map<String, dynamic> cartItemMap) {
    return Wrap(
      direction: Axis.horizontal,
      spacing: 2.0,
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
                  width: 150,
                  height: 150,
                  decoration: new BoxDecoration(
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          offset: Offset(1.0, 6.0),
                          blurRadius: 15.0,
                        ),
                      ],
                      color: Colors.white,
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(5.0))),
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  )),
            ],
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(product.description, style: minorFoodNameText),
              checkPizzaEdge(cartItemMap),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      size != null
                          ? Text(size, style: minorCartItemText)
                          : Container(),
                      getItemPrice(
                          size,
                          product,
                          finalAllCartItemsMap[finalAllCartItemsMap
                              .indexOf(ammount)]["productAmount"]),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          int index = finalAllCartItemsMap.indexOf(ammount);
                          dynamic value =
                              finalAllCartItemsMap[index]["productAmount"];
                          value = value - 1;
                          Map<String, dynamic> newMap = new Map();
                          newMap.addAll(ammount);
                          newMap["productAmount"] = value;
                          await widget.dbHelper
                              .update(newMap, "cartItems", "cartItemsId");

                          setState(() {
                            retrieveAllCartItems();
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          margin: EdgeInsets.only(right: 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            border: Border.all(color: Colors.grey[500]),
                          ),
                          child: Icon(Icons.remove),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 5, right: 10),
                        child: Text(ammount['productAmount'].toString(),
                            style: h3),
                      ),
                      InkWell(
                        onTap: () async {
                          int index = finalAllCartItemsMap.indexOf(ammount);
                          dynamic value =
                              finalAllCartItemsMap[index]["productAmount"];
                          value = value + 1;
                          Map<String, dynamic> newMap = new Map();
                          newMap.addAll(ammount);
                          newMap["productAmount"] = value;
                          await widget.dbHelper
                              .update(newMap, "cartItems", "cartItemsId");

                          setState(() {
                            retrieveAllCartItems();
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(4.0)),
                            border: Border.all(color: Colors.grey[500]),
                          ),
                          child: Icon(Icons.add),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getItemPrice(String size, Product product, int ammount) {
    double tempPrice;

    Widget retorno;

    if (size == null) {
      if (product.price != null) {
        tempPrice = double.parse(product.price) * ammount;
//        String oldTotalPrice = totalPrice.replaceAll(",", ".");
//
////        print("totalPrice ANTES:"+totalPrice.toString());
//
//        totalPrice =
//            (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

//        print("totalPrice DEPOIS:"+totalPrice.toString());

        product.price = tempPrice.toStringAsFixed(2);

//        bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));

        retorno = Text(
          "R\$ " + product.price.replaceAll(".", ","),
          style: minorCartItemText,
        );
      } else {
        retorno = Text(
          "R\$ --,--",
          style: minorCartItemText,
        );
      }
    } else {
      if (size == "Broto") {
        if (product.price_broto != null) {
          tempPrice = double.parse(product.price_broto) * ammount;
//          String oldTotalPrice = totalPrice.replaceAll(",", ".");
//          totalPrice =
//              (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

          product.price_broto = tempPrice.toStringAsFixed(2);

//          bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));

          return Text(
            "R\$ " + product.price_broto.replaceAll(".", ","),
            style: minorCartItemText,
          );
        } else {
          return Text(
            "R\$ --,--",
            style: minorCartItemText,
          );
        }
      } else {
        if (product.price_inteira != null) {
          tempPrice = double.parse(product.price_inteira) * ammount;
//          String oldTotalPrice = totalPrice.replaceAll(",", ".");
//          totalPrice =
//              (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

          product.price_inteira = tempPrice.toStringAsFixed(2);

//          bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));

          return Text(
            "R\$ " + product.price_inteira.replaceAll(".", ","),
            style: minorCartItemText,
          );
        } else {
          retorno = Text(
            "R\$ --,--",
            style: minorCartItemText,
          );
        }
      }
    }

    return retorno;
  }

  Widget getProductPrice(Product product, String size) {
    String retorno;

    print(size);

    if (size == "Broto") {
      print("Entrou no Broto");
      return Expanded(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              child: new Text("Broto", style: foodNameText),
            ),
            new Container(
              child: new Text("R\$ " + product.price_broto.replaceAll(".", ","),
                  style: foodNameText),
            ),
          ],
        ),
      );
    } else {
      if (size == "Inteira") {
        print("Entrou na Inteira");
        return Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Container(
                child: new Text("Inteira", style: foodNameText),
              ),
              new Container(
                child: new Text(
                    "R\$ " + product.price_inteira.replaceAll(".", ","),
                    style: foodNameText),
              ),
            ],
          ),
        );
      } else {
        print("Entrou em Outro");
        return new Container(
          height: 100,
          width: 100,
          child:
              new Text("R\$ 0,00", // + product.price,//.replaceAll(".", ","),
                  style: foodNameText),
        );
      }
    }

//  if (!product.description.contains("Escolha")) {
//    if (product.price != null && product.price != "") {
//      retorno = "R\$ " + product.price.replaceAll(".", ",");
//      return Text(retorno, style: foodNameText);
//    }
//
//    if (product.price_broto != null) {
//      return generatePricesGrid(product.price_broto, product.price_inteira);
//    }
//  } else {
//    return Text(product.price, style: foodNameText);
//  }
//    return retorno;
  }

  Widget checkPizzaEdge(Map<String, dynamic> cartItemMap) {
    if (cartItemMap['pizzaEdgeId'] == null) {
      return Container(); //Text("", style: minorFoodNameText);
    } else {
      return FutureBuilder(
        builder: (context, productSnap) {
          if (productSnap.connectionState == ConnectionState.none &&
              productSnap.hasData == null) {
            return Container();
          } else if (productSnap.hasData) {
            return Container(
              width: MediaQuery.of(context).size.width,
              child:
                  Text(productSnap.data.description, style: minorPizzaEdgeText),
            );
          }
          return Container();
        },
        future:
            getProduct(id: cartItemMap['pizzaEdgeId'], category: 'pizza_edges'),
      );
    }
  }
}
