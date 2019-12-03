import 'dart:math';

import 'package:dom_marino_app/src/models/cart_result_model.dart';
import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/partials.dart';
import '../shared/buttons.dart';

import 'ChoosePizzaDialog.dart';
import 'ChoosePizzaEdgeDialog.dart';

class CartPage extends StatefulWidget {
  final dbHelper;
  final FirebaseUser user;

  CartPage({Key key, this.dbHelper, this.user})
      : super(key: key);

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
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("R\$ 43,00", style: cart_title),
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
                      padding: EdgeInsets.only(
                          top: 10, left: 10),
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Stack(
                        children: <Widget>[
                          Center(child: Text("Items",style: h4)),
                          Positioned(
                            bottom: -5,
                            child: Container(
                              width: MediaQuery.of(context).size.width*0.8,
                              margin: EdgeInsets.only(bottom: 10),
                              child: froyoFlatBtn(
                                  'Pagar',(){

                              }),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                            ],
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

  bool isCategoryAllowed(String category) {
    return (category.contains("Promoções") || category.contains("Borda"));
  }

}
