import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Entrar"),
          centerTitle: true,
          actions: <Widget>[
            FlatButton(
              child: Text(
                "CRIAR CONTA",
                style: TextStyle(
                    fontSize: 15.0
                ),
              ),
              textColor: Colors.white,
              onPressed: (){
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context)=>SignUpPage())
                );
              },
            )
          ],
        ),
        body: ScopedModelDescendant<UserModel>(
          builder: (context, child, model){
            if(model.isLoading){
              return Center(child: CircularProgressIndicator(),);
            }
            return Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(16.0),
                children: <Widget>[
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        hintText: "E-mail"
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (text){
                      if(text.isEmpty || !text.contains("@")) return "E-mail inválido";
                    },
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passController,
                    decoration: InputDecoration(
                        hintText: "Senha"
                    ),
                    obscureText: true,
                    validator: (text){
                      if(text.isEmpty) return "Insira uma senha";
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FlatButton(
                      onPressed: (){},
                      child: Text("Esqueci minha senha",
                        textAlign: TextAlign.right,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  SizedBox(
                      height: 44.0,
                      child: RaisedButton(
                        child: Text(
                          !model.isLoggedIn() ?
                          "Entrar": "Sair",
                          style: TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        textColor: Colors.white,
                        color: Theme.of(context).primaryColor,
                        onPressed: (){
                          if(_formKey.currentState.validate()){
                          }
                          if(!model.isLoggedIn()) {
                            model.signIn(
                                email: _emailController.text,
                                pass: _passController.text,
                                onSucess: _onSucess,
                                onFail: _onFail
                            );
                          }else{
                            model.signOut();
                          }
                        },
                      )
                  ),
                  RaisedButton(
                    child: Text("Login with Facebook"),
                    onPressed: () => initiateFacebookLogin(model),
                  ),
                ],
              ),
            );
          },
        )
    );
  }


  void _onSucess(){
    print("logado");
    Navigator.of(context).pop();
  }

  void _onFail(){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(content: Text("Falha ao entrar!"),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),)
    );
  }

  void initiateFacebookLogin(UserModel model) async {
    final facebookLogin = FacebookLogin();
    final facebookLoginResult = await facebookLogin.logIn(['email', 'public_profile']);

    //var facebookLogin = FacebookLogin();
    //var facebookLoginResult =
    //await facebookLogin.logInWithReadPermissions(['email']);

    FacebookAccessToken myToken = facebookLoginResult.accessToken;
    AuthCredential credential = FacebookAuthProvider.getCredential(accessToken: myToken.token);

    FirebaseUser firebaseUser = await FirebaseAuth.instance.signInWithCredential(credential);

    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        //onLoginStatusChanged(false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        model.signInFace(true, firebaseUser);
        //onLoginStatusChanged(true);
        break;
    }
  }
}
