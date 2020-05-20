import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/shared/colors.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';

import 'signInUi.dart';

class SignInMainPage extends StatefulWidget {
  SignInMainPage({Key key, this.title, this.uri, this.url, this.aboutInfo}) : super(key: key);
  final String title;
  String uri;
  String url;
  Map<String, dynamic> aboutInfo;

  @override
  _SignInMainPageState createState() => _SignInMainPageState();
}

class _SignInMainPageState extends State<SignInMainPage> {
  ScrollController scrollController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: BackButton(
          color: Colors.white,
        ),
        title: Text("Entrar", style: h2),
      ),
      body: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
//        if (model.isLoading) {
////          Dialog thisDialog = showLoadingDialog();
//        }

        return ListView(
          controller: scrollController,
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height, child: Login(model, scaffoldKey, url: widget.url, uri: widget.uri, aboutInfo: widget.aboutInfo,)),
          ],
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();

    scrollController = ScrollController();

    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) {
        print(visible);
        if (!visible) {
          scrollController.animateTo(
            -10.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 30),
          );
        }
      },
    );
  }
}
