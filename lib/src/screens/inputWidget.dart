import 'package:flutter/material.dart';

class InputWidget extends StatefulWidget {
  final double topRight;
  final double bottomRight;
  final String hintText;
  final bool isPasswordField;
  final emailController = TextEditingController();

  final passController = TextEditingController();

  final emailFocusNode = FocusNode();
  final passFocusNode = FocusNode();

  InputWidget(this.topRight, this.bottomRight, this.hintText, this.isPasswordField);

  @override
  _InputWidgetState createState() => _InputWidgetState(this.emailController, this.passController, this.emailFocusNode, this.passFocusNode);
}

class _InputWidgetState extends State<InputWidget> {

  var _emailController;
  var _passController;

  var _emailFocusNode = FocusNode();
  var _passFocusNode = FocusNode();

  _InputWidgetState(this._emailController,this._passController, this._emailFocusNode, this._passFocusNode);


  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _emailFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 40, bottom: 10),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        child: Material(
          elevation: 0,
          color: Colors.white.withOpacity(0.8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(widget.bottomRight),
                  topRight: Radius.circular(widget.topRight))),
          child: Padding(
            padding: EdgeInsets.only(left: 40, right: 20, top: 0, bottom: 0),
            child: TextFormField(
              autofocus: false,
              focusNode: widget.isPasswordField ? _passFocusNode : _emailFocusNode,
              obscureText: widget.isPasswordField,
              controller: widget.isPasswordField ? _passController : _emailController,
              keyboardType: widget.isPasswordField ? TextInputType.text : TextInputType.emailAddress,
              validator: (text){
                if(text.isEmpty){
                  if (widget.isPasswordField) {
                    if (text.length<=6) {
                      return "Digite sua Senha.";
                    }
                  }else{
                    if (!text.contains("@")) {
                      return "E-mail inválido";
                    }
                  }
                }else{
                  if (!widget.isPasswordField) {
                    if (!text.contains("@")) {
                      return "E-mail inválido";
                    }
                  }
                }
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14)),
            ),
          ),
        ),
      ),
    );
  }
}
