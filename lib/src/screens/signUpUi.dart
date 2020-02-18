import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/signupBg.dart';
import 'package:dom_marino_app/src/shared/database_helper.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart' as diolib;
import 'package:http/http.dart' as http;

import 'image_picker_handler.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class SignUp extends StatefulWidget {
  final UserModel model;
  final scaffoldKey;
  Map<String, dynamic> thisUser;
  final dbHelper = DatabaseHelper.instance;

  SignUp(this.thisUser, this.model, this.scaffoldKey);

  @override
  _SignUpState createState() =>
      _SignUpState(this.thisUser, this.model, this.scaffoldKey);
}

class _SignUpState extends State<SignUp>
    with TickerProviderStateMixin, ImagePickerListener {
  BuildContext globalContext;

  final _formKey = GlobalKey<FormState>();
  var _scaffoldKey;

  var _nameController;
  var _phoneController;
  var _emailController;
  var _pass1Controller;
  var _pass2Controller;

  var thisSignUpBg;

  String imgUrl = null;
  FocusNode registerFN;

  var maskFormatter = new MaskTextInputFormatter(
      mask: '+55 (##) #####-####', filter: {"#": RegExp(r'[0-9]')});

  File _image;

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser firebaseUser;
  Map<String, dynamic> userData = Map();

  FocusNode sendResetPassFN;

  var _model;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Map<String, dynamic> thisUser;

  bool isToSendRetrievePassword = false;

  _SignUpState(this.thisUser, this._model, this._scaffoldKey);

  AnimationController _controller;
  ImagePickerHandler imagePicker;

  @override
  void initState() {
    super.initState();
    sendResetPassFN = FocusNode();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _pass1Controller = TextEditingController();
    _pass2Controller = TextEditingController();

    registerFN = FocusNode();

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = new ImagePickerHandler(this, _controller);
    imagePicker.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (thisUser != null) {
        _nameController.text = thisUser['name'];
        _emailController.text = thisUser['email'];
        _phoneController.text = thisUser['phone'];

        if (thisUser['imgUrl'] != null) {
          setState(() {
            imgUrl = thisUser['imgUrl'].toString();
          });
        }
      }
    });
  }

  @override
  void dispose() {
    sendResetPassFN.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _pass1Controller.dispose();
    _pass2Controller.dispose();

    registerFN.dispose();

    _controller.dispose();

    super.dispose();
  }

  Future<void> onTap() async {
    imagePicker.showDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    thisSignUpBg = SignupBg(imgUrl, onTap, _image);
    return Stack(
      children: <Widget>[
        thisSignUpBg,
        Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 4.5),
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
                                  padding: EdgeInsets.only(
                                      left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    autofocus: false,
                                    controller: _nameController,
                                    keyboardType: TextInputType.text,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return "Digite seu Nome Completo.";
                                      } else {
                                        if (text.length < 3) {
                                          return "Nome inválido";
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Nome Completo",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 14)),
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
                                  padding: EdgeInsets.only(
                                      left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    enabled: thisUser!=null?false:true,
                                    autofocus: false,
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return "Digite seu Email.";
                                      } else {
                                        if (!text.contains("@") ||
                                            !text.contains(".")) {
                                          return "Email inválido";
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 14)),
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
                                  padding: EdgeInsets.only(
                                      left: 40, right: 20, top: 0, bottom: 0),
                                  child: TextFormField(
                                    inputFormatters: [maskFormatter],
                                    autofocus: false,
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    validator: (text) {
                                      if (text.isEmpty) {
                                        return "Digite o Nº de seu Telefone.";
                                      } else {
                                        if (text.length < 10) {
                                          return "Telefone inválido";
                                        }
                                      }
                                    },
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Telefone de Contato",
                                        hintStyle: TextStyle(
                                            color: Colors.grey, fontSize: 14)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          thisUser != null
                              ? Container()
                              : Padding(
                                  padding:
                                      EdgeInsets.only(right: 40, bottom: 10),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 50,
                                    child: Material(
                                      elevation: 0,
                                      color: Colors.white.withOpacity(0.8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(0.0),
                                              topRight: Radius.circular(0.0))),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 40,
                                            right: 20,
                                            top: 0,
                                            bottom: 0),
                                        child: TextFormField(
                                          autofocus: false,
                                          controller: _pass1Controller,
                                          obscureText: true,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          validator: (text) {
                                            if (text.isEmpty) {
                                              return "Digite sua Senha.";
                                            } else {
                                              if (text.length < 6) {
                                                return "A Senha deve conter ao menos 6 dígitos.";
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Senha",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                          thisUser != null
                              ? Container()
                              : Padding(
                                  padding:
                                      EdgeInsets.only(right: 40, bottom: 10),
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width - 40,
                                    height: 50,
                                    child: Material(
                                      elevation: 0,
                                      color: Colors.white.withOpacity(0.8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              bottomRight:
                                                  Radius.circular(30.0),
                                              topRight: Radius.circular(0.0))),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 40,
                                            right: 20,
                                            top: 0,
                                            bottom: 0),
                                        child: TextFormField(
                                          autofocus: false,
                                          controller: _pass2Controller,
                                          obscureText: true,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          validator: (text) {
                                            if (text.isEmpty) {
                                              return "Repita sua Senha.";
                                            } else {
                                              if (_pass1Controller.text !=
                                                  _pass2Controller.text) {
                                                return "As Senhas digitadas não coincidem.";
                                              }
                                            }
                                          },
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Repetir a Senha",
                                              hintStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14)),
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
                    roundedRectButton(thisUser!=null?"Salvar":"Registrar", goBtnGradients, false),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        focusNode: registerFN,
                        autofocus: true,
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
                        onTap: (() async {
                          FocusScope.of(context).requestFocus(sendResetPassFN);

                          if (_formKey.currentState.validate()) {
                            userData = {
                              "name": _nameController.text,
                              "email": _emailController.text,
                              "phone": _phoneController.text,
//                              "picture": _image
                            };

                            signUp(
                                userData: userData,
                                pass: _pass1Controller.text,
                                onSucess: _onSucess,
                                onFail: _onFail);

//                            model.signUp(
//                              userData: userData,
//                              pass: _passController.text,
//                              onSucess: _onSucess,
//                              onFail: _onFail,
//                            );
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

//  void initiateFacebookLogin(UserModel model) async {
//    showLoadingDialog();
//
//    final facebookLogin = FacebookLogin();
//    final facebookLoginResult =
//        await facebookLogin.logIn(['email', 'public_profile']);
//
//    FacebookAccessToken myToken = facebookLoginResult.accessToken;
//
//    switch (facebookLoginResult.status) {
//      case FacebookLoginStatus.error:
//        print("Error");
//        Navigator.of(context, rootNavigator: false).pop();
//        //onLoginStatusChanged(false);
//        break;
//      case FacebookLoginStatus.cancelledByUser:
//        print("CancelledByUser");
////        stopLoading();
//        Navigator.of(context, rootNavigator: false).pop();
//        //onLoginStatusChanged(false);
//        break;
//      case FacebookLoginStatus.loggedIn:
//        print("LoggedIn");
//        AuthCredential credential =
//            FacebookAuthProvider.getCredential(accessToken: myToken.token);
//
//        FirebaseUser firebaseUser =
//            await FirebaseAuth.instance.signInWithCredential(credential);
//
//        Navigator.of(context, rootNavigator: false).pop();
//
//        model.signInFace(true, firebaseUser);
//
//        Navigator.of(context, rootNavigator: true).pop();
//        //onLoginStatusChanged(true);
//        break;
//    }
//  }

  Dialog showLoadingDialog() {
    Dialog retorno;
    showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: Builder(builder: (context) {
              return WillPopScope(
                onWillPop: () {},
                child: Material(
                    color: Colors.transparent,
                    child: Align(
                        alignment: Alignment.center,
                        child: Container(
                            height: 100.0,
                            width: 100.0,
                            child: Image.asset(
                              'images/loading_pizza_faster.gif',
                              fit: BoxFit.scaleDown,
                            )))),
              );
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

//  Future<String> signInWithGoogle() async {
//    showLoadingDialog();
//
//    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
//
//    if (googleSignInAccount != null) {
//      final GoogleSignInAuthentication googleSignInAuthentication =
//          await googleSignInAccount.authentication;
//
//      final AuthCredential credential = GoogleAuthProvider.getCredential(
//        accessToken: googleSignInAuthentication.accessToken,
//        idToken: googleSignInAuthentication.idToken,
//      );
//
//      final FirebaseUser user = await FirebaseAuth.instance
//          .signInWithCredential(credential)
//          .then((thisUser) {
//        _model.signInFace(true, thisUser);
//        Navigator.of(context, rootNavigator: false).pop();
//
////      assert(!thisUser.isAnonymous);
////      assert(thisUser.getIdToken() != null);
//
//        if (!thisUser.isAnonymous && thisUser.getIdToken() != null) {
//          Navigator.of(context, rootNavigator: true).pop();
//        } else {
//          print("User é nulo");
//        }
//
//        print("terminou: " + thisUser.toString());
//        return thisUser;
//      });
//
////    assert(!user.isAnonymous);
////    assert(await user.getIdToken() != null);
//
//      final FirebaseUser currentUser =
//          await FirebaseAuth.instance.currentUser();
////    assert(user.uid == currentUser.uid);
//
//      return 'signInWithGoogle succeeded: $currentUser';
//    } else {
//      Navigator.of(context, rootNavigator: false).pop();
//      return 'signInWithGoogle failed.';
//    }
//  }
//
//  void signOutGoogle() async {
//    await googleSignIn.signOut();
//
//    print("User Sign Out");
//  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

  Future<void> _onSucess() async {
    sendUserToFirestore();
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Falha ao criar usuário!"),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
    ));

    Future.delayed(Duration(seconds:2)).then((_){
      Navigator.of(context).pop();
    });
  }

  void signUp(
      {@required Map<String, dynamic> userData,
      @required String pass,
      @required VoidCallback onSucess,
      @required VoidCallback onFail}) {
//    isLoading = true;
//    notifyListeners();

    showLoadingDialog();

    if (thisUser!=null) {
      sendUserToFirestore();
    }else{
      _auth
          .createUserWithEmailAndPassword(
          email: userData["email"], password: pass)
          .then((user) async {
        firebaseUser = user;

        //await _saveUserData(userData);

        onSucess();
//      isLoading = false;
//      notifyListeners();
      }).catchError((e) {
        onFail();
//      isLoading = false;
//      notifyListeners();
      });
    }
  }

  Future<void> sendUserToFirestore() async {
    userData["uid"] = widget.thisUser!=null?widget.thisUser['uid']:this.firebaseUser.uid.toString();

    var url = "https://dom-marino-webservice.appspot.com/create_user";

    final postUri = Uri.parse(url);
    http.MultipartRequest request = http.MultipartRequest('POST', postUri);

    request.fields['hasImageFile'] = "False";

    if (_image != null) {
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('image_file', _image.path);
      request.files.add(multipartFile);
      request.fields['hasImageFile'] = "True";
    }

    request.fields['uid'] = userData["uid"];
    request.fields['name'] = userData["name"];
    request.fields['email'] = userData["email"];
    request.fields['phone'] = userData["phone"];
    request.fields['img_url'] = "";
    request.fields['isRegisterComplete'] = "1";

    if (this.widget.thisUser != null) {
      if (this.thisUser['imgUrl'] != null) {
        request.fields['img_url'] = this.thisUser['imgUrl'].toString();
      }
    }

    http.StreamedResponse response = await request.send();
    String img_url = "";

    Map<String, dynamic> thisUser = {
      DatabaseHelper.columnUID: userData["uid"],
      DatabaseHelper.columnUserName: userData["name"],
      DatabaseHelper.columnUserEmail: userData["email"],
      DatabaseHelper.columnUserImgUrl: img_url,
      DatabaseHelper.columnUserPhone: userData["phone"],
      DatabaseHelper.columnIsRegComplete: 1
    };

    dynamic retorno = await this.widget.dbHelper.searchUser(userData["uid"]);

//          print("retorno="+retorno.toString());

    if (retorno!=null) {
//            print("Não existe, tem retorno");
      await this.widget.dbHelper.update(thisUser, "users", "uid");
    }else{
//            print("Não existe, Não tem retorno");
      await this.widget.dbHelper.insert(thisUser, "users");
    }

    Navigator.of(context, rootNavigator: false).pop();

    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text("Usuário Salvo com sucesso!"),
      backgroundColor: Colors.greenAccent,
      duration: Duration(seconds: 2),
    ));
//
    Future.delayed(Duration(seconds: 2)).then((_) {
      Navigator.of(context).pop();
    });
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
