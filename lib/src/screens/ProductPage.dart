import 'dart:math';

import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/partials.dart';
import '../shared/buttons.dart';

import 'ChoosePizzaDialog.dart';
import 'ChoosePizzaEdgeDialog.dart';

class ProductPage extends StatefulWidget {
  final String pageTitle;
  final String category;
  final Product productData;

  ProductPage({Key key, this.pageTitle, this.productData, this.category})
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

  String brotoPrice_global;
  String inteiraPrice_global;

  Product global_pizzaEdgeChosen;
  double global_previous_pizzaEdgeBrotoPrice = 0;
  double global_previous_pizzaEdgeinteiraPrice = 0;
  Product global_product;
  String observations;
  bool hasObservations = false;

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
          title: Text(widget.productData.description, style: h2),
        ),
        body: ListView(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Center(
                              child: Text(widget.productData.description,
                                  style: h4)),
                          Align(
                              alignment: Alignment.center,
                              child: checkIngredients(widget.productData)),
                          checkNotes(widget.productData),
                          widget.category.contains("Pizza")
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
                                        borderSide:
                                            BorderSide(color: Colors.black38),
                                        onPressed: () {
                                          setState(() {
                                            _quantity += 1;
                                          });
                                        },
                                        child: Icon(Icons.add),
                                      ),
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 20, right: 20),
                                      child:
                                          Text(_quantity.toString(), style: h3),
                                    ),
                                    Container(
                                      width: 55,
                                      height: 55,
                                      child: OutlineButton(
                                        borderSide:
                                            BorderSide(color: Colors.black38),
                                        onPressed: () {
                                          setState(() {
                                            if (_quantity == 1) return;
                                            _quantity -= 1;
                                          });
                                        },
                                        child: Icon(Icons.remove),
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
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: TextField(
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
                            margin: EdgeInsets.only(top:10),
                            child: froyoFlatBtn('Adicionar ao Pedido', () {}),
                          )
                        ],
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
        ));
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
        child: Text(product.notes, style: foodNotesText),
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
      child: new Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 50),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: new Text("Broto", style: h4),
                  ),
                  new Container(
                    child: new Text(
                        "R\$ " + brotoPrice_global.replaceAll(".", ","),
                        style: h4),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 20),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Container(
                    child: new Text("Inteira", style: h4),
                  ),
                  new Container(
                    child: new Text(
                        "R\$ " + inteiraPrice_global.replaceAll(".", ","),
                        style: h4),
                  )
                ],
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
              showDialog(
                  context: context,
                  builder: (context) {
                    return CupertinoAlertDialog(
                      title: Text('Erro'),
                      content: Text('Por favor, escolha os sabores da Pizza'),
                      actions: <Widget>[
                        FlatButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('Ok')),
                      ],
                    );
                  });
            } else {
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
                            brotoPrice_global =
                                (double.parse(brotoPrice_global) -
                                        global_previous_pizzaEdgeBrotoPrice)
                                    .toStringAsFixed(2);

                            inteiraPrice_global =
                                (double.parse(inteiraPrice_global) -
                                        global_previous_pizzaEdgeinteiraPrice)
                                    .toStringAsFixed(2);

                            global_previous_pizzaEdgeBrotoPrice =
                                double.parse(pizzaEdgeToReturn.price_broto);
                            global_previous_pizzaEdgeinteiraPrice =
                                double.parse(pizzaEdgeToReturn.price_inteira);

                            setState(() {
                              brotoPrice_global =
                                  (double.parse(brotoPrice_global) +
                                          double.parse(
                                              pizzaEdgeToReturn.price_broto))
                                      .toStringAsFixed(2);

                              inteiraPrice_global =
                                  (double.parse(inteiraPrice_global) +
                                          double.parse(
                                              pizzaEdgeToReturn.price_inteira))
                                      .toStringAsFixed(2);
                            });
                          } else {
                            //remover borda
                            setState(() {
                              global_pizzaEdgeChosen = pizzaEdgeToReturn;
                              brotoPrice_global =
                                  (double.parse(brotoPrice_global) -
                                          global_previous_pizzaEdgeBrotoPrice)
                                      .toStringAsFixed(2);

                              inteiraPrice_global =
                                  (double.parse(inteiraPrice_global) -
                                          global_previous_pizzaEdgeinteiraPrice)
                                      .toStringAsFixed(2);
                            });

                            global_previous_pizzaEdgeBrotoPrice = 0;
                            global_previous_pizzaEdgeinteiraPrice = 0;
                          }
                        }
                      }
                    },
                  );

                  return dialog;
                },
              );
            }
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
                    double maximum_broto = max(
                        double.parse(product1ToReturn.price_broto),
                        double.parse(product2ToReturn.price_broto));
                    double maximum_inteira = max(
                        double.parse(product1ToReturn.price_inteira),
                        double.parse(product2ToReturn.price_inteira));

                    setState(() {
                      brotoPrice_global = maximum_broto.toStringAsFixed(2);
                    });

                    setState(() {
                      inteiraPrice_global = maximum_inteira.toStringAsFixed(2);
                    });
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
      return foodItemFlavorChosen(
          "two_flavored_pizzas", context, product1ToReturn);
    } else if (product2ToReturn != null) {
      return foodItemFlavorChosen(
          "two_flavored_pizzas", context, product2ToReturn);
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
        global_pizzaEdgeChosen.description =
            "Borda de " + global_pizzaEdgeChosen.description;
        return foodItemFlavorChosen(
            "pizza_edges", context, global_pizzaEdgeChosen);
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

  Widget foodItemFlavorChosen(
      String category, BuildContext context, Product product,
      {double imgWidth, onTapped, bool isProductPage = false}) {
    return Container(
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
            child: Stack(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(product.description, style: chooseFlavorFoodNameText),
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
        child:
            Text(product.ingredients, style: chooseFlavorFoodingredientsText),
      );
    } else {
      retorno = Container(
        width: MediaQuery.of(context).size.width / 2,
        child: Text("", style: chooseFlavorFoodingredientsText),
      );
    }

    return retorno;
  }
}
