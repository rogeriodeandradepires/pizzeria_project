import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dom_marino_app/src/BLoC/allCartItems_bloc.dart';
import 'package:dom_marino_app/src/BLoC/listenAllCartItemsRetrieved_bloc.dart';
import 'package:dom_marino_app/src/BLoC/totalPrice_bloc.dart';
import 'package:dom_marino_app/src/models/cart_item_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/screens/Dashboard.dart';
import 'package:dom_marino_app/src/shared/cart_partials.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as diolib;

class CartPage extends StatefulWidget {
  final dbHelper;
  final FirebaseUser user;

  CartPage({Key key, this.dbHelper, this.user}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isLoading = false;
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

  var globalContext;

  @override
  Future<void> initState() {
//    Dialog thisDialog = showLoadingDialog();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      isLoading = true;
      return showLoadingDialog();
    });

    totalPrice_bloc = new TotalPriceBloc();
    allCartItemsBloc = new AllCartItemsBloc();
    listenAllCartItemsReceivedBloc = new ListenAllCartItemsReceivedBloc();
    retrieveCartId();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
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
//                          print(itemsCount.data);

                          if (itemsCount.data == null) {
                            return Container(
                              child: _showOverlay(context),
                            );
                          }

                          if (itemsCount.data == 0) {
                            totalPrice_bloc.totalPriceSink.add("0,00");
                            return Container(
                                height: 500,
                                margin: EdgeInsets.only(right: 5),
                                child: Center(
                                    child: Text(
                                        'Nenhum item no carrinho neste momento.',
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
                                    child: froyoFlatBtn('Realizar Pedido',
                                        () async {
                                    Dialog thisDialog = showLoadingDialog();
                                    checkWorkingHoursAndPlaceOrder();
                                    }),
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
    cartId = cart != null ? await cart['cartId'] : null;
    retrieveAllCartItems();
    return cartId;
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
      Product thisProduct;

      if (finalAllCartItemsMap[i]['isTwoFlavoredPizza'] == 1) {
//        print("É pizza de 2 sabores");
//        print("Product: "+finalAllCartItemsMap[i].toString());

        //se for pizza de 2 sabores
        thisProduct = await getProduct(
            category: finalAllCartItemsMap[i]['categoryName'],
            id: finalAllCartItemsMap[i]['product1Id'],
            productOrder: "product1");

        Product product2 = await getProduct(
            category: finalAllCartItemsMap[i]['product2CategoryName'],
            id: finalAllCartItemsMap[i]['product2Id'],
            productOrder: "product2");

        Product retrievedPizzaEdge;
//        print("Pizza Edge: "+finalAllCartItemsMap[i]['pizzaEdgeId'].toString());

        if (finalAllCartItemsMap[i]['pizzaEdgeId'] != null &&
            finalAllCartItemsMap[i]['pizzaEdgeId'] != "null") {
//          print("Entrou errado");
          retrievedPizzaEdge = await getProduct(
              id: finalAllCartItemsMap[i]['pizzaEdgeId'],
              category: 'pizza_edges');
        }
        double tempPizzaEdgePrice = 0.00;
        double higherPrice;

        if (finalAllCartItemsMap[i]['productSize'] == "Broto") {
          higherPrice = max(double.parse(thisProduct.price_broto),
              double.parse(product2.price_broto));
          if (retrievedPizzaEdge != null) {
            allPizzaEdgesProduct.add(retrievedPizzaEdge);
            tempPizzaEdgePrice = double.parse(retrievedPizzaEdge.price_broto) *
                finalAllCartItemsMap[i]['productAmount'];
          }
        } else if (finalAllCartItemsMap[i]['productSize'] == "Inteira") {
          higherPrice = max(double.parse(thisProduct.price_inteira),
              double.parse(product2.price_inteira));

          thisProduct.description =
              thisProduct.description + " + " + product2.description;

          if (retrievedPizzaEdge != null) {
            allPizzaEdgesProduct.add(retrievedPizzaEdge);
            tempPizzaEdgePrice =
                double.parse(retrievedPizzaEdge.price_inteira) *
                    finalAllCartItemsMap[i]['productAmount'];
          }
        }

        double tempProductPrice =
            higherPrice * finalAllCartItemsMap[i]['productAmount'];
        String oldTotalPrice = totalPrice.replaceAll(",", ".");
        totalPrice = (double.parse(oldTotalPrice) +
                tempProductPrice +
                (tempPizzaEdgePrice))
            .toStringAsFixed(2);

        if (finalAllCartItemsMap[i]['productSize'] == "Broto") {
          thisProduct.price_broto =
              (tempProductPrice + tempPizzaEdgePrice).toStringAsFixed(2);
        } else if (finalAllCartItemsMap[i]['productSize'] == "Inteira") {
          thisProduct.price_inteira =
              (tempProductPrice + tempPizzaEdgePrice).toStringAsFixed(2);
        }

        totalPrice_bloc.totalPriceSink.add(totalPrice.replaceAll(".", ","));
      } else {
        //se não for pizza de 2 sabores
//        print("Não é pizza de 2 sabores");
//        print("Product: "+finalAllCartItemsMap[i].toString());

        thisProduct = await getProduct(map: finalAllCartItemsMap[i]);
        thisProduct.category =
            finalAllCartItemsMap[i]['productCategory'].toString();

        if (!finalAllCartItemsMap[i]['productCategory']
                .toString()
                .contains("Pizza") &&
            finalAllCartItemsMap[i]['productCategory'].toString() != "null") {
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

          if (finalAllCartItemsMap[i]['pizzaEdgeId'] != null &&
              finalAllCartItemsMap[i]['pizzaEdgeId'] != "null") {
//            pizzaEdgePriceBlocs.insert(i, new PizzaEdgePriceBloc());
            retrievedPizzaEdge = await getProduct(
                id: finalAllCartItemsMap[i]['pizzaEdgeId'],
                category: 'pizza_edges');
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

    columnChildren.add(generateDummyListItem(60));

    allCartItemsBloc.allCartItemsSink.add(columnChildren);

    if (isLoading) {
      isLoading = false;
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<Product> getProduct(
      {Map<String, dynamic> map,
      String id,
      String category,
      String productOrder}) async {
//    print("problema");
//    print("category: $category, id: $id");
//    print("map: $map");
//    print("productOrder: $productOrder");
    if (map != null) {
      if (map['isTwoFlavoredPizza'] == 1) {
        if (productOrder == "product1") {
          id = map['product1Id'];
          category = map['categoryName'];
        } else {
          id = map['product2Id'];
          category = map['product2CategoryName'];
        }
      } else {
        id = map['productId'];
        category = map['categoryName'];
      }
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
    List<Widget> columnChildren = new List();
    columnChildren.add(Text(product.description, style: minorFoodNameText));

    if (cartItemMap['pizzaEdgeId'] == null) {
      columnChildren.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (size != null && size != "" && size != "None")
                  ? Text(size, style: minorCartItemText)
                  : ((product.size != null && product.size != "None")
                      ? Text(product.size, style: minorCartItemText)
                      : Container()),
              getItemPrice(
                  size,
                  product,
                  finalAllCartItemsMap[finalAllCartItemsMap.indexOf(ammount)]
                      ["productAmount"]),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: () {
                  isLoading = true;
                  showLoadingDialog();

                  subtractAmmount(ammount);
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
                  isLoading = true;
                  showLoadingDialog();

                  addAmmount(ammount);
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
      ));
    } else {
      columnChildren
          .add(checkPizzaEdge(size, ammount, product, cartItemMap, index));
    }

    if (cartItemMap['productObservations'] != null &&
        cartItemMap['productObservations'] != "" &&
        cartItemMap['productObservations'] != "None") {
      columnChildren.add(Container(
        margin: EdgeInsets.only(top: 5, right: 4, bottom: 2),
        child: Text(
          cartItemMap['productObservations'],
          style: minorCartItemObservationsText,
          textAlign: TextAlign.justify,
        ),
      ));
    }

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
                      cartItemMap['isTwoFlavoredPizza'] == 1
                          ? "https://storage.googleapis.com/dom-marino-ws.appspot.com/categories/custom/two_flavored_pizza_image.png"
                          : product.imageUrl,
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
            children: columnChildren,
          ),
        ),
      ],
    );
  }

  Widget getItemPrice(String size, Product product, int ammount) {
    double tempPrice;

    Widget retorno;

    print("Aqui: " + product.category.toString());

    if (!product.category.toString().toLowerCase().contains("pizza") &&
        product.category.toString() != "null") {
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
    String pizzaEdgeDescription;

    allPizzaEdgesProduct.forEach((pizzaEdge) {
      if (pizzaEdge.id == cartItemMap["pizzaEdgeId"]) {
        pizzaEdgeDescription = pizzaEdge.description;
      }
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: (pizzaEdgeDescription != null &&
                      pizzaEdgeDescription != "null")
                  ? Text(pizzaEdgeDescription,
                      style: minorPizzaEdgeText,
                      overflow: TextOverflow.ellipsis)
                  : Container(),
            ),
            (size != null && size != "None")
                ? Text(size, style: minorCartItemText)
                : Container(),
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
                isLoading = true;
                showLoadingDialog();

                int thisIndex = finalAllCartItemsMap.indexOf(ammount);
                dynamic value =
                    finalAllCartItemsMap[thisIndex]["productAmount"];
                value = value - 1;

                if (value == 0) {
                  await widget.dbHelper.delete(
                      finalAllCartItemsMap[index]['cartItemsId'],
                      "cartItems",
                      "cartItemsId");
                } else {
                  Map<String, dynamic> newMap = new Map();
                  newMap.addAll(ammount);
                  newMap["productAmount"] = value;
                  await widget.dbHelper
                      .update(newMap, "cartItems", "cartItemsId");
                }

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
                isLoading = true;
                showLoadingDialog();

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
  }

  Dialog showLoadingDialog() {
    Dialog retorno;
    showGeneralDialog(
        context: globalContext,
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

  Future<void> subtractAmmount(Map<String, dynamic> ammount) async {
    int index = finalAllCartItemsMap.indexOf(ammount);
    dynamic value = finalAllCartItemsMap[index]["productAmount"];
    value = value - 1;

    if (value == 0) {
      await widget.dbHelper.delete(finalAllCartItemsMap[index]['cartItemsId'],
          "cartItems", "cartItemsId");
    } else {
      Map<String, dynamic> newMap = new Map();
      newMap.addAll(ammount);
      newMap["productAmount"] = value;
      await widget.dbHelper.update(newMap, "cartItems", "cartItemsId");
    }

    setState(() {
      retrieveAllCartItems();
    });
  }

  Future<void> addAmmount(Map<String, dynamic> ammount) async {
    int index = finalAllCartItemsMap.indexOf(ammount);
    dynamic value = finalAllCartItemsMap[index]["productAmount"];
    value = value + 1;
    Map<String, dynamic> newMap = new Map();
    newMap.addAll(ammount);
    newMap["productAmount"] = value;
    await widget.dbHelper.update(newMap, "cartItems", "cartItemsId");

    setState(() {
      retrieveAllCartItems();
    });
  }

  Future<void> checkWorkingHoursAndPlaceOrder() async {
    String url = 'http://api.timezonedb.com/v2.1/get-time-zone?key=PJ3V1SZ4GHNA&format=json&by=zone&zone=America/Sao_Paulo';
  //formatted
//    String url = 'http://worldtimeapi.org/api/timezone/America/Sao_Paulo';

    Response response = await get(url);
    // sample info available in response
    int statusCode = response.statusCode;
    Map<String, String> headers = response.headers;
    String contentType = headers['content-type'];
    dynamic realDateTime = json.decode(response.body);

    var date = DateTime.parse(realDateTime['formatted'].toString());
    String dayOfTheWeek = DateFormat('EEE').format(date).toLowerCase();

//    print(dayOfTheWeek);

    String currentHoursString = realDateTime["formatted"]
        .toString()
        .substring(11, 13);

    if (currentHoursString=="00") {
      currentHoursString = "24";
    }

    int currentHours = int.parse(currentHoursString);

    int currentMinutes =
        int.parse(realDateTime["formatted"].toString().substring(14, 16));
    int currentTimeSum = currentHours * 60 + currentMinutes;

    String formattedActualDateTime = realDateTime['formatted'].toString().substring(0, 10) +
            " " +
            currentHours.toString() +
            ":" +
            realDateTime["formatted"].toString().substring(14, 16) +
            ":00";
    print(formattedActualDateTime);
//  var now = new DateTime.now();
//
//  print(now.toString().substring(0, 19));

    int serverHoursFrom;
    int serverMinutesFrom;
    int serverTimeSumFrom;

    int serverHoursTo;
    int serverMinutesTo;
    int serverTimeSumTo;

    var queryParameters = {
      'weekDay': '$dayOfTheWeek',
    };

    var uri = Uri.https('dom-marino-webservice.appspot.com',
        'get_working_hours', queryParameters);

    Response wh_response = await get(uri);
    // sample info available in response
    int wh_statusCode = wh_response.statusCode;
    Map<String, String> wh_headers = wh_response.headers;
    String wh_contentType = headers['content-type'];
    dynamic workingHours = json.decode(wh_response.body);

    if (response.statusCode == 200) {

      serverHoursFrom =
          int.parse(workingHours["from"].toString().substring(0, 2));
      serverMinutesFrom =
          int.parse(workingHours["from"].toString().substring(3, 5));
      serverTimeSumFrom = serverHoursFrom * 60 + serverMinutesFrom;

      serverHoursTo = int.parse(workingHours["to"].toString().substring(0, 2));
      serverMinutesTo =
          int.parse(workingHours["to"].toString().substring(3, 5));
      serverTimeSumTo = serverHoursTo * 60 + serverMinutesTo;
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load product');
    }

    print(currentTimeSum);
    print(serverTimeSumFrom);
    print(serverTimeSumTo);

    if (serverHoursFrom != null) {
      if (currentTimeSum >= serverTimeSumFrom &&
          currentTimeSum <= serverTimeSumTo) {
//      String url = 'http://192.168.63.1:8080/makeorder';
        String userId = widget.user.uid;
        String coupon_id = null;

//      var now = new DateTime.now();

//      print("Aqui:" + now.toString());

//      var formatter = new DateFormat('yyyy-MM-dd Hms');
//      String dateTime = now.toString().substring(0, 19);
//      print(dateTime);

        String id = null;
        String delivery = "withdraw";
        String payment_method = "credit_card";
        String total = null;

        Map<String, dynamic> productsId = {};

        finalAllCartItemsMap.forEach((item) {
//      print("Item: "+item.toString());

          String pizza_edge_id = item['pizzaEdgeId'];
          String product1_category = item["categoryName"];
          String product2_category = item["product2CategoryName"];
          String product_id = "";

          if (item["isTwoFlavoredPizza"] == 1) {
            product_id = item["product1Id"];
          } else {
            product_id = item["productId"];
          }

          Map<String, dynamic> tempMap = {
            'category': item['productCategory'],
            'notes': item['productObservations'],
            'pizza_edge_id': '$pizza_edge_id',
            'product1_category': '$product1_category',
            'product2_category': '$product2_category',
            'product2_id': item['product2Id'],
            'product_id': product_id,
            'isTwoFlavoredPizza': item["isTwoFlavoredPizza"],
            'quantity': item['productAmount'],
            'size': item['productSize'],
          };

          String tempProductsId = new DateTime.now().toUtc().toString();

          productsId[tempProductsId] = tempMap;

//      print(tempMap);
        });

//      print("productsId: "+json.encode(productsId));

        var queryParameters = {
          'date_time': '$formattedActualDateTime',
          'coupon_id': '$coupon_id',
          'id': '$id',
          'delivery': '$delivery',
          'payment_method': '$payment_method',
          'total': '$total',
          'userId': '$userId',
          'products_id': json.encode(productsId),
        };

        var url = "https://dom-marino-webservice.appspot.com/makeorder";
//      var url = "http://192.168.63.1:8080/makeorder";

        diolib.Dio dio = new diolib.Dio();
        diolib.Response apiResponse =
            await dio.post(url, data: queryParameters);
        print(apiResponse.data.toString());


        Navigator.of(context, rootNavigator: false).pop();

        await widget.dbHelper.delete(cartId, "cartItems", "cartId");
        await widget.dbHelper.delete(cartId, "cart", "cartId");

        showSuccessDialog();

      }else{
        Navigator.of(context, rootNavigator: false).pop();
        showTimeErrorDialog();
      }
    }
  }

  Dialog showSuccessDialog() {
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
                          height: MediaQuery.of(context).size.width * 0.5,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: Column(
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
                                      "Pedido Recebido",
                                      style: h2,
                                    ),
                                  ),
                                  color: Colors.lightGreen,
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Text(
                                    "Seu pedido foi recebido com sucesso.",
                                    style: h6,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: froyoFlatBtn("Ok", () async {
                                  Navigator.of(context, rootNavigator: false).pop("Ok");
                                  Navigator.of(context, rootNavigator: true).pop("Ok");
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

  Dialog showTimeErrorDialog() {
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
                          height: MediaQuery.of(context).size.height * 0.4,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                            new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: Column(
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
                                      "Horário de Atendimento",
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
                                              "Pedido fora do horário de atendimento. Por favor, tente novamente de:",
                                              style: h6,
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.7,
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: AutoSizeText(
                                                "Dom à Sex das 19:00 às 23:00",
                                                style: h6,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.7,
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                "Sáb das 19:00 às 23:30",
                                                style: h6,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 15.0, right: 15.0),
                                child: froyoFlatBtn("Ok", () async {
                                  Navigator.of(context, rootNavigator: true).pop();
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

}
