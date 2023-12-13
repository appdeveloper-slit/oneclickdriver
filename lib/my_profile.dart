import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'demo.dart';
import 'home.dart';
import 'login.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/strings.dart';
import 'values/styles.dart';

class MyProfile extends StatefulWidget {
  final index;

  const MyProfile({super.key,  this.index});

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  late BuildContext ctx;

  bool _isExpanded = false;
  var sToken, details;
  final formKey = GlobalKey<FormState>();
  TextEditingController mobileCtrl = TextEditingController();
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController updatenumberCtrl = TextEditingController();
  TextEditingController updateUserOtpController = TextEditingController();
  bool again = false;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      sToken = sp.getString('token');
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        print('sToken : ${sToken}');
        apiIntegrate(type: 'get', value: '', apiname: 'profile_details');
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return WillPopScope(
      onWillPop: () async {
        widget.index == 3
            ? STM().finishAffinity(ctx, Home())
            : STM().back2Previous(ctx);
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: bottomBarLayout(ctx, 3),
        extendBodyBehindAppBar: true,
        backgroundColor: Clr().white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().transparent,
          leadingWidth: 52,
          leading: InkWell(
              onTap: () {
                widget.index == 3
                    ? STM().finishAffinity(ctx, Home())
                    : STM().back2Previous(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    padding: EdgeInsets.only(left: 6),
                    height: 60,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Clr().white, shape: BoxShape.circle),
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
                  height: 33,
                  width: 33,
                  decoration:
                      BoxDecoration(color: Clr().white, shape: BoxShape.circle),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/exit.png'),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      Text('Logout?',
                                          style: Sty().mediumBoldText),
                                      SizedBox(
                                        height: Dim().d12,
                                      ),
                                      Text('Are you sure want to Log Out?',
                                          style: Sty().mediumText),
                                      SizedBox(
                                        height: Dim().d28,
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() async {
                                              SharedPreferences sp =
                                              await SharedPreferences
                                                  .getInstance();
                                              sp.setBool('login', false);
                                              sp.clear();
                                              STM().finishAffinity(ctx, Login());
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Clr().primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(
                                                      Radius.circular(
                                                          Dim().d12)))),
                                          child: Center(
                                            child: Text('Log Out',
                                                style: Sty()
                                                    .mediumText
                                                    .copyWith(
                                                    color: Clr().white)),
                                          )),
                                    ],
                                  ),
                                );
                              });
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
                      fit: BoxFit.fill,
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
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: Dim().d20,
                            ),
                            TextFormField(
                              controller: nameCtrl,
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
                              controller: emailCtrl,
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
                              controller: mobileCtrl,
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
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      mobileUpdate(ctx);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(right: Dim().d12),
                                      child: Icon(Icons.edit,
                                          size: 20, color: Clr().primaryColor),
                                    ),
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
                                      if (formKey.currentState!.validate()) {
                                        apiIntegrate(
                                            type: 'post',
                                            value: '',
                                            apiname: 'update_profile');
                                      }
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
                            Card(color: Clr().white,
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                            Divider(
                              color: Clr().borderColor,
                            ),
                            Card(
                              color: Clr().white,
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                          decoration: Sty()
                                              .textFieldOutlineStyle
                                              .copyWith(
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
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('Delete Account',
                                                style: Sty().mediumBoldText),
                                            content: Text(
                                                'Are you sure want to delete account?',
                                                style: Sty().mediumText),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    // getProfile(
                                                    //     apiname: 'delete_account', type: 'get');
                                                  },
                                                  child: Text('Yes',
                                                      style: Sty()
                                                          .smallText
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight
                                                              .w600))),
                                              TextButton(
                                                  onPressed: () {
                                                    STM().back2Previous(ctx);
                                                  },
                                                  child: Text('No',
                                                      style: Sty()
                                                          .smallText
                                                          .copyWith(
                                                          fontWeight:
                                                          FontWeight
                                                              .w600))),
                                            ],
                                          );
                                        });
                                  },
                                  child: Text(
                                    "Delete My Account",
                                    style: Sty().mediumText.copyWith(
                                        color: Clr().secondary,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "MulishSemi"),
                                  ),
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
                      ),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
  ///Update number pop up
  Future mobileUpdate(ctx) async {
    TextEditingController mobilectrl = TextEditingController();
    TextEditingController otpctrl = TextEditingController();
    bool loading = false;
    final _formKey = GlobalKey<FormState>();
    bool? checkStatus;
    bool? checkStatus1;
    return AwesomeDialog(
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        dialogType: DialogType.noHeader,
        width: 600.0,
        isDense: true,
        context: ctx,
        body: StatefulBuilder(builder: (ctx, setState) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                loading == false
                    ? Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text('Enter Mobile Number',
                          style: Sty()
                              .mediumText
                              .copyWith(fontWeight: FontWeight.w600)),
                      SizedBox(height: Dim().d20),
                      TextFormField(
                        controller: updatenumberCtrl,
                        maxLength: 10,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          if (v!.isEmpty) {
                            return 'Mobile number is required';
                          }
                          if (v.length != 10) {
                            return 'Mobile number digits must be 10';
                          }
                          return null;
                        },
                        decoration: Sty()
                            .TextFormFieldOutlineDarkStyle
                            .copyWith(
                            hintText: 'Enter Mobile Number',
                            counterText: "",
                            hintStyle: Sty()
                                .mediumText
                                .copyWith(color: Clr().hintColor)),
                      ),
                      SizedBox(height: Dim().d20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Clr().primaryColor),
                                onPressed: () {
                                  STM().back2Previous(ctx);
                                },
                                child: Center(
                                  child: Text('Cancel',
                                      style: Sty()
                                          .mediumText
                                          .copyWith(color: Clr().white)),
                                )),
                          ),
                          SizedBox(width: Dim().d8),
                          checkStatus == true
                              ? CircularProgressIndicator(
                              color: Clr().primaryColor)
                              : Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Clr().primaryColor),
                                onPressed: () async {
                                  if (_formKey.currentState!
                                      .validate()) {
                                    setState(() {
                                      checkStatus = true;
                                    });
                                    FormData body =
                                    FormData.fromMap({
                                      'mobile':
                                      updatenumberCtrl.text,
                                    });
                                    var result = await STM()
                                        .postWithToken(
                                        ctx,
                                        Str().sendingOtp,
                                        'update_mobile_sent_otp',
                                        body,
                                        sToken);
                                    if (result['success'] == true) {
                                      setState(() {
                                        loading = true;
                                        checkStatus = false;
                                      });
                                    } else {
                                      setState(() {
                                        checkStatus = false;
                                        loading = false;
                                        mobilectrl.clear();
                                        AwesomeDialog(
                                            context: ctx,
                                            dismissOnBackKeyPress:
                                            false,
                                            dismissOnTouchOutside:
                                            false,
                                            dialogType:
                                            DialogType
                                                .ERROR,
                                            animType:
                                            AnimType.SCALE,
                                            headerAnimationLoop:
                                            true,
                                            title: 'Note',
                                            desc: result[
                                            'message'],
                                            btnOkText: "OK",
                                            btnOkOnPress: () {
                                              Navigator.pop(
                                                  ctx);
                                            },
                                            btnOkColor:
                                            Clr().errorRed)
                                            .show();
                                      });
                                    }
                                  }
                                },
                                child: Center(
                                  child: Text('Send OTP',
                                      style: Sty()
                                          .mediumText
                                          .copyWith(
                                          color: Clr().white)),
                                )),
                          )
                        ],
                      ),
                    ],
                  ),
                )
                    : Column(
                  children: [
                    Text('Enter OTP',
                        style: Sty()
                            .mediumText
                            .copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: Dim().d20),
                    TextFormField(
                      controller: updateUserOtpController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: Sty()
                          .TextFormFieldOutlineDarkStyle
                          .copyWith(
                          hintText: 'Enter OTP',
                          counterText: '',
                          hintStyle: Sty()
                              .mediumText
                              .copyWith(color: Clr().hintColor)),
                    ),
                    SizedBox(
                      height: Dim().d4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Request new code in ",
                          style: Sty().smallText.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Clr().textcolor),
                        ),
                        Visibility(
                          visible: !again,
                          child: TweenAnimationBuilder<Duration>(
                              duration: const Duration(seconds: 60),
                              tween: Tween(
                                  begin: const Duration(seconds: 60),
                                  end: Duration.zero),
                              onEnd: () {
                                // ignore: avoid_print
                                // print('Timer ended');
                                setState(() {
                                  again = true;
                                });
                              },
                              builder: (BuildContext context,
                                  Duration value, Widget? child) {
                                final minutes = value.inMinutes;
                                final seconds = value.inSeconds % 60;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5),
                                  child: Text(
                                    "0$minutes:$seconds",
                                    textAlign: TextAlign.center,
                                    style: Sty().smallText.copyWith(
                                        color: Clr().secondary,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "MulshiSemi",
                                        fontSize: 14),
                                  ),
                                );
                              }),
                        ),
                        // Visibility(
                        //   visible: !isResend,
                        //   child: Text("I didn't receive a code! ${(  sTime  )}",
                        //       style: Sty().mediumText),
                        // ),
                        Visibility(
                          visible: again,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                again = false;
                              });
                              resendOTP(updatenumberCtrl.text);
                            },
                            child: Text(
                              'Resend',
                              style: Sty().smallText.copyWith(
                                  color: Clr().secondary,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "MulshiSemi",
                                  fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dim().d20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Clr().primaryColor),
                              onPressed: () {
                                setState(() {
                                  loading = false;
                                  otpctrl.clear();
                                  mobilectrl.clear();
                                });
                              },
                              child: Center(
                                child: Text('Back',
                                    style: Sty()
                                        .mediumText
                                        .copyWith(color: Clr().white)),
                              )),
                        ),
                        SizedBox(width: Dim().d12),
                        checkStatus1 == true
                            ? CircularProgressIndicator(
                            color: Clr().primaryColor)
                            : Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  Clr().primaryColor),
                              onPressed: () async {
                                setState(() {
                                  checkStatus1 = true;
                                });
                                FormData body = FormData.fromMap({
                                  'mobile': updatenumberCtrl.text,
                                  'otp':
                                  updateUserOtpController.text,
                                });
                                var result = await STM()
                                    .postWithToken(
                                    ctx,
                                    Str().processing,
                                    'update_mobile_verify_otp',
                                    body,
                                    sToken);
                                if (result['success']) {
                                  setState(() {
                                    checkStatus1 = false;
                                    otpctrl.clear();
                                    mobilectrl.clear();
                                  });
                                  STM().replacePage(
                                      ctx, MyProfile(index: 3));
                                } else {
                                  setState(() {
                                    checkStatus1 = false;
                                    otpctrl.clear();
                                  });
                                  STM().errorDialog(
                                      ctx, result['message']);
                                }
                              },
                              child: Center(
                                child: Text('Submit',
                                    style: Sty()
                                        .mediumText
                                        .copyWith(
                                        color: Clr().white)),
                              )),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        })).show();
  }

  /// api intgertaion
  apiIntegrate({apiname, type, value}) async {
    var data = FormData.fromMap({});
    switch (apiname) {
      case 'update_mobile_verify_otp':
        data = FormData.fromMap({
          'mobile': value[0],
          'otp': value[1],
        });
        break;
      case 'update_profile':
        data = FormData.fromMap({
          'name': nameCtrl.text,
          'email': emailCtrl.text,
        });
        break;
    }
    FormData body = data;
    var result = type == 'post'
        ? await STM().postWithToken(ctx, Str().loading, apiname, body, sToken)
        : await STM().getcat(ctx, Str().loading, apiname, sToken);
    switch (apiname) {
      case 'profile_details':
        if (result['success']) {
          setState(() {
            details = result['data'];
            nameCtrl = TextEditingController(text: details['name'].toString());
            emailCtrl =
                TextEditingController(text: details['email'].toString());
            mobileCtrl =
                TextEditingController(text: details['mobile'].toString());
          });
        } else {
          setState(() {
            STM().errorDialog(ctx, result['message']);
          });
        }
        break;
      case 'update_profile':
        if (result['success']) {
          STM().displayToast(result['message']);
          STM().replacePage(ctx, MyProfile(index: 3));
        } else {
          setState(() {
            STM().errorDialog(ctx, result['message']);
          });
        }
        break;
    }
  }

  /// resend otp
  void resendOTP(mobile) async {
    //Input
    FormData body = FormData.fromMap({
      'mobile': mobile,
    });
    //Output
    var result = await STM().post(ctx, Str().sendingOtp, "resent_otp", body);
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (!mounted) return;
    var success = result['success'];
    var message = result['message'];
    if (success) {
      STM().displayToast(message);
    } else {
      STM().errorDialog(ctx, message);
      // _showSuccessDialog(ctx,message);
    }
  }
}
