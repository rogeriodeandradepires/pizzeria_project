import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import '../shared/styles.dart';
import '../shared/colors.dart';

class AboutPage extends StatefulWidget {
  Map<String, dynamic> aboutInfo;

  AboutPage({Key key, this.aboutInfo}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var globalContext;

  @override
  Future<void> initState() {
//    WidgetsBinding.instance
//        .addPostFrameCallback((_) {
//    });
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
        title: Text("Sobre", style: h2),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: 200,
              padding: EdgeInsets.only(bottom: 10),
              child: Image.asset(
                'images/logo_minor.png',
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
                                coords: Coords(
                                    double.parse(widget.aboutInfo['latitude1']),
                                    double.parse(
                                        widget.aboutInfo['longitude1'])),
                                title: widget.aboutInfo['map_title'],
                                description:
                                    widget.aboutInfo['map_description'],
                              );
                            } else {
                              if (await MapLauncher.isMapAvailable(
                                  MapType.apple)) {
                                await MapLauncher.launchMap(
                                  mapType: MapType.apple,
                                  coords: Coords(
                                      double.parse(
                                          widget.aboutInfo['latitude1']),
                                      double.parse(
                                          widget.aboutInfo['longitude1'])),
                                  title: widget.aboutInfo['map_title'],
                                  description:
                                      widget.aboutInfo['map_description'],
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
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, bottom: 8.0, top: 8.0),
                            child: Container(
                              width: 20,
                              child: Image.asset(
                                'images/place.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          Expanded(
                            child: returnAddressColumn(),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, bottom: 8.0),
                            child: Container(
                              width: 20,
                              child: Image.asset(
                                'images/phone.png',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                          Expanded(
                            child: returnPhoneColumn(),
                          ),
                        ],
                      ),
                      widget.aboutInfo['working_hour1'] != null &&
                              widget.aboutInfo['working_hour1'] != "null"
                          ? Padding(
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
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: AutoSizeText(
                                        "Horário de funcionamento:",
                                        style: h6,
                                        maxLines: 1,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.aboutInfo['working_hour1'] != null &&
                              widget.aboutInfo['working_hour1'] != "null"
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(width: 20),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: AutoSizeText(
                                        widget.aboutInfo['working_hour1'],
                                        style: h6,
                                        maxLines: 1,
                                        textAlign: TextAlign.justify,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.aboutInfo['working_hour2'] != null &&
                              widget.aboutInfo['working_hour2'] != "null"
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 20,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: AutoSizeText(
                                        widget.aboutInfo['working_hour2'],
                                        style: h6,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.aboutInfo['working_hour3'] != null &&
                              widget.aboutInfo['working_hour3'] != "null"
                          ? Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 20,
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: AutoSizeText(
                                        widget.aboutInfo['working_hour3'],
                                        style: h6,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
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

  Widget returnAddressColumn() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: Coords(
                            double.parse(widget.aboutInfo['latitude1']),
                            double.parse(widget.aboutInfo['longitude1'])),
                        title: widget.aboutInfo['map_title'],
                        description: widget.aboutInfo['map_description'],
                      );
                    } else {
                      if (await MapLauncher.isMapAvailable(MapType.apple)) {
                        await MapLauncher.launchMap(
                          mapType: MapType.apple,
                          coords: Coords(
                              double.parse(widget.aboutInfo['latitude1']),
                              double.parse(widget.aboutInfo['longitude1'])),
                          title: widget.aboutInfo['map_title'],
                          description: widget.aboutInfo['map_description'],
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['address1'] != null &&
                            widget.aboutInfo['address1'] != "null")
                        ? AutoSizeText(
                            widget.aboutInfo['address1'] +
                                " - " +
                                widget.aboutInfo['city1'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: Coords(
                            double.parse(widget.aboutInfo['latitude2']),
                            double.parse(widget.aboutInfo['longitude2'])),
                        title: widget.aboutInfo['map_title'],
                        description: widget.aboutInfo['map_description'],
                      );
                    } else {
                      if (await MapLauncher.isMapAvailable(MapType.apple)) {
                        await MapLauncher.launchMap(
                          mapType: MapType.apple,
                          coords: Coords(
                              double.parse(widget.aboutInfo['latitude2']),
                              double.parse(widget.aboutInfo['longitude2'])),
                          title: widget.aboutInfo['map_title'],
                          description: widget.aboutInfo['map_description'],
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['address2'] != null &&
                            widget.aboutInfo['address2'] != "null")
                        ? AutoSizeText(
                            widget.aboutInfo['address2'] +
                                " - " +
                                widget.aboutInfo['city2'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    if (await MapLauncher.isMapAvailable(MapType.google)) {
                      await MapLauncher.launchMap(
                        mapType: MapType.google,
                        coords: Coords(
                            double.parse(widget.aboutInfo['latitude3']),
                            double.parse(widget.aboutInfo['longitude3'])),
                        title: widget.aboutInfo['map_title'],
                        description: widget.aboutInfo['map_description'],
                      );
                    } else {
                      if (await MapLauncher.isMapAvailable(MapType.apple)) {
                        await MapLauncher.launchMap(
                          mapType: MapType.apple,
                          coords: Coords(
                              double.parse(widget.aboutInfo['latitude3']),
                              double.parse(widget.aboutInfo['longitude3'])),
                          title: widget.aboutInfo['map_title'],
                          description: widget.aboutInfo['map_description'],
                        );
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['address3'] != null &&
                            widget.aboutInfo['address3'] != "null")
                        ? AutoSizeText(
                            widget.aboutInfo['address3'] +
                                " - " +
                                widget.aboutInfo['city3'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
        ],
      ),
    );
  }

  Widget returnPhoneColumn() {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.only(right: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    String phone1Url = widget.aboutInfo['phone1']
                        .toString()
                        .replaceAll(" ", ""); //"tel:+551833042044";
                    phone1Url = phone1Url.replaceAll("(", "");
                    phone1Url = phone1Url.replaceAll(")", "");
                    phone1Url = phone1Url.replaceAll("-", "");
                    phone1Url = "tel:+55" + phone1Url;
                    if (await canLaunch(phone1Url)) {
                      await launch(phone1Url);
                    } else {
                      throw 'Could not launch $phone1Url';
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['phone1'] != null &&
                            widget.aboutInfo['phone1'] != "null")
                        ? AutoSizeText(
                            "Ligar " + widget.aboutInfo['phone1'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    String phone2Url = widget.aboutInfo['phone2']
                        .toString()
                        .replaceAll(" ", ""); //"tel:+551833042044";
                    phone2Url = phone2Url.replaceAll("(", "");
                    phone2Url = phone2Url.replaceAll(")", "");
                    phone2Url = phone2Url.replaceAll("-", "");
                    phone2Url = "tel:+55" + phone2Url;
                    if (await canLaunch(phone2Url)) {
                      await launch(phone2Url);
                    } else {
                      throw 'Could not launch $phone2Url';
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['phone2'] != null &&
                            widget.aboutInfo['phone2'] != "null")
                        ? AutoSizeText(
                            widget.aboutInfo['phone2'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
          Material(
              color: Colors.transparent,
              child: InkWell(
                  onTap: () async {
                    String phone3Url = widget.aboutInfo['phone3']
                        .toString()
                        .replaceAll(" ", ""); //"tel:+551833042044";
                    phone3Url = phone3Url.replaceAll("(", "");
                    phone3Url = phone3Url.replaceAll(")", "");
                    phone3Url = phone3Url.replaceAll("-", "");
                    phone3Url = "tel:+55" + phone3Url;
                    if (await canLaunch(phone3Url)) {
                      await launch(phone3Url);
                    } else {
                      throw 'Could not launch $phone3Url';
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: (widget.aboutInfo['phone3'] != null &&
                            widget.aboutInfo['phone3'] != "null")
                        ? AutoSizeText(
                            widget.aboutInfo['phone3'],
                            style: h6,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        : Container(),
                  ))),
        ],
      ),
    );
  }
}
