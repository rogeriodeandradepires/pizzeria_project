import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/CartPage.dart';
import 'package:dom_marino_app/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './src/screens/SignInPage.dart';
import './src/screens/SignUpPage.dart';
import './src/screens/HomePage.dart';
import './src/screens/Dashboard.dart';
import './src/screens/ProductPage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopedModel<UserModel>(
      model:UserModel(),
      child:ScopedModelDescendant<UserModel>(
        builder: (context, child, model){
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Dom Marino',
            theme: ThemeData(
              primarySwatch: Colors.brown,
            ),
            home: Dashboard(pageTitle: 'Bem vindo'),
            //home: SignInPage(),
            routes: <String, WidgetBuilder> {
              '/signup': (BuildContext context) =>  !model.isLoggedIn() ? SignUpPage():Dashboard(),
              '/signin': (BuildContext context) =>  SignInPage(),
              '/dashboard': (BuildContext context) => Dashboard(),
              '/productPage': (BuildContext context) => SignInPage(),
              '/cartPage': (BuildContext context) => CartPage(),
            },
          );
        },
      )
    );
  }
}
