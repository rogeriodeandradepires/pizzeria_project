import 'dart:io';

import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/signupBg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  final UserModel model;
  final scaffoldKey;

  SignUp(this.model, this.scaffoldKey);

  @override
  _SignUpState createState() => _SignUpState(this.model, this.scaffoldKey);
}

class _SignUpState extends State<SignUp> {
  BuildContext globalContext;

  final _formKey = GlobalKey<FormState>();
  var _scaffoldKey;

  var _nameController;
  var _phoneController;
  var _emailController;
  var _pass1Controller;
  var _pass2Controller;

  var thisSignUpBg;

  File _image;

  FocusNode sendResetPassFN;

  var _model;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isToSendRetrievePassword = false;

  _SignUpState(this._model, this._scaffoldKey);

  @override
  void initState() {
    super.initState();
    sendResetPassFN = FocusNode();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _pass1Controller = TextEditingController();
    _pass2Controller = TextEditingController();
  }

  @override
  void dispose() {
    sendResetPassFN.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pass1Controller.dispose();
    _pass2Controller.dispose();
    super.dispose();
  }

  Future<void> onTap() async {

    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: Builder(builder: (context) {
              return Align(
                  alignment: Alignment.center,
                  child: Container(
                    color: Colors.white,
                      height: MediaQuery.of(context).size.height/4,
                      width: MediaQuery.of(context).size.width*0.8,
                      child: Image.asset(
                        'images/loading_pizza_faster.gif',
                        fit: BoxFit.scaleDown,
                      )));
            }),
          );
        },
        barrierDismissible: true,
        barrierLabel:
        MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: const Duration(milliseconds: 150));

//    var image = await ImagePicker.pickImage(source: ImageSource.camera);
//    setState(() {
////      thisSignUpBg = SignupBg(onTap, image);
//    _image = image;
//    });

  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    thisSignUpBg = SignupBg(onTap, _image);
    return Stack(
      children: <Widget>[
        thisSignUpBg,
        Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: MediaQuery.of(context).size.height / 4.5),
            ),
            Column(
              children: <Widget>[
                ///holds email header and inputField
                Stack(
                  alignment: Alignment.bottomRight,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 40, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: Material(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(0.0),
                                        topRight: Radius.circular(30.0))),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _nameController,
                                    keyboardType: TextInputType.text,
                                    validator: (text){
                                      if(text.isEmpty){
                                        return "Digite seu Nome Completo.";
                                      }else{
                                          if (text.length<3) {
                                            return "Nome inválido";
                                          }

                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Nome Completo",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 40, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: Material(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0))),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _phoneController,
                                    keyboardType: TextInputType.text,
                                    validator: (text){
                                      if(text.isEmpty){
                                        return "Digite o Nº de seu Telefone.";
                                      }else{
                                        if (text.length<10) {
                                          return "Telefone inválido";
                                        }

                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Telefone de Contato",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 40, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: Material(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0))),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _emailController,
                                    keyboardType: TextInputType.text,
                                    validator: (text){
                                      if(text.isEmpty){
                                        return "Digite seu Email.";
                                      }else{
                                        if (!text.contains("@") || !text.contains(".") ) {
                                          return "Email inválido";
                                        }

                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 40, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: Material(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(0.0),
                                        topRight: Radius.circular(0.0))),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _pass1Controller,
                                    obscureText: true,
                                    keyboardType: TextInputType.text,
                                    validator: (text){
                                      if(text.isEmpty){
                                        return "Digite sua Senha.";
                                      }else{
                                        if (text.length<6) {
                                          return "A Senha deve conter ao menos 6 dígitos.";
                                        }

                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Senha",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 40, bottom: 10),
                            child: Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 50,
                              child: Material(
                                elevation: 0,
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(30.0),
                                        topRight: Radius.circular(0.0))),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _pass2Controller,
                                    obscureText: true,
                                    keyboardType: TextInputType.text,
                                    validator: (text){
                                      if(text.isEmpty){
                                        return "Repita sua Senha.";
                                      }else{
                                          if (_pass1Controller.text != _pass2Controller.text) {
                                            return "As Senhas digitadas não coincidem.";
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Repetir a Senha",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                Stack(
                  children: <Widget>[
                    roundedRectButton(
                        "Registrar", goBtnGradients, false),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(globalContext).size.width / 1.2,
                          height: 55.0,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0)),
                          ),
                          padding: EdgeInsets.only(top: 16, bottom: 16),
                        ),
                        onTap: (() {
                          if (_formKey.currentState.validate()) {
                            print("validou");
                          }

                        }),
                      ),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  void initiateFacebookLogin(UserModel model) async {
    showLoadingDialog();

    final facebookLogin = FacebookLogin();
    final facebookLoginResult =
        await facebookLogin.logIn(['email', 'public_profile']);

    FacebookAccessToken myToken = facebookLoginResult.accessToken;

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        Navigator.of(context, rootNavigator: false).pop();
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
//        stopLoading();
        Navigator.of(context, rootNavigator: false).pop();
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        AuthCredential credential =
            FacebookAuthProvider.getCredential(accessToken: myToken.token);

        FirebaseUser firebaseUser =
            await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.of(context, rootNavigator: false).pop();

        model.signInFace(true, firebaseUser);

        Navigator.of(context, rootNavigator: true).pop();
        //onLoginStatusChanged(true);
        break;
    }
  }

  Dialog showLoadingDialog() {
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: Builder(builder: (context) {
              return Material(
                  color: Colors.transparent,
                  child: Align(
                      alignment: Alignment.center,
                      child: Container(
                          height: 100.0,
                          width: 100.0,
                          child: Image.asset(
                            'images/loading_pizza_faster.gif',
                            fit: BoxFit.scaleDown,
                          ))));
            }),
          );
        },
        barrierDismissible: true,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black.withOpacity(0.4),
        transitionDuration: const Duration(milliseconds: 150));
    return retorno;
  }

  Future<String> signInWithGoogle() async {
    showLoadingDialog();

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final FirebaseUser user = await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((thisUser) {
        _model.signInFace(true, thisUser);
        Navigator.of(context, rootNavigator: false).pop();

//      assert(!thisUser.isAnonymous);
//      assert(thisUser.getIdToken() != null);

        if (!thisUser.isAnonymous && thisUser.getIdToken() != null) {
          Navigator.of(context, rootNavigator: true).pop();
        } else {
          print("User é nulo");
        }

        print("terminou: " + thisUser.toString());
        return thisUser;
      });

//    assert(!user.isAnonymous);
//    assert(await user.getIdToken() != null);

      final FirebaseUser currentUser =
          await FirebaseAuth.instance.currentUser();
//    assert(user.uid == currentUser.uid);

      return 'signInWithGoogle succeeded: $currentUser';
    } else {
      Navigator.of(context, rootNavigator: false).pop();
      return 'signInWithGoogle failed.';
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }
}

Widget roundedRectButton(
    String title, List<Color> gradient, bool isEndIconVisible) {
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
            child: Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
          ),
        ],
      ),
    );
  });
}

const List<Color> goBtnGradients = [
  Color(0xFF643621),
  Color(0xFF391d11),
];
