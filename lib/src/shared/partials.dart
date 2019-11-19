import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:flutter/material.dart';
import '../shared/ProductOld.dart';
import '../shared/colors.dart';
import '../shared/styles.dart';

Widget foodItem(BuildContext context, Product product,
    {double imgWidth, onLike, onTapped, bool isProductPage = false}) {
  return !isProductPage
      ? InkWell(
          onTap: onTapped,
          child: Card(
            color: Color(0xfffff2ca).withOpacity(0.65),
            elevation: 5,
            //Color.fromRGBO(255, 0, 0, 0.5),
            child: getContainer(
                context, onLike, imgWidth, product, isProductPage, onTapped),
          ))
      : getContainer(
          context, onLike, imgWidth, product, isProductPage, onTapped);
}

getContainer(BuildContext context, onLike, double imgWidth, Product product,
    bool isProductPage, onTapped) {

  return Wrap(
    direction: Axis.horizontal,
    spacing: 8.0,
    children: <Widget>[
      Container(
        //quadrado branco fictício do conjunto imagem
        width: (!isProductPage) ? 100 : 200,
        height: (!isProductPage) ? 100 : 200,
        margin: EdgeInsets.only(left: (!isProductPage) ? 0 : 15),
        child: Stack(
          // para fazer a sombra
          children: <Widget>[
            Container(
                //quadrado branco da imagem para fazer a sombra
                margin: EdgeInsets.only(left: (!isProductPage) ? 0 : 10),
                width: (!isProductPage) ? 100 : 150,
                height: (!isProductPage) ? 100 : 150,
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
//            Positioned(
//                // descontos
//                top: 10,
//                left: 10,
//                child: (product.promotional_price!= null)
//                    ? Container(
//                        padding: EdgeInsets.only(
//                            top: 5, left: 10, right: 10, bottom: 5),
//                        decoration: BoxDecoration(
//                            color: Colors.grey[600],
//                            borderRadius: BorderRadius.circular(50)),
//                        child: Text('-' + product.promotional_price + '%',
//                            style: TextStyle(
//                                color: Colors.white,
//                                fontWeight: FontWeight.w700)),
//                      )
//                    : SizedBox(width: 0))
          ],
        ),
      ),
      Container(
        width: MediaQuery.of(context).size.width * 0.65,
        child: Stack(
          children: <Widget>[
            (!isProductPage)
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(product.description, style: minorFoodNameText),
                      checkIngredients(context, product),
                      checkNotes(context, product),
                      checkSizes(context, product),
                      getProductPrice(product),
                    ],
                  )
                : Text(' '),
            product.description.contains("Escolha")
                ? Container() //se for
                : product.description.contains("RODÍZIO")
                    ? Container()
                    : Positioned(
                        right: -25,
                        top: -5,
                        child: FlatButton(
                          padding: EdgeInsets.all(5),
                          shape: CircleBorder(),
                          onPressed: onLike,
                          child: Icon(
                            (product.userLiked != null)
                                ? (product.userLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border)
                                : (Icons.favorite_border),
                            color: (product.userLiked != null)
                                ? (product.userLiked ? Colors.red : darkText)
                                : darkText,
                            size: 25,
                          ),
                        ),
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
      return Text(retorno, style: foodNameText);
    }

    if (product.price_broto != null) {
      return generatePricesGrid(product.price_broto, product.price_inteira);
    }
  } else {
    return Text(product.price, style: foodNameText);
  }
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
      child: Text(product.notes, style: foodNotesText),
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
      child: Text(product.ingredients, style: foodNotesText),
    );
  } else {
    retorno = Container();
  }

  return retorno;
}
