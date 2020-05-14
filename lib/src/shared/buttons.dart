import 'package:dom_marino_app/src/shared/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './colors.dart';

FlatButton froyoFlatBtn(String text, onPressed, {TextStyle style}) {
  TextStyle thisStyle = style != null ? style : h2;
  return FlatButton(
    onPressed: onPressed,
    child: Text(text, style: thisStyle,textAlign: TextAlign.center,),
    textColor: white,
    color: primaryColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );
}

OutlineButton froyoOutlineBtn(String text, onPressed) {
  return OutlineButton(
    onPressed: onPressed,
    child: Text(text),
    textColor: primaryColor,
    highlightedBorderColor: highlightColor,
    borderSide: BorderSide(color: primaryColor),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  );
}
