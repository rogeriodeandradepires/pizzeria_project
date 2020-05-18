import 'dart:convert';

import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/signUpUi.dart';
import 'package:dom_marino_app/src/shared/database_helper.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'SignUpMainPage.dart';
import 'signinBg.dart';
import 'inputWidget.dart';

class Login extends StatefulWidget {
  final UserModel model;
  final scaffoldKey;
  final dbHelper = DatabaseHelper.instance;
  String uri;
  String url;

  Login(this.model, this.scaffoldKey, {@required this.url, @required this.uri});



  @override
  _LoginState createState() => _LoginState(this.model, this.scaffoldKey);
}

class _LoginState extends State<Login> {
  BuildContext globalContext;

  final _formKey = GlobalKey<FormState>();
  var _scaffoldKey;

  final inputEmail = InputWidget(30.0, 0.0, "seuemail@aqui.com", false);
  final inputPass = InputWidget(0.0, 30.0, "Senha", true);

  FocusNode sendResetPassFN;
  FocusNode signInBtnFN;

  var _model;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isToSendRetrievePassword = false;

  _LoginState(this._model, this._scaffoldKey);

  @override
  void initState() {
    super.initState();
    sendResetPassFN = FocusNode();
    signInBtnFN = FocusNode();
  }

  @override
  void dispose() {
    sendResetPassFN.dispose();
    signInBtnFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Stack(
      children: <Widget>[
        SigninBg(),
        SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).size.height / 4),
              ),
              Column(
                children: <Widget>[
                  ///holds email header and inputField
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 40, bottom: 10),
                        child: Text(
                          "Login",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFF000000)),
                        ),
                      ),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                inputEmail,
                                inputPass,
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          focusNode: sendResetPassFN,
                                          autofocus: true,
                                          onTap: (() async {
                                            FocusScope.of(context)
                                                .requestFocus(sendResetPassFN);

//                                        inputEmail.emailFocusNode.unfocus(focusPrevious: true);
//                                        FocusScope.of(globalContext).requestFocus(sendResetPassFN);

                                            isToSendRetrievePassword = false;
                                            if (inputEmail.emailController.text !=
                                                    null &&
                                                inputEmail.emailController.text
                                                    .contains("@")) {
                                              showLoadingDialog();

                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(
                                                      email: inputEmail
                                                          .emailController.text)
                                                  .catchError((onError) {
                                                isToSendRetrievePassword = true;

                                                if (onError.toString().contains(
                                                    "ERROR_USER_NOT_FOUND")) {
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                    content: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(
                                                            "Usuário Não Encontrado.",
                                                            textAlign:
                                                                TextAlign.center,
                                                            style: h6Snackbar,
                                                          ),
                                                          Text(
                                                            "Verifique o email digitado e tente novamente.",
                                                            textAlign:
                                                                TextAlign.justify,
                                                            style: h5Snackbar,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ));
//                                                          inputEmail.emailFocusNode.unfocus(focusPrevious: true);
//                                                          FocusScope.of(globalContext).requestFocus(inputPass.passFocusNode);
                                                }
                                              }).then((onValue) {
                                                Navigator.of(context,
                                                        rootNavigator: false)
                                                    .pop();

                                                if (!isToSendRetrievePassword) {
                                                  _scaffoldKey.currentState
                                                      .showSnackBar(SnackBar(
                                                    content: Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.1,
                                                      child: Column(
                                                        children: <Widget>[
                                                          Text(
                                                            "Email enviado.",
                                                            textAlign:
                                                                TextAlign.center,
                                                            style: h6Snackbar,
                                                          ),
                                                          Text(
                                                            "Email de redefinição de senha enviado.",
                                                            textAlign:
                                                                TextAlign.justify,
                                                            style: h5Snackbar,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    backgroundColor:
                                                        Colors.greenAccent,
                                                    duration:
                                                        Duration(seconds: 2),
                                                  ));
//                                              FocusScope.of(globalContext).requestFocus(inputPass.passFocusNode);
//                                              inputEmail.emailFocusNode.unfocus(focusPrevious: true);
                                                }
                                              });
                                            } else {
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.1,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "Email Inválido.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: h6Snackbar,
                                                      ),
                                                      Text(
                                                        "Verifique o email digitado e tente novamente.",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: h5Snackbar,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                backgroundColor: Colors.redAccent,
                                                duration: Duration(seconds: 2),
                                              ));
                                            }
                                          }),
                                          child: Text(
                                            'Redefinir senha',
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Color(0xFF000000),
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: (() {
//                                            Navigator.pushNamed(context, '/signup');
                                            Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  new SignUpMainPage(uri: widget.uri, url: widget.url)),
                                            );
                                          }),
                                          child: Text(
                                            'Criar Conta',
                                            textAlign: TextAlign.end,
                                            style: TextStyle(
                                                color: Color(0xFF000000),
                                                fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 35, bottom: 35.0),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(),
                                    gradient: LinearGradient(
                                        colors: goBtnGradients,
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight),
                                  ),
                                  child: ImageIcon(
                                    AssetImage("images/ic_forward.png"),
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    focusNode: signInBtnFN,
                                    customBorder: new CircleBorder(),
                                    child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: ShapeDecoration(
                                            shape: CircleBorder(),
                                            color: Colors.transparent)),
                                    onTap: () {
                                      FocusScope.of(context)
                                          .requestFocus(signInBtnFN);

                                      if (_formKey.currentState.validate()) {
                                        print("validou");
                                      }

                                      if (!_model.isLoggedIn()) {
                                        _model.signIn(
                                            email:
                                                inputEmail.emailController.text,
                                            pass: inputPass.passController.text,
                                            onSucess: (() {
                                              print("Logou");
                                              Navigator.of(context,
                                                      rootNavigator: false)
                                                  .pop();
                                              Navigator.of(context,
                                                      rootNavigator: true)
                                                  .pop();
                                            }),
                                            onFail: (() {
                                              print("Falhou");
                                              Navigator.of(context,
                                                      rootNavigator: false)
                                                  .pop();
                                              _scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                content: Container(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.06,
                                                  child: Column(
                                                    children: <Widget>[
                                                      Text(
                                                        "Falha ao Entrar.",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: h6Snackbar,
                                                      ),
                                                      Text(
                                                        "Verifique seus dados e tente novamente.",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: h5Snackbar,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                backgroundColor: Colors.redAccent,
                                                duration: Duration(seconds: 2),
                                              ));
                                            }));
                                        if (_model.isLoading) {
                                          Dialog thisDialog = showLoadingDialog();
                                        }
                                      } else {
                                        _model.signOut();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 40),
                  ),
                  Stack(
                    children: <Widget>[
                      roundedRectButton(
                          "Login com Facebook", signInGradients, false),
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
                            initiateFacebookLogin(_model);
                          }),
                        ),
                      ),
                    ],
                  ),

                  Stack(
                    children: <Widget>[
                      roundedRectButton(
                          "Login com Google", signUpGradients, false),
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
                            signInWithGoogle();
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
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
//        print("LoggedIn");

        var graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');

        var profile = json.decode(graphResponse.body);
//        print(profile['first_name']+" "+profile['last_name']);
//        print(profile['picture']['data']['url']);
//        print(profile['email']);

        AuthCredential credential =
            FacebookAuthProvider.getCredential(accessToken: myToken.token);

//        print("Aqui: "+credential.toString());

        FirebaseUser firebaseUser =
            await FirebaseAuth.instance.signInWithCredential(credential);
        
        await sendUserToFirestore(firebaseUser, profile, true);

        Navigator.of(context, rootNavigator: false).pop('Ok');

        model.signInFace(true, firebaseUser);

        Navigator.of(context, rootNavigator: true).pop('Ok');
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
              return WillPopScope(
                onWillPop: (){},
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
          .then((thisUser) async {
        _model.signInFace(true, thisUser);
        Navigator.of(context, rootNavigator: false).pop('Ok');

//      assert(!thisUser.isAnonymous);
//      assert(thisUser.getIdToken() != null);

//        print("terminou: " + thisUser.toString());

        await sendUserToFirestore(thisUser, thisUser, false);

        if (!thisUser.isAnonymous && thisUser.getIdToken() != null) {
          Navigator.of(context, rootNavigator: true).pop('Ok');
        } else {
          print("User é nulo");
        }

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

  Future<void> sendUserToFirestore(FirebaseUser firebaseUser, profile, bool isFacebook) async {

//    print("Entrou senduser");

    String uid = firebaseUser.uid.toString();
    String name = isFacebook ? profile["first_name"]+" "+profile['last_name']: profile.displayName;
    String email = isFacebook ? profile["email"]: profile.email;
    String img_url = isFacebook ? profile['picture']['data']['url']: profile.photoUrl;

//    var url = "http://192.168.63.1:8080/create_user";
    var queryParameters = {
      'uid': '$uid',
    };

    var uri = Uri.https(
        widget.uri, 'list_users', queryParameters);

    try {
      http.Response response = await http.get(uri);
      // sample info available in response
      int statusCode = response.statusCode;
      Map<String, String> headers = response.headers;
      String contentType = headers['content-type'];

//      print(response.body);

      if (response.statusCode == 200) {
        dynamic existentUser = json.decode(response.body);

        if (existentUser!=null) {
//          print("já existe");

          Map<String, dynamic> thisUser = {
            DatabaseHelper.columnUID: uid,
            DatabaseHelper.columnUserName: name,
            DatabaseHelper.columnUserEmail: email,
            DatabaseHelper.columnUserImgUrl: img_url,
            DatabaseHelper.columnUserStreet: existentUser['street'],
            DatabaseHelper.columnUserStreetNumber: existentUser['streetNumber'],
            DatabaseHelper.columnUserNeighborhood: existentUser['neighborhood'],
            DatabaseHelper.columnUserCity: existentUser['city'],
            DatabaseHelper.columnUserPhone: existentUser['phone'],
            DatabaseHelper.columnIsRegComplete: existentUser['isRegisterComplete']
          };

          dynamic retorno = await this.widget.dbHelper.searchUser(uid);

          if (retorno!=null) {
//            print("já existe, tem retorno");
            await this.widget.dbHelper.update(thisUser, "users", "uid");
          }else{
//            print("já existe, NÃO tem retorno");
            await this.widget.dbHelper.insert(thisUser, "users");
          }

        }else{
//          print("não existe");
          var url = widget.url+"create_user";

          final postUri = Uri.parse(url);
          http.MultipartRequest request = http.MultipartRequest('POST', postUri);

          request.fields['hasImageFile'] = "False";

          request.fields['uid'] = uid;
          request.fields['name'] = name;
          request.fields['phone'] = "";
          request.fields['email'] = email;
          request.fields['isRegisterComplete'] = "0";
          request.fields['img_url'] = img_url;

          http.StreamedResponse response = await request.send();

          Map<String, dynamic> thisUser = {
            DatabaseHelper.columnUID: uid,
            DatabaseHelper.columnUserName: name,
            DatabaseHelper.columnUserEmail: email,
            DatabaseHelper.columnUserImgUrl: img_url,
            DatabaseHelper.columnUserPhone: "",
            DatabaseHelper.columnIsRegComplete: 0
          };

          dynamic retorno = await this.widget.dbHelper.searchUser(uid);

//          print("retorno="+retorno.toString());

          if (retorno!=null) {
//            print("Não existe, tem retorno");
            await this.widget.dbHelper.update(thisUser, "users", "uid");
          }else{
//            print("Não existe, Não tem retorno");
            await this.widget.dbHelper.insert(thisUser, "users");
          }
        }
//        all_products_obj_list = new List();
//
//        all_products_obj_list.add(Product.fromJson(allProducts));
//
//        return Product.fromJson(allProducts);
      } else {
        // If that response was not OK, throw an error.
        throw Exception('Failed to load product');
      }
    } catch (e) {
      print("Aqui listUsers erro: " + e.toString());
    }

//    print("Saiu senduser: "+response.statusCode.toString());


//    Future.delayed(Duration(seconds:2)).then((_){
//      Navigator.of(context).pop();
//    });
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
          Visibility(
            visible: isEndIconVisible,
            child: Padding(
                padding: EdgeInsets.only(right: 10),
                child: ImageIcon(
                  AssetImage("assets/ic_forward.png"),
                  size: 30,
                  color: Colors.white,
                )),
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

const List<Color> signInGradients = [
  Color(0xFF03A0FE),
  Color(0xFF4267b2),
];

const List<Color> signUpGradients = [
  Color(0xFFFc6076),
  Color(0xFFd9534f),
];
