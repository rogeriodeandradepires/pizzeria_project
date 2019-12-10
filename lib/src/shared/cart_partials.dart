import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:flutter/material.dart';
import '../shared/styles.dart';

Widget cartItem(BuildContext context, Product product,
    {String size,
    int ammount,
    double imgWidth,
    onLike,
    onTapped,
    bool isProductPage = false}) {
  return Card(
    color: Color(0xfffff2ca).withOpacity(0.65),
    elevation: 5,
    //Color.fromRGBO(255, 0, 0, 0.5),
    child: getCartItemContainer(context, onLike, imgWidth, product, isProductPage,
        onTapped, size, ammount),
  );
}

getCartItemContainer(BuildContext context, onLike, double imgWidth, Product product,
    bool isProductPage, onTapped, String size, int ammount) {
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
        width: MediaQuery.of(context).size.width * 0.65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(product.description, style: minorFoodNameText),
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
                    getItemPrice(size, product),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap:onTapped,
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
                      child: Text(ammount.toString(), style: h3),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4.0)),
                        border: Border.all(color: Colors.grey[500]),
                      ),
                      child: Icon(Icons.add),
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

Widget getItemPrice(String size, Product product) {
  if (size == null) {
    return Text(
      "R\$ " + product.price.replaceAll(".", ","),
      style: minorCartItemText,
    );
  } else {
    if (size == "Broto") {
      return Text(
        "R\$ " + product.price_broto.replaceAll(".", ","),
        style: minorCartItemText,
      );
    } else {
      return Text(
        "R\$ " + product.price_inteira.replaceAll(".", ","),
        style: minorCartItemText,
      );
    }
  }
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
        child: new Text("R\$ 0,00", // + product.price,//.replaceAll(".", ","),
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

Widget generatePricesGrid(String price_broto, String price_inteira) {
  return new Container(
    child: new Row(
      children: <Widget>[
        Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                child: new Text("Broto", style: foodNameText),
              ),
              new Container(
                child: new Text("R\$ " + price_broto.replaceAll(".", ","),
                    style: foodNameText),
              ),
            ],
          ),
        ),
        Expanded(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                child: new Text("Inteira", style: foodNameText),
              ),
              new Container(
                child: new Text("R\$ " + price_inteira.replaceAll(".", ","),
                    style: foodNameText),
              )
            ],
          ),
        )
      ],
    ),
  );
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

Widget checkIngredients(BuildContext context, product) {
  var retorno;

  if (product.ingredients != null && product.ingredients != "") {
    retorno = Container(
      width: MediaQuery.of(context).size.width / 2,
      child: Text(
        product.ingredients,
        style: foodNotesText,
        textAlign: TextAlign.justify,
      ),
    );
  } else {
    retorno = Container();
  }

  return retorno;
}
