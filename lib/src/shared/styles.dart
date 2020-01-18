import 'package:flutter/material.dart';
import './colors.dart';

/////////////////////////////////
///   TEXT STYLES
////////////////////////////////

const logoStyle = TextStyle(
    fontFamily: 'Pacifico',
    fontSize: 30,
    color: Colors.black54,
    letterSpacing: 2);

const logoWhiteStyle = TextStyle(
    fontFamily: 'Pacifico',
    fontSize: 21,
    letterSpacing: 2,
    color: Colors.white);
const whiteText = TextStyle(color: Colors.white, fontFamily: 'Poppins');
const disabledText = TextStyle(color: Colors.grey, fontFamily: 'Poppins');
const contrastText = TextStyle(color: primaryColor, fontFamily: 'Poppins');
const contrastTextBold = TextStyle(
    color: primaryColor, fontFamily: 'Poppins', fontWeight: FontWeight.w600);

const h2 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins');

const h3 = TextStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const cart_title = TextStyle(
    color: Colors.white,
    fontSize: 34,
    height: 0.98,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const h4 = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins');

const white_h4 = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins');

const white_h4_lesser = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins');

const h5 = TextStyle(
    color: Colors.black,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins');

const h5Snackbar = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins');

const h6 = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins');

const h6Snackbar = TextStyle(
    color: Colors.black,
    fontSize: 16,
    height: 0.98,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins');

const priceText = TextStyle(
    color: Colors.black,
    fontSize: 19,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const foodNameText = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const minorFoodNameText = TextStyle(
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const majorFoodNameText = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const minorCartItemObservationsText = TextStyle(
    color: Colors.black,
    fontSize: 14,
    height: 0.98,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const minorPizzaEdgeText = TextStyle(
    color: Colors.black,
    fontSize: 12,
    height: 0.98,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const minorCartItemText = TextStyle(
    color: Color.fromRGBO(117, 117, 117, 1.0),
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 0.98,
    fontFamily: 'Poppins');

const chooseFlavorFoodNameText = TextStyle(
    color: Colors.black,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    fontFamily: 'Poppins');

const foodIngredientsText = TextStyle(
    color: Colors.black,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const foodNotesText = TextStyle(
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const chooseFlavorFoodNotesText = TextStyle(
    color: Colors.black,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const chooseFlavorFoodingredientsText = TextStyle(
    color: Colors.black,
    fontSize: 9,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins');

const tabLinkStyle = TextStyle(fontWeight: FontWeight.w500);

const taglineText = TextStyle(color: Colors.grey, fontFamily: 'Poppins');
const categoryText = TextStyle(
    color: Color(0xff444444),
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins');

const noneItemText = TextStyle(
    color: Color.fromRGBO(117, 117, 117, 1.0),
    fontSize: 18,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins');

const inputFieldTextStyle =
    TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w500);

const inputFieldHintTextStyle =
    TextStyle(fontFamily: 'Poppins', color: Color(0xff444444));

const inputFieldPasswordTextStyle = TextStyle(
    fontFamily: 'Poppins', fontWeight: FontWeight.w500, letterSpacing: 3);

const inputFieldHintPaswordTextStyle = TextStyle(
    fontFamily: 'Poppins', color: Color(0xff444444), letterSpacing: 2);

///////////////////////////////////
/// BOX DECORATION STYLES
//////////////////////////////////

const authPlateDecoration = BoxDecoration(
    color: white,
    boxShadow: [
      BoxShadow(
          color: Color.fromRGBO(0, 0, 0, .1),
          blurRadius: 10,
          spreadRadius: 5,
          offset: Offset(0, 1))
    ],
    borderRadius: BorderRadiusDirectional.only(
        bottomEnd: Radius.circular(20), bottomStart: Radius.circular(20)));

/////////////////////////////////////
/// INPUT FIELD DECORATION STYLES
////////////////////////////////////

const inputFieldFocusedBorderStyle = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(6)),
    borderSide: BorderSide(
      color: primaryColor,
    ));

const inputFieldDefaultBorderStyle = OutlineInputBorder(
    gapPadding: 0, borderRadius: BorderRadius.all(Radius.circular(6)));
