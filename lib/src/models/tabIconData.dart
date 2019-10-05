import 'package:flutter/material.dart';

class TabIconData {
  String imagePath;
  String selctedImagePath;
  bool isSelected;
  int index;
  AnimationController animationController;

  TabIconData({
    this.imagePath = '',
    this.index = 0,
    this.selctedImagePath = "",
    this.isSelected = false,
    this.animationController,
  });

  static List<TabIconData> tabIconsList = [
    TabIconData(
      imagePath: 'images/menu.png',
      selctedImagePath: 'images/menu.png',
      index: 0,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'images/favorites.png',
      selctedImagePath: 'images/favorites.png',
      index: 1,
      isSelected: false,
      animationController: null,

    ),
    TabIconData(
      imagePath: 'images/orders.png',
      selctedImagePath: 'images/orders.png',
      index: 2,
      isSelected: false,
      animationController: null,

    ),
    TabIconData(
      imagePath: 'images/profile.png',
      selctedImagePath: 'images/profile.png',
      index: 3,
      isSelected: false,
      animationController: null,

    ),
  ];
}
