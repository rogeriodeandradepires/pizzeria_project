import 'package:dom_marino_app/src/models/user_model.dart';
import 'package:dom_marino_app/src/screens/signUpUi.dart';
import 'package:dom_marino_app/src/shared/colors.dart';
import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpMainPage extends StatefulWidget {
  SignUpMainPage({Key key, this.title, @required this.uri, @required this.url, this.aboutInfo}) : super(key: key);
  final String title;
  String uri;
  String url;
  Map<String, dynamic> aboutInfo;

  @override
  _SignUpMainPageState createState() => _SignUpMainPageState();
}

class _SignUpMainPageState extends State<SignUpMainPage> {
  ScrollController scrollController;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context).settings.arguments;

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
        title: Text("Cadastre-se", style: h2),
      ),
      body: ScopedModelDescendant<UserModel>(builder: (context, child, model) {
//        if (model.isLoading) {
////          Dialog thisDialog = showLoadingDialog();
//        }

        return ListView(
          controller: scrollController,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height*1.5, child: SignUp(args, model, scaffoldKey, uri: widget.uri, url: widget.url, aboutInfo: widget.aboutInfo,)),
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
