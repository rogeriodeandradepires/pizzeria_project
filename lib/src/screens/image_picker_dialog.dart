import 'dart:async';
import 'package:dom_marino_app/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'image_picker_handler.dart';
import 'loginUi.dart';

class ImagePickerDialog extends StatelessWidget {
  ImagePickerHandler _listener;
  AnimationController _controller;
  BuildContext context;

  ImagePickerDialog(this._listener, this._controller);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = new CurvedAnimation(
      parent: new ReverseAnimation(_controller),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = new Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_controller == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _controller.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => new SlideTransition(
        position: _drawerDetailsPosition,
        child: new FadeTransition(
          opacity: new ReverseAnimation(_drawerContentsOpacity),
          child: this,
        ),
      ),
    );
  }

  void dispose() {
    _controller.dispose();
  }

  startTime() async {
    var _duration = new Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _controller.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return new Material(
        type: MaterialType.transparency,
        child: new Opacity(
          opacity: 1.0,
          child: new Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    roundedRectButton("Câmera", goBtnGradients, false, "images/whitecamera.png"),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onTap: () => _listener.openCamera(),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 65.0,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Stack(
                  children: <Widget>[
                    roundedRectButton("Galeria", goBtnGradients, false, "images/gallery.png"),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        onTap: () => _listener.openGallery(),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 65.0,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                      child:
                          roundedRectButton("Cancelar", goBtnGradients, false, "images/close.png"),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0)),
                          onTap: () => dismissDialog(),
                          child: Container(
                            alignment: Alignment.center,
                            width: MediaQuery.of(context).size.width / 1.2,
                            height: 65.0,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)),
                            ),
                            padding: EdgeInsets.only(top: 16, bottom: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget roundedRectButton(
      String title, List<Color> gradient, bool isEndIconVisible, String image) {
    return Builder(builder: (BuildContext mContext) {
      return Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Stack(
          alignment: Alignment(1.0, 0.0),
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: MediaQuery.of(mContext).size.width / 1.2,
              decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width:title=="Cancelar"?30:35,
                      height: title=="Cancelar"?30:35,
                      margin: EdgeInsets.only(right: 20),
                      child: Image.asset(image, fit: BoxFit.scaleDown,),
                  ),
                  Text(title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500)),
                ],
              ),
              padding: EdgeInsets.only(top: 16, bottom: 16),
            ),
          ],
        ),
      );
    });
  }
}
