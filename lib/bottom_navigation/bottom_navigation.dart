import 'package:flutter/material.dart';
import 'package:oneclick_driver/my_rides.dart';
import 'package:oneclick_driver/notification.dart';
import '../home.dart';
import '../manage/static_method.dart';
import '../my_profile.dart';
import '../values/colors.dart';

Widget bottomBarLayout(ctx, index, {b = false}) {
  return BottomNavigationBar(
    elevation: 10,
    backgroundColor: Clr().white,
    // unselectedItemColor: Clr().black,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Clr().primaryColor,
    unselectedItemColor: Clr().textGrey,
    showSelectedLabels: true,
    selectedFontSize: 14,
    selectedLabelStyle: TextStyle(color: Clr().textcolor),
    currentIndex: index,
    onTap: (i) async {
      switch (i) {
        case 0:
          STM().finishAffinity(ctx, Home());
          break;
        case 1:
          index == 1
              ? STM().replacePage(ctx, NotificationPage())
              : STM().redirect2page(ctx, NotificationPage());
          break;
        case 2:
          index == 2
              ? STM().replacePage(ctx, MyRides())
              : STM().redirect2page(ctx, MyRides());
          break;

        case 3:
          index == 3
              ? STM().replacePage(ctx, MyProfile(index: 3))
              : STM().redirect2page(ctx, MyProfile());
          break;
      }
    },
    items: STM().getBottomList(index, b)
  );
}
