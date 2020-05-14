import 'dart:math';

import 'package:dom_marino_app/src/models/cart_item_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:dom_marino_app/src/shared/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/partials.dart';
import '../shared/buttons.dart';

import 'ChoosePizzaDialog.dart';
import 'ChoosePizzaEdgeDialog.dart';

class ProductPage extends StatefulWidget {
  final String pageTitle;
  final String category;
  final String categoryName;
  final Product productData;
  final dbHelper;
  final FirebaseUser user;

  ProductPage(
      {Key key,
      this.pageTitle,
      this.productData,
      this.category,
      this.categoryName,
      this.dbHelper,
      this.user})
      : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _quantity = 1;

  Widget firstFlavorChosen;
  Widget secondFlavorChosen;

  Product product1ToReturn;
  Product product2ToReturn;

  Product product1CategoryName;
  Product product2CategoryName;

  String brotoPrice_global;
  String inteiraPrice_global;

  Product global_pizzaEdgeChosen;
  double global_previous_pizzaEdgeBrotoPrice = 0;
  double global_previous_pizzaEdgeinteiraPrice = 0;
  Product global_product;
  String observations;
  bool hasObservations = false;
  String sizePriceSelected = "";

  BuildContext globalContext;

  TextEditingController observationsController = new TextEditingController();


  @override
  void initState() {
    sizePriceSelected = "";
    print(widget.productData.id);
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
          title: Text(widget.productData.description, style: h2),
        ),
        body: new Builder(builder: (BuildContext context) {
          globalContext = context;
          return ListView(
            children: <Widget>[
              Container(
                //container de fora
                color: primaryColor,
                margin: EdgeInsets.only(top: 20),
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 100, bottom: 100),
                        padding: EdgeInsets.only(
                            top: 60, bottom: 20, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: getPageColumn(),
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
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 180,
                        //box de todos os conteudos da imagem na pagina do produto
                        child: foodItem(context, widget.productData,
                            isProductPage: true,
                            onTapped: () {},
                            imgWidth: 200,
                            onLike: () {}),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        }));
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

  Widget checkNotes(Product product) {
    var retorno;

    if (product.notes != null && product.notes != "") {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text(
          product.notes,
          style: foodNotesText,
          textAlign: TextAlign.justify,
        ),
      );
    } else {
      retorno = Container();
    }

    return retorno;
  }

  Widget checkIngredients(product) {
    global_product = product;
    var retorno;

    if (!product.description.contains("Escolha")) {
      if (product.ingredients != null && product.ingredients != "") {
        retorno = Text(product.ingredients, style: foodNotesText);
      } else {
        retorno = Container();
      }
    } else {
      firstFlavorChosen = getFlavorButton("1º");
      secondFlavorChosen = getFlavorButton("2º");

      retorno = Column(
        children: <Widget>[
//            Text("Escolha os 2 Sabores da Pizza:", style: foodNotesText),
          firstFlavorChosen,
          secondFlavorChosen,
        ],
      );
    }

    return retorno;
  }

  Widget getProductPrice(Product product) {
    String retorno;
    if (!product.description.contains("Escolha")) {
      if (product.price != null && product.price != "") {
        retorno = "R\$ " + product.price.replaceAll(".", ",");
        return Text(retorno, style: foodNameText);
      }

      if (product.price_broto != null) {
        if (product1ToReturn == null && product2ToReturn == null) {
          inteiraPrice_global = product.price_inteira;
          brotoPrice_global = product.price_broto;
        }

        return generatePricesGrid();
      }
    } else {
      if (product1ToReturn == null && product2ToReturn == null) {
        inteiraPrice_global = product.price_inteira;
        brotoPrice_global = product.price_broto;
      }
      return generatePricesGrid();
    }
  }

  Widget generatePricesGrid() {
    return new Container(
      margin: EdgeInsets.only(top: 10),
      child: new Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sizePriceSelected = "Broto";
                });
              },
              child: Container(
                margin: EdgeInsets.only(right: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  border: Border.all(
                    color: (sizePriceSelected == "" ||
                            sizePriceSelected == "Inteira")
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      child: new Text("Broto",
                          style: (sizePriceSelected == "" ||
                                  sizePriceSelected == "Inteira")
                              ? noneItemText
                              : h4),
                    ),
                    new Container(
                      child: new Text(
                          "R\$ " + brotoPrice_global.replaceAll(".", ","),
                          style: (sizePriceSelected == "" ||
                                  sizePriceSelected == "Inteira")
                              ? noneItemText
                              : h4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  sizePriceSelected = "Inteira";
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  border: Border.all(
                    color: (sizePriceSelected == "" ||
                            sizePriceSelected == "Broto")
                        ? Colors.grey[500]
                        : Colors.black,
                  ),
                ),
                margin: EdgeInsets.only(left: 5),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      child: new Text("Inteira",
                          style: (sizePriceSelected == "" ||
                                  sizePriceSelected == "Broto")
                              ? noneItemText
                              : h4),
                    ),
                    new Container(
                      child: new Text(
                          "R\$ " + inteiraPrice_global.replaceAll(".", ","),
                          style: (sizePriceSelected == "" ||
                                  sizePriceSelected == "Broto")
                              ? noneItemText
                              : h4),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getEdgesButton(product) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (product.description.contains("Escolha")) {
            if (product1ToReturn == null || product2ToReturn == null) {
              Scaffold.of(globalContext).showSnackBar(
                  SnackBar(content: Text("Por favor, escolha os sabores da Pizza."),
                    backgroundColor: Colors.redAccent,
                    duration: Duration(seconds: 3),)
              );
            } else {
              showPizzaEdgeDialog();
            }
          } else if (widget.category.contains("Pizza")) {
            showPizzaEdgeDialog();
          }
        },
        child: Card(
          color: Colors.white.withOpacity(0.65),
          //Color(0xfffff2ca).withOpacity(0.65),
          elevation: 5,
          child: pizzaEdgeChosen(),
        ),
      ),
    );
  }

  Widget getFlavorButton(String flavorOrder) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              Product productToReturn =
                  flavorOrder == "1º" ? product1ToReturn : product2ToReturn;
              ChoosePizzaDialog dialog = ChoosePizzaDialog(
                returnedProduct: productToReturn,
                onReturnedProductChanged: (productToReturn) {
                  if (flavorOrder == "1º") {
                    setState(() {
                      product1ToReturn = productToReturn;
                    });
                  } else {
                    setState(() {
                      product2ToReturn = productToReturn;
                    });
                  }
                  if (brotoPrice_global != "--") {

                    if (product2ToReturn!=null) {
                      double maximum_broto = max(
                          double.parse(product1ToReturn.price_broto),
                          double.parse(product2ToReturn.price_broto));
                      double maximum_inteira = max(
                          double.parse(product1ToReturn.price_inteira),
                          double.parse(product2ToReturn.price_inteira));

                      setState(() {
                        brotoPrice_global = maximum_broto.toStringAsFixed(2);
                        inteiraPrice_global = maximum_inteira.toStringAsFixed(2);
                      });
                    }else{
                      setState(() {
                        brotoPrice_global = productToReturn.price_broto;
                        inteiraPrice_global = productToReturn.price_inteira;
                      });
                    }

                  } else {
                    setState(() {
                      brotoPrice_global = productToReturn.price_broto;
                      inteiraPrice_global = productToReturn.price_inteira;
                    });
                  }
//                  print(productToReturn.description);
                },
                title: "Success",
                description: "",
                buttonText: "Okay",
              );

              return dialog;
            },
          );
        },
        child: Card(
          color: Colors.white.withOpacity(0.65),
          //Color(0xfffff2ca).withOpacity(0.65),
          elevation: 5,
          child: flavorChosen(flavorOrder),
        ),
      ),
    );
  }

  Widget flavorChosen(String flavorOrder) {
    Widget retorno;

    if (flavorOrder == "1º" && product1ToReturn != null) {
//      firstFlavorChosen =
      return foodItemFlavorChosen("two_flavored_pizzas", context,
          product1ToReturn, product1ToReturn.description);
    } else if (product2ToReturn != null) {
      return foodItemFlavorChosen("two_flavored_pizzas", context,
          product2ToReturn, product2ToReturn.description);
//      secondFlavorChosen =
    }

    retorno = Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      child: Center(
          child: Text("Clique para Escolher o $flavorOrder Sabor da Pizza:",
              style: foodIngredientsText)),
    );

    return retorno;
  }

  Widget pizzaEdgeChosen() {
    Widget retorno;

    if (global_pizzaEdgeChosen != null) {
//      firstFlavorChosen =
      if (global_pizzaEdgeChosen.description != "Nenhuma Borda") {
        String description = "Borda de " + global_pizzaEdgeChosen.description;
        return foodItemFlavorChosen(
            "pizza_edges", context, global_pizzaEdgeChosen, description);
      }
    }

    retorno = Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      child: Center(
          child: Text("Adicionar Borda Recheada:", style: foodIngredientsText)),
    );

    return retorno;
  }

  Widget foodItemFlavorChosen(String category, BuildContext context,
      Product product, String description,
      {double imgWidth, onTapped, bool isProductPage = false}) {
    return new Container(
      width: MediaQuery.of(context).size.width,
      child: Wrap(
        direction: Axis.horizontal,
        spacing: 8.0,
        children: <Widget>[
          Container(
            //quadrado branco fictício do conjunto imagem
            width: 35,
            height: 35,
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
                        tag: product.description + (product.id),
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
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(description, style: chooseFlavorFoodNameText),
                    checkIngredientsFlavorChosen(context, product),
//                  checkNotes(context, product),
//                  checkSizes(context, product),
//                  getProductPrice(product),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget checkIngredientsFlavorChosen(BuildContext context, product) {
    var retorno;

    if (product.ingredients != null && product.ingredients != "") {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text(
          product.ingredients,
          style: chooseFlavorFoodingredientsText,
          textAlign: TextAlign.justify,
        ),
      );
    } else {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text("", style: chooseFlavorFoodingredientsText),
      );
    }

    return retorno;
  }

  void showPizzaEdgeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Product pizzaEdgeToReturn = global_pizzaEdgeChosen;
        ChoosePizzaEdgeDialog dialog = ChoosePizzaEdgeDialog(
          returnedProduct: pizzaEdgeToReturn,
          onReturnedProductChanged: (pizzaEdgeToReturn) {
            global_pizzaEdgeChosen = pizzaEdgeToReturn;

            if (pizzaEdgeToReturn != null) {
              if (pizzaEdgeToReturn.price_broto != "--" &&
                  pizzaEdgeToReturn.price_inteira != "--") {
                if (pizzaEdgeToReturn.price_broto != null) {
                  if (widget.productData.description.contains("Escolha")) {
                    brotoPrice_global = (double.parse(brotoPrice_global) -
                            global_previous_pizzaEdgeBrotoPrice)
                        .toStringAsFixed(2);

                    inteiraPrice_global = (double.parse(inteiraPrice_global) -
                            global_previous_pizzaEdgeinteiraPrice)
                        .toStringAsFixed(2);

                    global_previous_pizzaEdgeBrotoPrice =
                        double.parse(pizzaEdgeToReturn.price_broto);
                    global_previous_pizzaEdgeinteiraPrice =
                        double.parse(pizzaEdgeToReturn.price_inteira);

                    setState(() {
                      brotoPrice_global = (double.parse(brotoPrice_global) +
                              double.parse(pizzaEdgeToReturn.price_broto))
                          .toStringAsFixed(2);

                      inteiraPrice_global = (double.parse(inteiraPrice_global) +
                              double.parse(pizzaEdgeToReturn.price_inteira))
                          .toStringAsFixed(2);
                    });
                  } else {
                    //description não contém escolha

                    widget.productData.price_broto =
                        (double.parse(widget.productData.price_broto) -
                                global_previous_pizzaEdgeBrotoPrice)
                            .toStringAsFixed(2);

                    widget.productData.price_inteira =
                        (double.parse(widget.productData.price_inteira) -
                                global_previous_pizzaEdgeinteiraPrice)
                            .toStringAsFixed(2);

                    global_previous_pizzaEdgeBrotoPrice =
                        double.parse(pizzaEdgeToReturn.price_broto);
                    global_previous_pizzaEdgeinteiraPrice =
                        double.parse(pizzaEdgeToReturn.price_inteira);

                    setState(() {
                      widget.productData.price_broto =
                          (double.parse(widget.productData.price_broto) +
                                  double.parse(pizzaEdgeToReturn.price_broto))
                              .toStringAsFixed(2);

                      widget.productData.price_inteira =
                          (double.parse(widget.productData.price_inteira) +
                                  double.parse(pizzaEdgeToReturn.price_inteira))
                              .toStringAsFixed(2);
                    });
                  }
                } else {
                  //remover borda
                  if (widget.productData.description.contains("Escolha")) {
                    setState(() {
                      global_pizzaEdgeChosen = pizzaEdgeToReturn;
                      brotoPrice_global = (double.parse(brotoPrice_global) -
                              global_previous_pizzaEdgeBrotoPrice)
                          .toStringAsFixed(2);

                      inteiraPrice_global = (double.parse(inteiraPrice_global) -
                              global_previous_pizzaEdgeinteiraPrice)
                          .toStringAsFixed(2);
                    });

                    global_previous_pizzaEdgeBrotoPrice = 0;
                    global_previous_pizzaEdgeinteiraPrice = 0;
                  } else {
                    //description nao contem Escolha
                    setState(() {
                      global_pizzaEdgeChosen = pizzaEdgeToReturn;
                      widget.productData.price_broto =
                          (double.parse(widget.productData.price_broto) -
                                  global_previous_pizzaEdgeBrotoPrice)
                              .toStringAsFixed(2);

                      widget.productData.price_inteira =
                          (double.parse(widget.productData.price_inteira) -
                                  global_previous_pizzaEdgeinteiraPrice)
                              .toStringAsFixed(2);
                    });

                    global_previous_pizzaEdgeBrotoPrice = 0;
                    global_previous_pizzaEdgeinteiraPrice = 0;
                  }
                }
              }
            }
          },
        );

        return dialog;
      },
    );
  }

  bool isCategoryAllowed(String category) {
    return (category.contains("Promoções") || category.contains("Borda"));
  }

  Widget getPageColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(child: Text(widget.productData.description, style: h4)),
        widget.productData.size==null?Container():Center(child: Text(widget.productData.size, style: h6)),
        Align(
            alignment: Alignment.center,
            child: checkIngredients(widget.productData)),
        checkNotes(widget.productData),
        (widget.category.contains("Pizza") && !widget.category.contains("Doce"))
            ? getEdgesButton(widget.productData)
            : Container(),
        Center(child: getProductPrice(widget.productData)),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: Column(
            children: <Widget>[
              Container(
                child: Text('Quantidade', style: h6),
                margin: EdgeInsets.only(bottom: 15),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 55,
                    height: 55,
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.black38),
                      onPressed: () {
                        setState(() {
                          if (_quantity == 1) return;
                          _quantity -= 1;
                        });
                      },
                      child: Icon(Icons.remove),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20),
                    child: Text(_quantity.toString(), style: h3),
                  ),
                  Container(
                    width: 55,
                    height: 55,
                    child: OutlineButton(
                      borderSide: BorderSide(color: Colors.black38),
                      onPressed: () {
                        setState(() {
                          _quantity += 1;
                        });
                      },
                      child: Icon(Icons.add),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
        widget.category.contains("Pizza")
            ? Wrap(
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.start,
                children: <Widget>[
                  Checkbox(
                    value: hasObservations,
                    onChanged: (bool value) {
                      setState(() {
                        hasObservations = value;
                      });
                    },
                  ),
                  Text('Observações', style: h6),
                ],
              )
            : Container(),
        widget.category.contains("Pizza")
            ? Card(
                color: Colors.white.withOpacity(0.65),
                //Color(0xfffff2ca).withOpacity(0.65),
                elevation: 5,
                child: hasObservations
                    ? Container(
                        padding: EdgeInsets.all(10),
                        height: 70,
                        width: MediaQuery.of(context).size.width,
                        child: TextField(
                            controller: observationsController,
                            maxLength: 40,
                            style: new TextStyle(
                                fontSize: 14.0,
                                height: 2.0,
                                color: Colors.black)),
                      )
                    : Container(),
              )
            : Container(),
        Container(
          width: 180,
          margin: EdgeInsets.only(top: 10),
          child: froyoFlatBtn(
              'Adicionar ao Pedido',
              isCategoryAllowed(widget.category)
                  ? null
                  : widget.user != null
                      ? () async {
                          //método onClick
                          Map<String, dynamic> cartRow = {
                            DatabaseHelper.columnUserId: widget.user.uid,
                            DatabaseHelper.columnDateRegister:
                                new DateTime.now().toUtc().toString()
                          };

                          int cartId;
                          Map<String, dynamic> cart =
                              await widget.dbHelper.searchCart(widget.user.uid);

                          if (widget.category.contains("Pizza")) {
                            //se é pizza
                            if (!widget.category.contains("Sabores")) {
                              if (sizePriceSelected=="") {
                                Scaffold.of(globalContext).showSnackBar(
                                    SnackBar(content: Text("Por favor, escolha o tamanho da Pizza."),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 3),)
                                );
                              }else{
                                //se Não é two_flavored_pizza
                                checkSizeAndRunDb(cartId, cart, cartRow);
                              }
                            } else {
                              //se é Pizza de 2 Sabores
                              if (product1ToReturn == null ||
                                  product2ToReturn == null) {
                                Scaffold.of(globalContext).showSnackBar(
                                    SnackBar(content: Text("Por favor, escolha os sabores da Pizza."),
                                      backgroundColor: Colors.redAccent,
                                      duration: Duration(seconds: 3),)
                                );
                              } else {
                                if (sizePriceSelected=="") {
                                  Scaffold.of(globalContext).showSnackBar(
                                      SnackBar(content: Text("Por favor, escolha o tamanho da Pizza."),
                                        backgroundColor: Colors.redAccent,
                                        duration: Duration(seconds: 3),)
                                  );
                                }else{
                                  checkSizeAndRunDb(cartId, cart, cartRow, isTwoFlavoredPizza: true);
                                }
                              }
                            }
                          } else {
                            //se não for pizza

                            if (cart == null) {
                              cartId =
                                  await widget.dbHelper.insert(cartRow, "cart");
                            } else {
                              cartId = cart['cartId'];
                            }

                            List<Map<String, dynamic>> allCartItems =
                                await widget.dbHelper
                                    .retrieveAllCartItems(cartId);
                            int equalId = null;

                            allCartItems.forEach((item) {
                              if (item['productId'] == widget.productData.id) {
                                //se já tem item igual
                                equalId = item['cartItemsId'];
                              }
                            });

                            if (equalId != null) {
                              //se já tem item igual
                              Map<String, dynamic> productRow =
                                  await widget.dbHelper.searchCartItem(equalId);
                              Map<String, dynamic> tempProductRow = new Map();
                              tempProductRow.addAll(productRow);
                              tempProductRow["productAmount"] =
                                  tempProductRow["productAmount"] + 1;

                              await widget.dbHelper.update(
                                  tempProductRow, "cartItems", "cartItemsId");
                            } else {
                              //se ainda não tem item igual

//                              print("Size: "+widget.productData.size);

                              Map<String, dynamic> productRow = {
                                DatabaseHelper.columnCartId: cartId,
                                DatabaseHelper.columnProductId:
                                    widget.productData.id,
                                DatabaseHelper.columnProductCategory:
                                    widget.category,
                                DatabaseHelper.columnCategoryName:
                                    widget.categoryName,
                                DatabaseHelper.columnProductAmount: _quantity,
                                DatabaseHelper.columnProductObservations:
                                    observations,
                                DatabaseHelper.columnPizzaEdgeId: null,
                                DatabaseHelper.columnProductSize:
                                    widget.productData.size
                              };

                              await widget.dbHelper
                                  .insert(productRow, "cartItems");
                            }
                            Navigator.pop(context);
                          }
                        }
                      : () {
                          Navigator.pushNamed(context, '/signin');
                        }),
        )
      ],
    );
  }

  Future<void> checkSizeAndRunDb(int cartId, Map<String, dynamic> cart,
      Map<String, dynamic> cartRow, {bool isTwoFlavoredPizza}) async {
    if (sizePriceSelected == "") {
      //se não escolheu o tamanho
      Scaffold.of(globalContext).showSnackBar(
          SnackBar(content: Text("Por favor, escolha o tamanho da Pizza."),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),)
      );
    } else {
      //se tiver selecionado o tamanho

      if (isTwoFlavoredPizza!=null) {
          //é pizza de 2 sabores
          String observations = observationsController.text;
          String pizzaEdgeId =
          global_pizzaEdgeChosen != null ? global_pizzaEdgeChosen.id : null;

          if (cart == null) {
            //se não tem carrinho
            cartId = await widget.dbHelper.insert(cartRow, "cart");
          } else {
            //se já tem carrinho
            cartId = cart['cartId'];
          }

          List<Map<String, dynamic>> allCartItems =
          await widget.dbHelper.retrieveAllCartItems(cartId);
          int equalId = null;

          allCartItems.forEach((item) {
            if (item['productId'] == widget.productData.id &&
                item['pizzaEdgeId'] == pizzaEdgeId &&
                item['productSize'] == sizePriceSelected) {
              if (item['product1Id']==product1ToReturn.id||item['product1Id']==product2ToReturn.id
                  &&item['product2Id']==product1ToReturn.id||item['product2Id']==product2ToReturn.id) {
                //se já tem item igual
                equalId = item['cartItemsId'];
              }
            }
          });

          if (equalId != null) {
            //se já tem item igual
            Map<String, dynamic> productRow =
            await widget.dbHelper.searchCartItem(equalId);
            Map<String, dynamic> tempProductRow = new Map();
            tempProductRow.addAll(productRow);
            tempProductRow["productAmount"] =
                tempProductRow["productAmount"] + 1;
            await widget.dbHelper.update(
                tempProductRow, "cartItems", "cartItemsId");
          } else {
            //se ainda não tem item igual

            Map<String, dynamic> productRow = {
              DatabaseHelper.columnCartId: cartId,
              DatabaseHelper.columnProductId: widget.productData.id,
              DatabaseHelper.columnProduct1Id: product1ToReturn.id,
              DatabaseHelper.columnProduct2Id: product2ToReturn.id,
              DatabaseHelper.columnProductCategory: widget.category,
              DatabaseHelper.columnCategoryName: product1ToReturn.categoryName,
              DatabaseHelper.columnProduct2CategoryName: product2ToReturn.categoryName,
              DatabaseHelper.columnProductAmount: _quantity,
              DatabaseHelper.columnProductObservations: observations,
              DatabaseHelper.columnPizzaEdgeId: pizzaEdgeId,
              DatabaseHelper.columnProductSize: sizePriceSelected,
              DatabaseHelper.columnIsTwoFlavoredPizza: 1
            };

            await widget.dbHelper.insert(productRow, "cartItems");
          }


      }else{
        String observations = observationsController.text;
        String pizzaEdgeId =
        global_pizzaEdgeChosen != null ? global_pizzaEdgeChosen.id : null;

        if (cart == null) {
          //se não tem carrinho
          cartId = await widget.dbHelper.insert(cartRow, "cart");
        } else {
          //se já tem carrinho
          cartId = cart['cartId'];
        }

        List<Map<String, dynamic>> allCartItems =
        await widget.dbHelper.retrieveAllCartItems(cartId);
        int equalId = null;

        allCartItems.forEach((item) {
          if (item['productId'] == widget.productData.id &&
              item['pizzaEdgeId'] == pizzaEdgeId &&
              item['productSize'] == sizePriceSelected) {
            //se já tem item igual
            equalId = item['cartItemsId'];
          }
        });

        if (equalId != null) {
          //se já tem item igual
          Map<String, dynamic> productRow =
          await widget.dbHelper.searchCartItem(equalId);
          Map<String, dynamic> tempProductRow = new Map();
          tempProductRow.addAll(productRow);
          tempProductRow["productAmount"] =
              tempProductRow["productAmount"] + 1;
          await widget.dbHelper.update(
              tempProductRow, "cartItems", "cartItemsId");
        } else {
          //se ainda não tem item igual

          Map<String, dynamic> productRow = {
            DatabaseHelper.columnCartId: cartId,
            DatabaseHelper.columnProductId: widget.productData.id,
            DatabaseHelper.columnProductCategory: widget.category,
            DatabaseHelper.columnCategoryName: widget.categoryName,
            DatabaseHelper.columnProductAmount: _quantity,
            DatabaseHelper.columnProductObservations: observations,
            DatabaseHelper.columnPizzaEdgeId: pizzaEdgeId,
            DatabaseHelper.columnProductSize: sizePriceSelected
          };

          await widget.dbHelper.insert(productRow, "cartItems");
        }
      }
    }
    Navigator.pop(globalContext);
  }
}
