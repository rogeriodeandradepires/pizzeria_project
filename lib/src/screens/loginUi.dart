import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/signUpUi.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'signinBg.dart';
import 'inputWidget.dart';

class Login extends StatefulWidget {
  final UserModel model;
  final scaffoldKey;

  Login(this.model, this.scaffoldKey);

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

  var _model;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  bool isToSendRetrievePassword = false;

  _LoginState(this._model, this._scaffoldKey);

  @override
  void initState() {
    super.initState();
    sendResetPassFN = FocusNode();
  }

  @override
  void dispose() {
    sendResetPassFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    globalContext = context;
    return Stack(
      children: <Widget>[
        SigninBg(),
        Column(
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
                                          'Esqueci minha senha',
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
                                          Navigator.pushReplacementNamed(context, '/signup');
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
                          padding: EdgeInsets.only(right: 35, bottom: 50.0),
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
                                  customBorder: new CircleBorder(),
                                  child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: ShapeDecoration(
                                          shape: CircleBorder(),
                                          color: Colors.transparent)),
                                  onTap: () {
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
