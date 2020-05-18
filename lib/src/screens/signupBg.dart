import 'dart:io';

import 'package:dom_marino_app/src/screens/signInUi.dart';
import 'package:flutter/material.dart';

class SignupBg extends StatefulWidget {
  Function() thisOnTap;
  File image;
  String imgUrl;

  SignupBg(this.imgUrl, this.thisOnTap, this.image);

  @override
  _SignupBgState createState() => _SignupBgState();
}

class _SignupBgState extends State<SignupBg> {

//  void setImage(File thisImage){
//    setState(() {
//      this.widget.image = thisImage;
//    });
//  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/main_bg.png"), fit: BoxFit.cover)),//
      child: Column(
          children: <Widget>[
            Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                WavyHeader(),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Stack(
                    children: <Widget>[
                      Container(
                        width: 120.0,
                        height: 120.0,
                        padding: const EdgeInsets.all(8.0), // borde width
                        decoration: new BoxDecoration(
                          color: Colors.white, // border color
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 60.0,
                          backgroundColor: Colors.transparent,
                          backgroundImage: this.widget.image != null ? FileImage(this.widget.image):this.widget.imgUrl!=null?NetworkImage(this.widget.imgUrl):AssetImage('images/avatar.png'),
                        ),
                      ),
                      Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: this.widget.thisOnTap,
                            customBorder: new CircleBorder(),
                            child: CircleAvatar(
                                radius: 60.0,
                              backgroundColor: Colors.transparent,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
              ),
            ),
            Stack(
              alignment: Alignment.bottomLeft,
              children: <Widget>[
                WavyFooter(),
                CirclePink(),
                CircleYellow(),
              ],
            )
          ],
        ),
    );
  }
}

const List<Color> orangeGradients = [
  Color(0xFF391d11),
  Color(0xFF643621),
  Color(0xFF643124),
];

const List<Color> aquaGradients = [
  Color(0xFF5AEAF1),
  Color(0xFF8EF7DA),
];

class WavyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: TopWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: orangeGradients,
              begin: Alignment.topLeft,
              end: Alignment.center),
        ),
        height: MediaQuery.of(context).size.height / 3.8,
      ),
    );
  }
}

class WavyFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: FooterWaveClipper(),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: goBtnGradients,
              begin: Alignment.center,
              end: Alignment.bottomRight),
        ),
        height: MediaQuery.of(context).size.height / 3,
      ),
    );
  }
}

class CirclePink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-70.0, 90.0),
      child: Material(
        color: Color(0xFF391d11),
        child: Padding(padding: EdgeInsets.all(120)),
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 15.0)),
      ),
    );
  }
}

class CircleYellow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0.0, 210.0),
      child: Material(
        color: Color(0xFF643621),
        child: Padding(padding: EdgeInsets.all(140)),
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 15.0)),
      ),
    );
  }
}

class TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // This is where we decide what part of our image is going to be visible.
    var path = Path();
    path.lineTo(0.0, size.height);

    var firstControlPoint = new Offset(size.width / 7, size.height - 30);
    var firstEndPoint = new Offset(size.width / 6, size.height / 1.5);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width / 5, size.height / 4);
    var secondEndPoint = Offset(size.width / 1.5, size.height / 5);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    var thirdControlPoint =
        Offset(size.width - (size.width / 9), size.height / 6);
    var thirdEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(thirdControlPoint.dx, thirdControlPoint.dy,
        thirdEndPoint.dx, thirdEndPoint.dy);

    ///move from bottom right to top
    path.lineTo(size.width, 0.0);

    ///finally close the path by reaching start point from top right corner
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FooterWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height - 60);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class YellowCircleClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return null;
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => false;
}
