import 'dart:convert';
import 'dart:math';

import 'package:dom_marino_app/src/BLoC/allCartItems_bloc.dart';
import 'package:dom_marino_app/src/BLoC/listenAllCartItemsRetrieved_bloc.dart';
import 'package:dom_marino_app/src/BLoC/pizzaEdgePrice_bloc.dart';
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
  List<Product> allCartItemsProduct = new List();
  List<Product> allPizzaEdgesProduct = new List();

  int cartId = 0;
  TotalPriceBloc totalPrice_bloc;
  AllCartItemsBloc allCartItemsBloc;

//  List<PizzaEdgePriceBloc> pizzaEdgePriceBlocs = new List();
  ListenAllCartItemsReceivedBloc listenAllCartItemsReceivedBloc;
  List<String> includedProducts = new List();

  @override
  Future<void> initState() {
    totalPrice_bloc = new TotalPriceBloc();
    allCartItemsBloc = new AllCartItemsBloc();
    listenAllCartItemsReceivedBloc = new ListenAllCartItemsReceivedBloc();
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
                    stream: totalPrice_bloc.totalPriceStream,
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
                      child: StreamBuilder(
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
                                StreamBuilder(
                                  stream: allCartItemsBloc.controller.stream,
                                  builder: (context, snapshot) {
                                    Widget retorno = Container();
//                                  List<Widget> allCartItemsWidget = snapshot.data;

                                    if (snapshot.data != null) {
//                                    List<Widget> columnChildren = new List();
//                                    columnChildren.add(Text("Items", style: h4));
//
//                                    for (int i = 0; i < finalAllCartItemsMap.length; i++) {
//                                      CartItem tempProduct = CartItem.fromJson(
//                                          finalAllCartItemsMap[i]);
//                                      tempProduct.productCategory =
//                                      finalAllCartItemsMap[i]['productCategory'];
//                                    }

                                      ListView createdLists = new ListView(
                                        controller: null,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.vertical,
                                        children: snapshot.data,
                                      );

                                      retorno = createdLists;
//                                    print("not null");
//                                    buildCartItemsList();
                                    }

                                    return retorno;
                                  },
                                ),
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
                        stream: listenAllCartItemsReceivedBloc
                            .listenAllCartItemsReceivedBlocStream,
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
                ],
              ),
            )
          ],
        ));
  }

  Future<int> retrieveAllCartItems() async {
    List<Map<String, dynamic>> tempAllCartItems =
        await widget.dbHelper.retrieveAllCartItems(cartId);
    allCartItemsMap = new List();
    allCartItemsMap.addAll(tempAllCartItems);

    allCartItemsMap
        .sort((a, b) => a['productCategory'].compareTo(b['productCategory']));
    allCartItemsMap = allCartItemsMap.reversed.toList();

//    allCartItemsBloc.controller.sink.add(allCartItemsMap);
    listenAllCartItemsReceivedBloc.listenAllCartItemsReceivedBlocSink
        .add(allCartItemsMap.length);
    buildCartItemsList();

    return allCartItemsMap.length;
  }

  Future<int> retrieveCartId() async {
    Map<String, dynamic> cart =
        await widget.dbHelper.searchCart(widget.user.uid);
    cartId = await cart['cartId'];
    retrieveAllCartItems();
    return cart['cartId'];
  }

  Future<Widget> buildCartItemsList() async {
    totalPrice = "0,00";
//
//    print("entrou");

    includedProducts = new List();
    List<Widget> columnChildren = new List();
    columnChildren.add(Text("Items", style: h4));

    finalAllCartItemsMap = new List();
    finalAllCartItemsMap.addAll(allCartItemsMap);

    for (int i = 0; i < finalAllCartItemsMap.length; i++) {
      CartItem tempProduct = CartItem.fromJson(finalAllCartItemsMap[i]);
      tempProduct.productCategory = finalAllCartItemsMap[i]['productCategory'];

      if (finalAllCartItemsMap[i]['isTwoFlavoredPizza'] == 1) {
      } else {
        Product thisProduct;

        thisProduct = await getProduct(map: finalAllCartItemsMap[i]);

        if (finalAllCartItemsMap[i]['productSize'] == null) {
          //se não é pizza
          double tempPrice = double.parse(thisProduct.price) *
              finalAllCartItemsMap[i]['productAmount'];
          String oldTotalPrice = totalPrice.replaceAll(",", ".");

          thisProduct.price = tempPrice.toStringAsFixed(2);

          totalPrice =
              (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

          totalPrice_bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));
        } else {
          //se é pizza

          Product retrievedPizzaEdge;

          if (finalAllCartItemsMap[i]['pizzaEdgeId'] != null) {
//            pizzaEdgePriceBlocs.insert(i, new PizzaEdgePriceBloc());
            retrievedPizzaEdge = await getProduct(
                id: finalAllCartItemsMap[i]['pizzaEdgeId'],
                category: 'pizza_edges');
//            pizzaEdgePriceBlocs.elementAt(i).pizzaEdgePriceBlocSink//                .add(retrievedPizzaEdge);
          }
          double tempPizzaEdgePrice = 0.00;
          if (finalAllCartItemsMap[i]['productSize'] == "Broto") {
            if (retrievedPizzaEdge != null) {
              tempPizzaEdgePrice =
                  double.parse(retrievedPizzaEdge.price_broto) *
                      finalAllCartItemsMap[i]['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice = (double.parse(oldTotalPrice) + tempPizzaEdgePrice)
                  .toStringAsFixed(2);

              //retrievedPizzaEdge.price_broto = tempPizzaEdgePrice.toStringAsFixed(2);
              allPizzaEdgesProduct.add(retrievedPizzaEdge);

              totalPrice_bloc.totalPriceSink
                  .add(totalPrice.replaceAll(".", ","));
            }

            if (thisProduct.price_broto != null) {
              double tempPrice = double.parse(thisProduct.price_broto) *
                  finalAllCartItemsMap[i]['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice =
                  (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

              thisProduct.price_broto =
                  (tempPrice + tempPizzaEdgePrice).toStringAsFixed(2);

              totalPrice_bloc.totalPriceSink
                  .add(totalPrice.replaceAll(".", ","));
            }
          } else {
            //se for inteira

            if (retrievedPizzaEdge != null) {
              tempPizzaEdgePrice =
                  double.parse(retrievedPizzaEdge.price_inteira) *
                      finalAllCartItemsMap[i]['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice = (double.parse(oldTotalPrice) + tempPizzaEdgePrice)
                  .toStringAsFixed(2);

              //retrievedPizzaEdge.price_inteira = tempPizzaEdgePrice.toStringAsFixed(2);
              allPizzaEdgesProduct.add(retrievedPizzaEdge);

              totalPrice_bloc.totalPriceSink
                  .add(totalPrice.replaceAll(".", ","));
            }

            if (thisProduct.price_inteira != null) {
              double tempPrice = double.parse(thisProduct.price_inteira) *
                  finalAllCartItemsMap[i]['productAmount'];
              String oldTotalPrice = totalPrice.replaceAll(",", ".");
              totalPrice =
                  (double.parse(oldTotalPrice) + tempPrice).toStringAsFixed(2);

              thisProduct.price_inteira =
                  (tempPrice + tempPizzaEdgePrice).toStringAsFixed(2);

              totalPrice_bloc.totalPriceSink
                  .add(totalPrice.replaceAll(".", ","));
            }
          }
        }

        Widget thisFuture = Container(
          width: MediaQuery.of(context).size.width,
          child: cartItem(context, thisProduct,
              index: i,
              size: finalAllCartItemsMap[i]['productSize'],
              ammount: finalAllCartItemsMap[i],
              cartItemMap: allCartItemsMap[i]),
        );

        columnChildren.add(thisFuture);
      }
    }

    columnChildren.add(generateDummyListItem(60));

    allCartItemsBloc.allCartItemsSink.add(columnChildren);
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

//      includedProducts.add(id);
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
    int index,
  }) {
    return Card(
      color: Color(0xfffff2ca).withOpacity(0.65),
      elevation: 5,
      child: getCartItemContainer(context, onLike, imgWidth, product,
          isProductPage, onTapped, size, ammount, cartItemMap, index),
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
      Map<String, dynamic> cartItemMap,
      int index) {
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
              cartItemMap['pizzaEdgeId'] == null
                  ? Row(
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
                                int index =
                                    finalAllCartItemsMap.indexOf(ammount);
                                dynamic value = finalAllCartItemsMap[index]
                                    ["productAmount"];
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
                                int index =
                                    finalAllCartItemsMap.indexOf(ammount);
                                dynamic value = finalAllCartItemsMap[index]
                                    ["productAmount"];
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
                    )
                  : checkPizzaEdge(size, ammount, product, cartItemMap, index),
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

  Widget checkPizzaEdge(String size, Map<String, dynamic> ammount,
      Product pizza, Map<String, dynamic> cartItemMap, int index) {
    if (finalAllCartItemsMap[index]['pizzaEdgeId'] != null) {
      //tem borda

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Text(allPizzaEdgesProduct.elementAt(index).description,
                    style: minorPizzaEdgeText, overflow: TextOverflow.ellipsis),
              ),
              size != null ? Text(size, style: minorCartItemText) : Container(),
              getItemPrice(
                  size,
                  pizza,
                  finalAllCartItemsMap[finalAllCartItemsMap.indexOf(ammount)]
                      ["productAmount"]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  int thisIndex = finalAllCartItemsMap.indexOf(ammount);
                  dynamic value =
                      finalAllCartItemsMap[thisIndex]["productAmount"];
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
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(color: Colors.grey[500]),
                  ),
                  child: Icon(Icons.remove),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5, right: 10),
                child: Text(ammount['productAmount'].toString(), style: h3),
              ),
              InkWell(
                onTap: () async {
                  int thisIndex = finalAllCartItemsMap.indexOf(ammount);
                  dynamic value =
                      finalAllCartItemsMap[thisIndex]["productAmount"];
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
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    border: Border.all(color: Colors.grey[500]),
                  ),
                  child: Icon(Icons.add),
                ),
              )
            ],
          ),
        ],
      );
    } else {
      //não tem borda

    }
  }

//  Widget checkPizzaEdgeOld(String size, Map<String, dynamic> ammount,
//      Product pizza, Map<String, dynamic> cartItemMap, int index) {
//    return StreamBuilder(
//      stream: pizzaEdgePriceBlocs.elementAt(index).pizzaEdgePriceBlocStream,
//      builder: (context, productSnap) {
//        if (productSnap.connectionState == ConnectionState.none &&
//            productSnap.hasData == null) {
//          return Container();
//        } else if (productSnap.hasData) {
//          String tempPrice;
//          if (cartItemMap['productSize'] == null) {
//            tempPrice = (double.parse(pizza.price) +
//                    double.parse(productSnap.data.price))
//                .toStringAsFixed(2);
////            pizza.price = tempPrice;
//          } else {
//            if (cartItemMap['productSize'] == "Broto") {
//              tempPrice = (double.parse(pizza.price_broto) +
//                      double.parse(productSnap.data.price_broto))
//                  .toStringAsFixed(2);
////              pizza.price_broto = tempPrice;
//            } else if (cartItemMap['productSize'] == "Inteira") {
//              tempPrice = (double.parse(pizza.price_inteira) +
//                      double.parse(productSnap.data.price_inteira))
//                  .toStringAsFixed(2);
////              pizza.price_inteira = tempPrice;
//            }
//          }
//
////          String oldTotalPrice =
////              (double.parse(totalPrice) + double.parse(tempPrice))
////                  .toStringAsFixed(2);
//
////          totalPrice_bloc.totalPriceSink.add(oldTotalPrice.replaceAll(".", ","));
//
//          return Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              Column(
//                mainAxisAlignment: MainAxisAlignment.start,
//                crossAxisAlignment: CrossAxisAlignment.start,
//                children: <Widget>[
//                  Container(
//                    width: MediaQuery.of(context).size.width * 0.35,
//                    child: Text(productSnap.data.description,
//                        style: minorPizzaEdgeText,
//                        overflow: TextOverflow.ellipsis),
//                  ),
//                  size != null
//                      ? Text(size, style: minorCartItemText)
//                      : Container(),
//                  getItemPrice(
//                      size,
//                      pizza,
//                      finalAllCartItemsMap[finalAllCartItemsMap
//                          .indexOf(ammount)]["productAmount"]),
//                ],
//              ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                crossAxisAlignment: CrossAxisAlignment.center,
//                children: <Widget>[
//                  InkWell(
//                    onTap: () async {
//                      int thisIndex = finalAllCartItemsMap.indexOf(ammount);
//                      dynamic value =
//                          finalAllCartItemsMap[thisIndex]["productAmount"];
//                      value = value - 1;
//                      Map<String, dynamic> newMap = new Map();
//                      newMap.addAll(ammount);
//                      newMap["productAmount"] = value;
//                      await widget.dbHelper
//                          .update(newMap, "cartItems", "cartItemsId");
//
//
//                      setState(() {
//                        retrieveAllCartItems();
//                      });
//                    },
//                    child: Container(
//                      width: 30,
//                      height: 30,
//                      margin: EdgeInsets.only(right: 5),
//                      alignment: Alignment.center,
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                        border: Border.all(color: Colors.grey[500]),
//                      ),
//                      child: Icon(Icons.remove),
//                    ),
//                  ),
//                  Container(
//                    margin: EdgeInsets.only(left: 5, right: 10),
//                    child: Text(ammount['productAmount'].toString(), style: h3),
//                  ),
//                  InkWell(
//                    onTap: () async {
//                      int thisIndex = finalAllCartItemsMap.indexOf(ammount);
//                      dynamic value =
//                          finalAllCartItemsMap[thisIndex]["productAmount"];
//                      value = value + 1;
//                      Map<String, dynamic> newMap = new Map();
//                      newMap.addAll(ammount);
//                      newMap["productAmount"] = value;
//                      await widget.dbHelper
//                          .update(newMap, "cartItems", "cartItemsId");
//
//
//                      setState(() {
//                        retrieveAllCartItems();
//                      });
//                    },
//                    child: Container(
//                      width: 30,
//                      height: 30,
//                      alignment: Alignment.center,
//                      decoration: BoxDecoration(
//                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                        border: Border.all(color: Colors.grey[500]),
//                      ),
//                      child: Icon(Icons.add),
//                    ),
//                  )
//                ],
//              ),
//            ],
//          );
//        }
//        return Container();
//      },
//    );
//  }
}
