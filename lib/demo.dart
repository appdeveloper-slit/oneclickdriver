import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:oneclick_driver/login.dart';

import 'bottom_navigation/bottom_navigation.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/strings.dart';
import 'values/styles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  late BuildContext ctx;

  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    ctx = context;

    return MaterialApp(
      home: Scaffold(
        bottomNavigationBar: bottomBarLayout(ctx, 3),
        extendBodyBehindAppBar: true,
        backgroundColor: Clr().white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().transparent,
          leadingWidth: 52,
          leading: InkWell(
              onTap: () {
                STM().back2Previous(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    padding: EdgeInsets.only(left: 6),
                    height: 60,
                    width: 40,
                    decoration:
                    BoxDecoration(color: Clr().white, shape: BoxShape.circle),
                    child: Center(
                      child: InkWell(
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Clr().primaryColor,
                          size: 18,
                        ),
                      ),
                    )),
              )),
          toolbarHeight: 60,
          title: Text(
            "My Profile",
            style: Sty().largeText.copyWith(fontSize: 20, color: Clr().white),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: EdgeInsets.all(Dim().d12),
              child: Container(
                  height: 35,
                  width: 35,
                  decoration:
                  BoxDecoration(color: Clr().white, shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          STM().redirect2page(ctx, Login());
                        },
                        child: SvgPicture.asset("assets/exit.svg")),
                  )),
            )
          ],
        ),
        body: Column(
          children: [
            // First Container (Static)
            Container(
              height: 270,
              width: MediaQuery.of(ctx).size.width * 100,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage("assets/myprofile_bg.png"))),
              child: Image.asset(
                "assets/profile.png",
              ),
            ),

            // Second Container (Scrollable)
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(34),
                          topRight: Radius.circular(34),
                        ),
                        color: Clr().white),
                    child: Padding(
                      padding: EdgeInsets.all(Dim().d16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: Dim().d20,
                          ),
                          TextFormField(
                            // controller: nameCtrl,
                            cursorColor: Clr().textcolor,
                            style: Sty().mediumText,
                            keyboardType: TextInputType.name,
                            textInputAction: TextInputAction.done,
                            decoration: Sty().textFieldOutlineStyle.copyWith(
                                hintStyle: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),
                                filled: true,
                                fillColor: Clr().grey,
                                hintText: "Aniket Mahakal",
                                counterText: "",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(Dim().d16),
                                  child: SvgPicture.asset("assets/name.svg"),
                                )),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Str().invalidName;
                              } else {
                                return null;
                              }
                            },
                          ),

                          SizedBox(
                            height: Dim().d20,
                          ),
                          TextFormField(
                            // controller: emailCtrl,
                            cursorColor: Clr().textcolor,
                            style: Sty().mediumText,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            decoration: Sty().textFieldOutlineStyle.copyWith(
                                hintStyle: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),
                                filled: true,
                                fillColor: Clr().grey,
                                hintText: "aniketmahakal1235@gmail.com",
                                counterText: "",
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(Dim().d16),
                                  child: SvgPicture.asset("assets/mail.svg"),
                                )),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return Str().invalidEmail;
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(
                            height: Dim().d20,
                          ),
                          TextFormField(
                            // controller: mobileCtrl,
                            cursorColor: Clr().textcolor,
                            style: Sty().mediumText,
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            decoration: Sty().textFieldOutlineStyle.copyWith(
                                hintStyle: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),
                                filled: true,
                                fillColor: Clr().grey,
                                hintText: "2589633214",
                                counterText: "",
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: Dim().d12),
                                  child: Icon(Icons.edit,
                                      size: 20, color: Clr().primaryColor),
                                ),
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(Dim().d16),
                                  child: SvgPicture.asset("assets/call.svg"),
                                )),

                            validator: (value) {
                              if (value!.isEmpty ||
                                  !RegExp(r'([5-9]{1}[0-9]{9})')
                                      .hasMatch(value)) {
                                return Str().invalidMobile;
                              } else {
                                return null;
                              }
                            },
                          ),
                          SizedBox(
                            height: Dim().d32,
                          ),
                          Center(
                            child: SizedBox(
                              height: 50,
                              width: 285,
                              child: ElevatedButton(
                                  onPressed: () {
                                    // if (_formKey.currentState!.validate()) {
                                    //   STM().checkInternet(context, widget).then((value) {
                                    //     if (value) {
                                    //       // sendOtp();
                                    STM().redirect2page(ctx, MyApp());
                                    //     }
                                    //   });
                                    // }
                                    // ;
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Clr().primaryColor,
                                      elevation: 0.5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                      )),
                                  child: Text(
                                    'Update Profile',
                                    style: Sty().mediumText.copyWith(
                                      fontSize: 16,
                                      color: Clr().white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )),
                            ),
                          ),
                          SizedBox(height: Dim().d32),
                          Card(
                            elevation: 0,
                            child: ExpansionTile(
                              initiallyExpanded: _isExpanded,
                              onExpansionChanged: (bool expanded) {
                                _isExpanded = expanded;
                              },
                              title: RichText(
                                text: TextSpan(
                                  text: "Vehicle ",
                                  style: Sty().smallText.copyWith(
                                      fontSize: 20,
                                      fontFamily: "MulshiBold",
                                      fontWeight: FontWeight.w500,
                                      color: Clr().secondary),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Details',
                                      style: Sty().smallText.copyWith(
                                        color: Clr().textcolor,
                                        fontSize: 20,
                                        fontFamily: "MulshiBold",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'Vehicle type',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        readOnly: true,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "Van",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'Vehicle Number',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "MH05FF8968",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'License Number',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "MH05FF8968",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'RC Number',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "MH05FF8968",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d32,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Card(
                            elevation: 0,
                            child: ExpansionTile(
                              initiallyExpanded: _isExpanded,
                              onExpansionChanged: (bool expanded) {
                                _isExpanded = expanded;

                              },
                              title: RichText(
                                text: TextSpan(
                                  text: "Bank ",
                                  style: Sty().smallText.copyWith(
                                      fontSize: 20,
                                      fontFamily: "MulshiBold",
                                      fontWeight: FontWeight.w500,
                                      color: Clr().secondary),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Details',
                                      style: Sty().smallText.copyWith(
                                        color: Clr().textcolor,
                                        fontSize: 20,
                                        fontFamily: "MulshiBold",
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'Bank Name',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        readOnly: true,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "HDFC Bank",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'Account Number',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "MH05FF8968",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'IFSC Code',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "MH05FF8968",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d20,
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          // v['title'].toString(),
                                          'Account Holder Name',
                                          style: Sty().mediumText.copyWith(
                                              fontWeight: FontWeight.w400,
                                              color: Clr().textcolor),
                                        ),
                                      ),
                                      SizedBox(
                                        height: Dim().d8,
                                      ),
                                      TextFormField(
                                        // controller: aadharCtrl,
                                        cursorColor: Clr().textcolor,
                                        style: Sty().mediumText,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration:
                                        Sty().textFieldOutlineStyle.copyWith(
                                          hintStyle: Sty().smallText.copyWith(
                                            color: Clr().textGrey,
                                          ),
                                          filled: true,
                                          fillColor: Clr().grey,
                                          hintText: "Aniket Mahakal",
                                          counterText: "",
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return Str().invalidEmpty;
                                          } else {
                                            return null;
                                          }
                                        },
                                      ),
                                      SizedBox(
                                        height: Dim().d32,
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: Dim().d32),
                          Row(
                            children: [
                              SizedBox(
                                width: Dim().d8,
                              ),
                              Expanded(
                                  child: Divider(
                                    color: Clr().secondary,
                                  )),
                              SizedBox(
                                width: Dim().d16,
                              ),
                              Text(
                                "Delete My Account",
                                style: Sty().mediumText.copyWith(
                                    color: Clr().secondary,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "MulishSemi"),
                              ),
                              SizedBox(
                                width: Dim().d16,
                              ),
                              Expanded(
                                  child: Divider(
                                    color: Clr().secondary,
                                  )),
                              SizedBox(
                                width: Dim().d8,
                              ),
                            ],
                          ),

                          SizedBox(height: Dim().d32),
                        ],
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
