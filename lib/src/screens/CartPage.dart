import 'dart:convert';
import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dom_marino_app/src/BLoC/allCartItems_bloc.dart';
import 'package:dom_marino_app/src/BLoC/listenAllCartItemsRetrieved_bloc.dart';
import 'package:dom_marino_app/src/BLoC/totalPrice_bloc.dart';
import 'package:dom_marino_app/src/models/cart_item_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as diolib;

class CartPage extends StatefulWidget {
  final dbHelper;
  Map<String, dynamic> thisUser;
  String uri;
  String url;
  Map<String, dynamic> aboutInfo;

  CartPage({Key key, this.dbHelper, this.thisUser, this.uri, this.url, this.aboutInfo}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _addressFormKey = GlobalKey<FormState>();
  final _paymentFormKey = GlobalKey<FormState>();
  var _addStreetController;
  var _addNumberController;
  var _addNeighborhoodController;
  var _addCityController;
  var _paymentChangeController;

  FocusNode _paymentChangeFN;
  FocusNode _addressStreetFN;
  FocusNode _addressStreetNumberFN;
  FocusNode _addressNeighborhoodFN;

  bool isLoading = false;
  int _quantity = 1;

  Widget firstFlavorChosen;
  Widget secondFlavorChosen;

  Product product1ToReturn;
  Product product2ToReturn;

  String brotoPrice_global;
  String inteiraPrice_global;

  String _radioValueDelivery = "withdraw";
  String _radioNeedChange = "sim";
  String _radioValueAddress = "userAddress";
  String _radioValuePayment = "credit_card";

  bool shouldShowAnotherAddress = false;
  bool shouldShowPaymentChange = false;
  bool shouldShowPaymentChangeValue = true;

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

  String formattedActualDateTime = "";

  String calculateNewTotal = "";

//  var maskFormatter = new MaskTextInputFormatter(mask: 'R\$ ###,##', filter: { "#": RegExp(r'[0-9]') });

  @override
  void dispose() {
    _addCityController.dispose();
    _addNeighborhoodController.dispose();
    _addNumberController.dispose();
    _addStreetController.dispose();
    _paymentChangeController.dispose();

    _paymentChangeFN.dispose();
    _addressStreetFN.dispose();
    _addressStreetNumberFN.dispose();
    _addressNeighborhoodFN.dispose();

    super.dispose();
  }

  @override
  Future<void> initState() {
//    Dialog thisDialog = showLoadingDialog();

    _addNumberController = TextEditingController();
    _addStreetController = TextEditingController();
    _addNeighborhoodController = TextEditingController();
    _addCityController = TextEditingController();
    _paymentChangeController =
        TextEditingController(); //_paymentChangeController.text.length <9 ? MaskedTextController(mask: 'R\$ 00,00') : MaskedTextController(mask: 'R\$ 00,00');
    //MoneyMaskedTextController(leftSymbol: ' R\$ ', decimalSeparator: ',', thousandSeparator: '.');

    _paymentChangeFN = FocusNode();
    _addressStreetFN = FocusNode();
    _addressStreetNumberFN = FocusNode();
    _addressNeighborhoodFN = FocusNode();

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
                      padding: EdgeInsets.only(top: 10, left: 2),
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: StreamBuilder(
                        builder: (context, itemsCount) {
//                          //print(itemsCount.data);

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
//                                    //print("not null");
//                                    buildCartItemsList();
                                    }

                                    return retorno;
                                  },
                                ),
                                Positioned(
                                  bottom: -5,
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    margin: EdgeInsets.only(bottom: 10),
                                    child: Center(
                                      child: froyoFlatBtn('Realizar Pedido',
                                          () async {
                                        Dialog thisDialog = showLoadingDialog();
                                        checkWorkingHoursAndPlaceOrder();
                                      }),
                                    ),
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

    var newMap = new Map();

//    tempAllCartItems.forEach((map) {
//      //print("item do carrinho: "+map.toString());
//      newMap.addAll(map);
//    });

//    //print("todos os itens do carrinho: "+newMap.toString());

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
        await widget.dbHelper.searchCart(widget.thisUser['uid']);
    cartId = cart != null ? await cart['cartId'] : null;
    retrieveAllCartItems();
    return cartId;
  }

  Future<Widget> buildCartItemsList() async {
    totalPrice = "0,00";
//
//    //print("entrou");

    includedProducts = new List();
    List<Widget> columnChildren = new List();
    columnChildren.add(Text("Itens", style: h4));

    finalAllCartItemsMap = new List();
    finalAllCartItemsMap.addAll(allCartItemsMap);

//    allCartItemsMap.forEach((element) {
//      //print("item do carrinho: "+element.toString());
//    });


    for (int i = 0; i < finalAllCartItemsMap.length; i++) {
      CartItem tempProduct = CartItem.fromJson(finalAllCartItemsMap[i]);
      tempProduct.productCategory = finalAllCartItemsMap[i]['productCategory'];
      Product thisProduct;

      //print("tempProduct: "+finalAllCartItemsMap[i].toString());

      if (finalAllCartItemsMap[i]['isTwoFlavoredPizza'] == 1) {
//        //print("É pizza de 2 sabores");
        //print("getProduct 1: ");

        //se for pizza de 2 sabores
        thisProduct = await getProduct(
            category: finalAllCartItemsMap[i]['categoryName'],
            id: finalAllCartItemsMap[i]['product1Id'],
            productOrder: "product1");

        //print("getProduct 2: ");

        Product product2 = await getProduct(
            category: finalAllCartItemsMap[i]['product2CategoryName'],
            id: finalAllCartItemsMap[i]['product2Id'],
            productOrder: "product2");

        Product retrievedPizzaEdge;
//        //print("Pizza Edge: "+finalAllCartItemsMap[i]['pizzaEdgeId'].toString());

        if (finalAllCartItemsMap[i]['pizzaEdgeId'] != null &&
            finalAllCartItemsMap[i]['pizzaEdgeId'] != "null") {
//          //print("Entrou errado");
          //print("getProduct 3: ");
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
//        //print("Não é pizza de 2 sabores");
//        //print("Product: "+finalAllCartItemsMap[i].toString());

        //print("getProduct 4: ");

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
            //print("getProduct 5: ");
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
//    //print("problema");
//    //print("category: $category, id: $id");
//    //print("map: $map");
//    //print("productOrder: $productOrder");
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

    //print("category: "+category+", product: "+map.toString());

    var uri = Uri.https(
        widget.uri, 'list_$category', queryParameters);

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

      child: Container(
        width: MediaQuery.of(context).size.width,
        child: getCartItemContainer(context, onLike, imgWidth, product,
            isProductPage, onTapped, size, ammount, cartItemMap, index),
      ),
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

    if (cartItemMap['pizzaEdgeId'] == null||cartItemMap['pizzaEdgeId'] == "null") {
      columnChildren.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              (size != null && size != "" && size != "None" && size != "null")
                  ? Text(size, style: minorCartItemText)
                  : ((product.size != null && product.size != "None" && product.size != "null" && size != "")
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

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          //quadrado branco fictício do conjunto imagem
          width: 50,
          height: 50,
          margin: EdgeInsets.only(right: 5),
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
        Expanded(
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

    //print("Aqui: " + product.category.toString());

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
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  (pizzaEdgeDescription != null &&
                      pizzaEdgeDescription != "null")
                      ? AutoSizeText(pizzaEdgeDescription,
                      style: minorPizzaEdgeText,
                      overflow: TextOverflow.ellipsis)
                      : Container(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      (size != null && size != "None" && size != "null")
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
              ),
            ],
          ),
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
    bool isValidTime = await checkWorkinghours();

    if (isValidTime) {
      Navigator.of(context, rootNavigator: false).pop();
      showDeliveryOptionsDialog();
    } else {
      Navigator.of(context, rootNavigator: false).pop();
      showTimeErrorDialog();
    }
  }

  //comentario so para comit
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
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
                                    left: 15.0, right: 15.0, bottom: 10.0),
                                child: froyoFlatBtn("Ok", () async {
                                  Navigator.of(context, rootNavigator: false)
                                      .pop("Ok");
                                  Navigator.of(context, rootNavigator: true)
                                      .pop("Ok");
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  height: 50,
                                  child: Center(
                                    child: AutoSizeText(
                                      "Horário de Atendimento",
                                      style: h2,
                                      maxLines: 1,
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
                                      Text(
                                        "Pedido fora do horário de atendimento. Por favor, tente novamente de:",
                                        style: h6,
                                        textAlign: TextAlign.justify,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 8.0, top: 8.0),
                                        child: AutoSizeText(
                                          "Dom à Sex das 19:00 às 23:00",
                                          style: h6,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, left: 8.0),
                                        child: AutoSizeText(
                                          "Sáb das 19:00 às 23:30",
                                          style: h6,
                                          maxLines: 1,
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
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
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

  Dialog showDeliveryOptionsDialog() {
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: StatefulBuilder(builder: (context, setState) {
              return WillPopScope(
                onWillPop: () {},
                child: Material(
                    color: Colors.transparent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10)),
                                child: Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  height: 50,
                                  child: Center(
                                    child: AutoSizeText(
                                      "Delivery",
                                      style: h2,
                                      maxLines: 1,
                                    ),
                                  ),
                                  color: Colors.orangeAccent,
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        "Você deseja que o pedido seja entregue na sua residência ou prefere retirar na pizzaria?",
                                        style: h6,
                                        textAlign: TextAlign.justify,
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          autofocus: true,
                                          onTap: () {
                                            setState(() {
                                              _radioValueDelivery = "withdraw";
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Radio(
                                                value: "withdraw",
                                                groupValue: _radioValueDelivery,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _radioValueDelivery = value;
                                                  });
                                                },
                                              ),
                                              AutoSizeText(
                                                "Retirada",
                                                style: h6,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          autofocus: true,
                                          onTap: () {
                                            setState(() {
                                              _radioValueDelivery = "delivery";
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Radio(
                                                value: "delivery",
                                                groupValue: _radioValueDelivery,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _radioValueDelivery = value;
                                                  });
                                                },
                                              ),
                                              AutoSizeText(
                                                "Entrega (+ R\$ "+widget.aboutInfo['delivery_tax'].toString().replaceAll(".",",")+")",
                                                style: h6,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5.0, left: 5.0),
                                      child: froyoFlatBtn("Cancelar", () async {
                                        cancelPurchaseDialog();
                                      }, style: h6White),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          right: 5.0, left: 5.0),
                                      child: froyoFlatBtn("Avançar", () async {
                                        //fecha o próprio dialog
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();

                                        if (_radioValueDelivery == "withdraw") {
                                          placeOrder();
                                        } else {
                                          showAddressOptions();
                                        }
                                      }, style: h6White),
                                    ),
                                  ),
                                ],
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

  Future<bool> checkWorkinghours() async {
    String url =
        'http://api.timezonedb.com/v2.1/get-time-zone?key=PJ3V1SZ4GHNA&format=json&by=zone&zone=America/Sao_Paulo';
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

//    //print(dayOfTheWeek);

    String currentHoursString =
        realDateTime["formatted"].toString().substring(11, 13);

    if (currentHoursString == "00") {
      currentHoursString = "24";
    }

    int currentHours = int.parse(currentHoursString);

    int currentMinutes =
        int.parse(realDateTime["formatted"].toString().substring(14, 16));
    int currentTimeSum = currentHours * 60 + currentMinutes;

    formattedActualDateTime =
        realDateTime['formatted'].toString().substring(0, 10) +
            " " +
            currentHours.toString() +
            ":" +
            realDateTime["formatted"].toString().substring(14, 16) +
            ":00";
    //print(formattedActualDateTime);
//  var now = new DateTime.now();
//
//  //print(now.toString().substring(0, 19));

    int serverHoursFrom;
    int serverMinutesFrom;
    int serverTimeSumFrom;

    int serverHoursTo;
    int serverMinutesTo;
    int serverTimeSumTo;

    var queryParameters = {
      'weekDay': '$dayOfTheWeek',
    };

    var uri = Uri.https(widget.uri,
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

    //print(currentTimeSum);
    //print(serverTimeSumFrom);
    //print(serverTimeSumTo);

    //para fim de testes:
    currentTimeSum = serverTimeSumFrom;

    if (serverHoursFrom != null) {
      return currentTimeSum >= serverTimeSumFrom &&
          currentTimeSum <= serverTimeSumTo;
    } else {
      return false;
    }
  }

  Dialog showPaymentOptions() {
    shouldShowPaymentChange = false;
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: StatefulBuilder(builder: (context, setState) {
              return WillPopScope(
                onWillPop: () {},
                child: Material(
                    color: Colors.transparent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    height: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        "Forma de Pagamento",
                                        style: h2,
                                        maxLines: 1,
                                      ),
                                    ),
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Escolha a forma de pagamento",
                                          style: h6,
                                          textAlign: TextAlign.justify,
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            autofocus: true,
                                            onTap: () {
                                              setState(() {
                                                _radioValuePayment =
                                                    "credit_card";
                                                shouldShowPaymentChange = false;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Radio(
                                                  value: "credit_card",
                                                  groupValue:
                                                      _radioValuePayment,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _radioValuePayment =
                                                          value;
                                                      shouldShowPaymentChange =
                                                          false;
                                                    });
                                                  },
                                                ),
                                                AutoSizeText(
                                                  "Cartão",
                                                  style: h6,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            autofocus: true,
                                            onTap: () {
                                              setState(() {
                                                _radioValuePayment = "money";
                                                shouldShowPaymentChange = true;
                                              });
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Radio(
                                                  value: "money",
                                                  groupValue:
                                                      _radioValuePayment,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _radioValuePayment =
                                                          value;
                                                      shouldShowPaymentChange =
                                                          true;
                                                    });
                                                  },
                                                ),
                                                AutoSizeText(
                                                  "Dinheiro",
                                                  style: h6,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        shouldShowPaymentChange
                                            ? returnPaymentChangeForm()
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child:
                                            froyoFlatBtn("Cancelar", () async {
                                          cancelPurchaseDialog();
                                        }, style: h6White),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child: froyoFlatBtn("Pedir", () async {
                                          if (_radioNeedChange == "sim" && _radioValuePayment=="money") {
                                            if (_paymentFormKey.currentState
                                                .validate()) {
                                              //fecha o próprio dialog
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              placeOrder();
                                            }
                                          } else {
                                            //fecha o próprio dialog
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            placeOrder();
                                          }
                                        }, style: h6White),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: _paymentChangeFN.hasFocus ? 230 : 0,
                                ),
                              ],
                            ),
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

  Dialog showAddressOptions() {
    shouldShowAnotherAddress = false;
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: StatefulBuilder(builder: (context, setState) {
              return WillPopScope(
                onWillPop: () {},
                child: Material(
                    color: Colors.transparent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: Colors.white,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(10.0)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10)),
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    height: 50,
                                    child: Center(
                                      child: AutoSizeText(
                                        "Endereço",
                                        style: h2,
                                        maxLines: 1,
                                      ),
                                    ),
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "Escolha o endereço para a entrega:",
                                          style: h6,
                                          textAlign: TextAlign.justify,
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            autofocus: true,
                                            onTap: () {
                                              setState(() {
                                                _radioValueAddress =
                                                    "userAddress";
                                                shouldShowAnotherAddress =
                                                    false;
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Radio(
                                                  value: "userAddress",
                                                  groupValue:
                                                      _radioValueAddress,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _radioValueAddress =
                                                          value;
                                                      shouldShowAnotherAddress =
                                                          false;
                                                    });
                                                  },
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: <Widget>[
                                                      AutoSizeText(
                                                        widget.thisUser[
                                                                'street'] +
                                                            ", Nº " +
                                                            widget.thisUser[
                                                                'streetNumber'],
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                      AutoSizeText(
                                                        widget.thisUser[
                                                                'neighborhood'] +
                                                            " - " +
                                                            widget.thisUser[
                                                                'city'],
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.justify,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            autofocus: true,
                                            onTap: () {
                                              setState(() {
                                                _radioValueAddress =
                                                    "newAddress";
                                                shouldShowAnotherAddress = true;
                                                _addCityController.text =
                                                    "Birigui";
                                              });
                                            },
                                            child: Row(
                                              children: <Widget>[
                                                Radio(
                                                  value: "newAddress",
                                                  groupValue:
                                                      _radioValueAddress,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      _radioValueAddress =
                                                          value;
                                                      shouldShowAnotherAddress =
                                                          true;
                                                    });
                                                  },
                                                ),
                                                AutoSizeText(
                                                  "Outro Endereço",
                                                  style: h6,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        shouldShowAnotherAddress
                                            ? returnAddressForm()
                                            : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child:
                                            froyoFlatBtn("Cancelar", () async {
                                          cancelPurchaseDialog();
                                        }, style: h6White),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 5.0, left: 5.0),
                                        child:
                                            froyoFlatBtn("Avançar", () async {
                                          //fecha o próprio dialog

                                          if (_radioValueAddress ==
                                              "userAddress") {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                            //print("Aqui: endereço user");
                                            showPaymentOptions();
                                          } else {
                                            //print("Aqui: outro endereço");

                                            if (_addressFormKey.currentState
                                                .validate()) {
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                              showPaymentOptions();
                                              //print("Aqui: validou");
                                            } else {
                                              //print("Aqui: não validou");
                                            }
                                          }
                                        }, style: h6White),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: (_addressStreetFN.hasFocus ||
                                          _addressStreetNumberFN.hasFocus ||
                                          _addressNeighborhoodFN.hasFocus)
                                      ? 230
                                      : 0,
                                ),
                              ],
                            ),
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

  Future<void> placeOrder() async {
    Dialog thisDialog = showLoadingDialog();

    bool isValidTime = await checkWorkinghours();

    if (isValidTime) {
//      Navigator.of(context, rootNavigator: false).pop();

//      String url = 'http://192.168.63.1:8080/makeorder';
      String userId = widget.thisUser['uid'];
      String coupon_id = null;

      String id = null;
      String delivery = _radioValueDelivery;
      String payment_method = _radioValuePayment;
      String payment_change = _paymentChangeController.text;
      String delivery_address = _radioValueDelivery == "delivery"
          ? returnDeliveryAddress()
          : "Retirada";
      String total = null;

      Map<String, dynamic> productsId = {};

      finalAllCartItemsMap.forEach((item) {
//      //print("Item: "+item.toString());

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

//      //print(tempMap);
      });

//      //print("productsId: "+json.encode(productsId));

      var queryParameters = {
        'date_time': '$formattedActualDateTime',
        'coupon_id': '$coupon_id',
        'id': '$id',
        'delivery': '$delivery',
        'payment_method': '$payment_method',
        'payment_change': 'Troco para $payment_change',
        'delivery_address': '$delivery_address',
        'total': '$total',
        'userId': '$userId',
        'products_id': json.encode(productsId),
      };

      var url = widget.url+"makeorder";
//      var url = "http://192.168.63.1:8080/makeorder";

      diolib.Dio dio = new diolib.Dio();
      diolib.Response apiResponse = await dio.post(url, data: queryParameters);
      //print(apiResponse.data.toString());

      Navigator.of(context, rootNavigator: false).pop();

      await widget.dbHelper.delete(cartId, "cartItems", "cartId");
      await widget.dbHelper.delete(cartId, "cart", "cartId");

      showSuccessDialog();
    } else {
      Navigator.of(context, rootNavigator: false).pop();
      showTimeErrorDialog();
    }
  }

  Widget returnAddressForm() {
    return Form(
      key: _addressFormKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(right: 5, bottom: 10),
                  child: Material(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(0.0),
                            topRight: Radius.circular(0.0))),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 0, bottom: 0),
                      child: TextFormField(
                        autofocus: false,
                        focusNode: _addressStreetFN,
                        controller: _addStreetController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Digite o Endereço.";
                          } else {
                            if (text.length < 3) {
                              return "Endereço inválido";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 0, top: 8, bottom: 8),
                            isDense: true,
                            hintText: "Endereço",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(0.0),
                            topRight: Radius.circular(30.0))),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 0, bottom: 0),
                      child: TextFormField(
                        autofocus: false,
                        focusNode: _addressStreetNumberFN,
                        controller: _addNumberController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Nº";
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 0, top: 8, bottom: 8),
                            isDense: true,
                            hintText: "Nº",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14)),
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
                  child: Material(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(0.0),
                            topRight: Radius.circular(0.0))),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 0, bottom: 0),
                      child: TextFormField(
                        autofocus: false,
                        focusNode: _addressNeighborhoodFN,
                        controller: _addNeighborhoodController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Digite o Bairro.";
                          } else {
                            if (text.length < 3) {
                              return "Bairro inválido";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 0, top: 8, bottom: 8),
                            isDense: true,
                            hintText: "Bairro",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Material(
                    elevation: 0,
                    color: Colors.grey.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(30.0),
                            topRight: Radius.circular(0.0))),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 10, right: 5, top: 0, bottom: 0),
                      child: TextFormField(
                        enabled: false,
                        autofocus: false,
                        controller: _addCityController,
                        keyboardType: TextInputType.text,
                        validator: (text) {
                          if (text.isEmpty) {
                            return "Digite a Cidade.";
                          } else {
                            if (text.length < 3) {
                              return "Cidade Inválida.";
                            }
                          }
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                                left: 0, right: 0, top: 8, bottom: 8),
                            isDense: true,
                            hintText: "Cidade",
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 14)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget returnPaymentChangeForm() {
    double deliveryTax = _radioValueDelivery == "delivery" ? double.parse(widget.aboutInfo['delivery_tax']) : 0.00;

    calculateNewTotal = totalPrice.replaceAll(",", ".");
    calculateNewTotal =
        (double.parse(calculateNewTotal) + (deliveryTax)).toStringAsFixed(2);

    calculateNewTotal = calculateNewTotal.replaceAll(".", ",");

    _paymentChangeController.addListener(() {
      if (_paymentChangeController.text.toString().length > 3) {
        if (_paymentChangeController.text.toString().substring(3) == "0,00") {
          _paymentChangeController.text = "";
        }
      }
    });

    return StatefulBuilder(builder: (context, setState) {
      return Column(
        children: <Widget>[
          Divider(
            height: 5,
          ),
          AutoSizeText(
            "Total de R\$ " + calculateNewTotal,
            style: h6,
            maxLines: 1,
          ),
          AutoSizeText(
            "Precisa de Troco?",
            style: h6,
            maxLines: 1,
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    autofocus: true,
                    onTap: () {
                      setState(() {
                        _radioNeedChange = "sim";
                        shouldShowPaymentChangeValue = true;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: "sim",
                          groupValue: _radioNeedChange,
                          onChanged: (value) {
                            setState(() {
                              _radioNeedChange = value;
                              shouldShowPaymentChangeValue = true;
                            });
                          },
                        ),
                        AutoSizeText(
                          "Sim",
                          style: h6,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    autofocus: true,
                    onTap: () {
                      setState(() {
                        _radioNeedChange = "nao";
                        shouldShowPaymentChangeValue = false;
                      });
                    },
                    child: Row(
                      children: <Widget>[
                        Radio(
                          value: "nao",
                          groupValue: _radioNeedChange,
                          onChanged: (value) {
                            setState(() {
                              _radioNeedChange = value;
                              shouldShowPaymentChangeValue = false;
                            });
                          },
                        ),
                        AutoSizeText(
                          "Não",
                          style: h6,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          shouldShowPaymentChangeValue
              ? Form(
                  key: _paymentFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Material(
                          elevation: 0,
                          color: Colors.grey.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(30.0),
                                  topRight: Radius.circular(30.0))),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 5, top: 0, bottom: 0),
                            child: TextFormField(
                              focusNode: _paymentChangeFN,
                              autofocus: false,
                              controller: _paymentChangeController,
                              inputFormatters: [
                                WhitelistingTextInputFormatter.digitsOnly,
                                // Fit the validating format.
                                //fazer o formater para dinheiro
                                CurrencyInputFormatter()
                              ],
                              keyboardType: TextInputType.number,
                              validator: (text) {
                                if (text.isEmpty) {
                                  return "Troco para quanto?";
                                }
                              },
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                      left: 0, right: 0, top: 8, bottom: 8),
                                  isDense: true,
                                  hintText: "Troco para quanto?",
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container(),
        ],
      );
    });
  }

  String returnDeliveryAddress() {
    String retorno = _radioValueAddress == "userAddress"
        ? widget.thisUser['street'] +
            ", " +
            widget.thisUser['streetNumber'] +
            "-" +
            widget.thisUser['neighborhood'] +
            "-" +
            widget.thisUser['city']
        : _addStreetController.text +
            ", " +
            _addNumberController.text +
            "-" +
            _addNeighborhoodController.text +
            "-" +
            _addCityController.text;
    return retorno;
  }

  void cancelPurchaseDialog() {
    //fecha o próprio dialog
    Navigator.of(context, rootNavigator: true).pop();

    _radioValueDelivery = "withdraw";
    _radioNeedChange = "sim";
    _radioValueAddress = "userAddress";
    _radioValuePayment = "credit_card";

    _paymentChangeController.text = "";
    _addStreetController.text = "";
    _addNumberController.text = "";
    _addNeighborhoodController.text = "";
    _addCityController.text = "";

//    _paymentChangeController.updateValue(0.0);
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      //print(true);
      return newValue;
    }

    double value = double.parse(newValue.text);

    final formatter = NumberFormat.simpleCurrency(locale: "pt_Br");

    String newText = formatter.format(value / 100);

    return newValue.copyWith(
        text: newText,
        selection: new TextSelection.collapsed(offset: newText.length));
  }
}
