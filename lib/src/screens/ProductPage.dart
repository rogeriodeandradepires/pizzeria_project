import 'package:dom_marino_app/src/models/product_result_model.dart';
import 'package:flutter/material.dart';
import '../shared/ProductOld.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/partials.dart';
import '../shared/buttons.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class ProductPage extends StatefulWidget {
  final String pageTitle;
  final Product productData;

  ProductPage({Key key, this.pageTitle, this.productData}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  double _rating = 4;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {//página grande do produto
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
              child: Center(
                child: Stack(
                  children: <Widget>[
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        margin: EdgeInsets.only(top: 100, bottom: 100),
                        padding: EdgeInsets.only(top: 60, bottom: 20, left: 10, right: 10),
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Center(child: Text(widget.productData.description, style: h4)),
                            checkIngredients(widget.productData),
                            checkNotes(widget.productData),
                            Center(child: getProductPrice(widget.productData)),
                            Center(
                              child: Container(
                                //estrelinhas
                                margin: EdgeInsets.only(top: 5, bottom: 20),
                                child: SmoothStarRating(
                                  allowHalfRating: false,
                                  onRatingChanged: (v) {
                                    setState(() {
                                      _rating = v;
                                    });
                                  },
                                  starCount: 5,
                                  rating: _rating,
                                  size: 27.0,
                                  color: Colors.orange,
                                  borderColor: Colors.orange,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10, bottom: 25),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    child: Text('Quantidade', style: h6),
                                    margin: EdgeInsets.only(bottom: 15),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                        margin: EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: Text(_quantity.toString(),
                                            style: h3),
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
                            Container(
                              width: 180,
                              child: froyoOutlineBtn('Comprar Agora', () {}),
                            ),
                            Container(
                              width: 180,
                              child:
                                  froyoFlatBtn('Adicionar ao Carrinho', () {}),
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

  Widget getProductPrice(Product product) {
    String retorno;
    if (product.price != null && product.price != "") {
      retorno = "R\$ " + product.price.replaceAll(".", ",");
      return Text(retorno, style: h4);
    }

    if (product.price_broto != null) {
      return generatePricesGrid(product.price_broto, product.price_inteira);
    }
  }

  Widget generatePricesGrid(String price_broto, String price_inteira) {
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
                    child: new Text("Broto", style:h4),
                  ),
                  new Container(
                    child: new Text("R\$ " + price_broto.replaceAll(".", ","), style:h4),
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
                    child: new Text("Inteira", style:h4),
                  ),
                  new Container(
                    child: new Text("R\$ " + price_inteira.replaceAll(".", ","), style:h4),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
  
}
