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
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';
import '../shared/buttons.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart' as diolib;

class AboutPage extends StatefulWidget {
  AboutPage({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var globalContext;

  @override
  Future<void> initState() {}

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
        title: Text("Sobre", style: h2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: 200,
              padding: EdgeInsets.only(bottom: 10),
              child: Image.asset(
                'images/logo_icon_wide_minor.png',
                fit: BoxFit.scaleDown,
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.7,
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
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (await MapLauncher.isMapAvailable(
                                MapType.google)) {
                              await MapLauncher.launchMap(
                                mapType: MapType.google,
                                coords: Coords(-21.208663, -50.437031),
                                title: "Dom Marino Pizzaria Gourmet",
                                description: "A melhor pizzaria da região.",
                              );
                            }else{
                              if (await MapLauncher.isMapAvailable(
                                  MapType.apple)) {
                                await MapLauncher.launchMap(
                                  mapType: MapType.apple,
                                  coords: Coords(-21.208663, -50.437031),
                                  title: "Dom Marino Pizzaria Gourmet",
                                  description: "A melhor pizzaria da região.",
                                );
                              }
                            }
                          },
                          child: ClipRRect(
                            borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: new BoxDecoration(
                                color: Colors.white, // border color
                                shape: BoxShape.rectangle,
                              ),
                              child: Image.asset(
                                'images/map.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            if (await MapLauncher.isMapAvailable(
                                MapType.google)) {
                              await MapLauncher.launchMap(
                                mapType: MapType.google,
                                coords: Coords(-21.208663, -50.437031),
                                title: "Dom Marino Pizzaria Gourmet",
                                description: "A melhor pizzaria da região.",
                              );
                            }else{
                              if (await MapLauncher.isMapAvailable(
                                  MapType.apple)) {
                                await MapLauncher.launchMap(
                                  mapType: MapType.apple,
                                  coords: Coords(-21.208663, -50.437031),
                                  title: "Dom Marino Pizzaria Gourmet",
                                  description: "A melhor pizzaria da região.",
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 20,
                                  child: Image.asset(
                                    'images/place.png',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: AutoSizeText(
                                    "R. Silva Jardim, 106 - Araçatuba",
                                    style: h5Snackbar,
                                    maxLines: 2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            const url = "tel:+551833042044";
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                right: 8.0, left: 8.0, bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: 20,
                                  child: Image.asset(
                                    'images/phone.png',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.6,
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: AutoSizeText(
                                    "Ligar (18) 3304-2044",
                                    style: h5Snackbar,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 20,
                              child: Image.asset(
                                'images/clock.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText("Horário de funcionamento:",
                                style: h6, maxLines: 1, textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(width: 20),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText(
                                "Dom à Sex - 19:00 às 23:30",
                                style: h5Snackbar,
                                maxLines: 1, textAlign: TextAlign.justify,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 20,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.65,
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText(
                                "Sáb - 19:00 às 0:00",
                                style: h5Snackbar,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
