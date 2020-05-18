import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/CartPage.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './src/screens/Dashboard.dart';

void main() => runApp(MyApp());
//void main() async{//=> runApp(MyApp());
//  WidgetsFlutterBinding.ensureInitialized();
//  SystemChrome.setPreferredOrientations([
//    DeviceOrientation.portraitUp,
//    DeviceOrientation.portraitDown
//  ]).then((_){
//    runApp(MyApp());
//  });
//}

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
              '/dashboard': (BuildContext context) => Dashboard(),
              '/cartPage': (BuildContext context) => CartPage(),
            },
          );
        },
      )
    );
  }
}
