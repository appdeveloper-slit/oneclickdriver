import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oneclick_driver/bottom_navigation/bottom_navigation.dart';
import 'package:oneclick_driver/demo.dart';
import 'package:oneclick_driver/login.dart';
import 'package:oneclick_driver/my_profile.dart';
import 'package:oneclick_driver/upload_documents.dart';
import 'package:oneclick_driver/values/colors.dart';
import 'package:oneclick_driver/values/dimens.dart';
import 'package:oneclick_driver/vehicle_details.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'manage/static_method.dart';
import 'my_rides.dart';
import 'notification.dart';
import 'values/strings.dart';
import 'values/styles.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BuildContext ctx;

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  int _currentState = 1;
  bool? loading;
  int selectedIndex = -1;
  var pageType, incomeData, ridesTodayData, leadsTodayData;
  String? sValue, usertoken;
  List<dynamic> requestList = [];
  List<String> cancelList = [
    "Bad Location",
    "Low Rider Score",
    "Personal Issue",
    "Distance factor",
    "Rush hour",
    "The passenger is unreachable",
    "Other",
  ];

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      usertoken = sp.getString('token');
    });
    if (usertoken == null) {
      setState(() {
        sp.clear();
        STM().finishAffinity(ctx, Login());
      });
    }
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        print('usertoken : ${usertoken}');
        getHomeApi();
      }
    });
  }

  @override
  void initState() {
    getSession();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return DoubleBack(
      message:
          "Kindly press the button once more to gracefully close the application!!!",
      child: Scaffold(
        bottomNavigationBar: pageType != null && pageType['status'] == 2
            ? SizedBox(height: 0)
            : bottomBarLayout(ctx, 0),
        key: scaffoldState,
        backgroundColor: Clr().white,
        appBar: pageType != null && pageType['status'] == 2
            ? AppBar(
                backgroundColor: Clr().white,
                elevation: 0,
                leading: Container(),
              )
            : AppBar(
                elevation: 0,
                backgroundColor: Clr().white,
                leadingWidth: 52,
                centerTitle: true,
                title: InkWell(
                    onTap: () {
                      // STM().redirect2page(context, UploadDocuments());
                      STM().redirect2page(context, VehicleDetails());
                    },
                    child: Image.asset("assets/home_logo.png")),
                leading: InkWell(
                    onTap: () {
                      // STM().back2Previous(ctx);
                      scaffoldState.currentState!.openDrawer();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                              color: Clr().primaryColor,
                              shape: BoxShape.circle),
                          child: SvgPicture.asset("assets/menu.svg")),
                    )),
              ),
        drawer:
            pageType != null && pageType['status'] == 2 ? null : drawerLayout(),
        body: loading == true
            ? SingleChildScrollView(
                padding: EdgeInsets.all(Dim().d16),
                child: Column(
                  children: [
                    if (pageType != null && pageType['status'] == 0)
                      underReview(),
                    if (pageType != null && pageType['status'] == 2)
                      kycRejected(),
                    if (pageType == null) HomePageLayout(),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }

  Widget underReview() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffEA9B52),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, size: 28),
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Text(
                      'Your KYC is Under Review',
                      style: Sty().mediumText.copyWith(
                            fontSize: 18,
                            color: Clr().white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                )),
          ),
        ),
        SizedBox(
          height: Dim().d20,
        ),
        threeCont(),
        SizedBox(
          height: Dim().d60,
        ),
        SvgPicture.asset("assets/notound.svg"),
        SizedBox(
          height: Dim().d40,
        ),
        Text(
          'No Rides Available',
          style: Sty()
              .mediumText
              .copyWith(fontWeight: FontWeight.w600, color: Clr().primaryColor),
        )
      ],
    );
  }

  Widget threeCont() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: Clr().lightGrey.withOpacity(0.2),
                  spreadRadius: 0.001,
                  blurRadius: 10,
                  offset: Offset(0, -5), // changes position of shadow
                ),
              ],
            ),
            child: Card(
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              )),
              color: Color(0xffFFFCE3),
              child: Padding(
                padding: EdgeInsets.all(Dim().d12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(55),
                          color: Clr().white,
                          border: Border.all(
                            color: Color(0xffFFE08F),
                          )),
                      child: Padding(
                        padding: EdgeInsets.all(Dim().d12),
                        child: SvgPicture.asset("assets/bag.svg"),
                      ),
                    ),
                    SizedBox(
                      height: Dim().d12,
                    ),
                    Container(
                        height: 20,
                        child: Text(
                          "Total Income",
                          overflow: TextOverflow.ellipsis,
                        )),
                    Text(
                      STM().formatAmount(int.parse(incomeData ?? '0')),
                      style: Sty().smallText.copyWith(
                          color: Color(0xffFFE08F),
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: Dim().d2,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: Clr().lightGrey.withOpacity(0.2),
                  spreadRadius: 0.001,
                  blurRadius: 10,
                  offset: Offset(0, -5), // changes position of shadow
                ),
              ],
            ),
            child: Card(
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              )),
              color: Color(0xffE9FFE3),
              child: Padding(
                padding: EdgeInsets.all(Dim().d12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(55),
                          color: Clr().white,
                          border: Border.all(
                            color: Color(0xff93FFBE),
                          )),
                      child: Padding(
                        padding: EdgeInsets.all(Dim().d8),
                        child: SvgPicture.asset("assets/truck.svg"),
                      ),
                    ),
                    SizedBox(
                      height: Dim().d12,
                    ),
                    Container(
                        height: 20,
                        child: Text(
                          "Rides (Today)",
                          overflow: TextOverflow.ellipsis,
                        )),
                    Text(
                      STM().formatAmount(int.parse(ridesTodayData ?? '0')),
                      style: Sty().smallText.copyWith(
                          color: Color(0xff07CB55),
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: Dim().d2,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: Clr().lightGrey.withOpacity(0.2),
                  spreadRadius: 0.001,
                  blurRadius: 10,
                  offset: Offset(0, -5), // changes position of shadow
                ),
              ],
            ),
            child: Card(
              elevation: 0.1,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                topRight: Radius.circular(60),
              )),
              color: Color(0xffE3E6FF),
              child: Padding(
                padding: EdgeInsets.all(Dim().d12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(55),
                          color: Clr().white,
                          border: Border.all(
                            color: Color(0xff928FFF),
                          )),
                      child: Padding(
                        padding: EdgeInsets.all(Dim().d12),
                        child: SvgPicture.asset("assets/cancelled.svg"),
                      ),
                    ),
                    SizedBox(
                      height: Dim().d12,
                    ),
                    SizedBox(
                        height: Dim().d20,
                        child: const Text(
                          "Leads (Today)",
                          overflow: TextOverflow.ellipsis,
                        )),
                    Text(
                      STM().formatAmount(int.parse(leadsTodayData ?? '0')),
                      style: Sty().smallText.copyWith(
                          color: Color(0xff928FFF),
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget kycRejected() {
    return Column(
      children: [
        Center(
          child: SizedBox(
            height: 55,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  AwesomeDialog(
                      context: ctx,
                      dialogType: DialogType.noHeader,
                      dialogBackgroundColor: Clr().white,
                      animType: AnimType.scale,
                      body: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d8, vertical: Dim().d8),
                        child: Column(
                          children: [
                            Text('Reasons',
                                style: Sty().mediumBoldText.copyWith(color: Clr().black)),
                            ListView.builder(
                                itemCount: pageType['reasons'].length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Text(
                                        "${index + 1}. ${pageType['reasons'][index]}",
                                        textAlign: TextAlign.start,
                                        style: Sty().mediumText.copyWith(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      SizedBox(height: Dim().d8),
                                    ],
                                  );
                                }),
                          ],
                        ),
                      )).show();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Clr().red,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info, size: 28),
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Text(
                      'Your KYC is Rejected',
                      style: Sty().mediumText.copyWith(
                            fontSize: 18,
                            color: Clr().white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                )),
          ),
        ),
        SizedBox(
          height: Dim().d20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: Clr().primaryColor,
            ),
            SizedBox(
              width: Dim().d12,
            ),
            Text(
              "Lorem ipsum dolor sit amet consectetur",
              style: Sty().smallText.copyWith(color: Clr().primaryColor),
            )
          ],
        ),
        SizedBox(
          height: Dim().d20,
        ),
        Center(
          child: SizedBox(
            height: 50,
            width: 285,
            child: ElevatedButton(
                onPressed: () {
                  if (!pageType['is_document_verified'] &&
                      !pageType['is_vehicle_detail_verified']) {
                    STM().redirect2page(
                        ctx,
                        UploadDocuments(
                          type: 'home',
                          vehicleDetails: true,
                        ));
                  } else if (!pageType['is_document_verified'] &&
                      pageType['is_vehicle_detail_verified']) {
                    STM().redirect2page(
                        ctx,
                        UploadDocuments(
                          type: 'home',
                          vehicleDetails: false,
                        ));
                  } else if (pageType['is_document_verified'] &&
                      !pageType['is_vehicle_detail_verified']) {
                    STM().redirect2page(
                        ctx,
                        VehicleDetails(
                          type: 'home',
                        ));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Clr().primaryColor,
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
                child: Text(
                  'Redo KYC',
                  style: Sty().mediumText.copyWith(
                        fontSize: 16,
                        color: Clr().white,
                        fontWeight: FontWeight.w600,
                      ),
                )),
          ),
        ),
        SizedBox(
          height: Dim().d20,
        ),
        Row(
          children: [
            Expanded(
                child: Divider(
              color: Clr().primaryColor,
              thickness: 0.6,
            )),
            SizedBox(
              width: Dim().d12,
            ),
            Text(
              "Contact Us",
              style: Sty().mediumText.copyWith(
                    color: Clr().primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(
              width: Dim().d12,
            ),
            Expanded(
                child: Divider(
              color: Clr().primaryColor,
              thickness: 0.6,
            )),
          ],
        )
      ],
    );
  }

  Widget CardLayout() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Clr().borderColor.withOpacity(1),
                  spreadRadius: 0.1,
                  blurRadius: 6,
                  offset: Offset(
                    0,
                    6,
                  ) // changes position of shadow
                  ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Clr().borderColor)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: Dim().d12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Clr().primaryColor,
                    ),
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: Sty().mediumText.copyWith(
                                      color: Clr().textcolor,
                                    ),
                              ),
                              SizedBox(
                                height: Dim().d4,
                              ),
                              Text(
                                '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Sty()
                                    .smallText
                                    .copyWith(color: Clr().primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SvgPicture.asset("assets/cash.svg"),
                        SizedBox(
                          height: Dim().d12,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            "View Map",
                            style: Sty().smallText.copyWith(
                                height: 1.2,
                                color: Clr().primaryColor,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Clr().primaryColor),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: Dim().d12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Icon(
                      Icons.circle,
                      size: 10,
                      color: Clr().green,
                    ),
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: Sty().mediumText.copyWith(
                                      color: Clr().textcolor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              SizedBox(
                                height: Dim().d4,
                              ),
                              Text(
                                '2972 Westheimer Rd. Santa Ana, Illinois 85486 ',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: Sty()
                                    .smallText
                                    .copyWith(color: Clr().primaryColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Text(
                            "View Map",
                            style: Sty().smallText.copyWith(
                                height: 1.2,
                                color: Clr().primaryColor,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                                decorationColor: Clr().primaryColor),
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(
                  height: Dim().d16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dim().d8),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: Dim().d8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Pick-up Date:",
                                style: Sty()
                                    .microText
                                    .copyWith(color: Clr().grey2),
                              ),
                              SizedBox(
                                height: Dim().d4,
                              ),
                              Text(
                                "04/10/2023",
                                style: Sty().smallText.copyWith(
                                    color: Clr().primaryColor,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Container(
                            color: Clr().primaryColor,
                            height: 25,
                            width: 0.5,
                          ),
                          Column(
                            children: [
                              Text(
                                "Pick-up Time:",
                                style: Sty()
                                    .microText
                                    .copyWith(color: Clr().grey2),
                              ),
                              SizedBox(
                                height: Dim().d4,
                              ),
                              Text(
                                "04:00pm",
                                style: Sty().smallText.copyWith(
                                    color: Clr().yellow,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                          Container(
                            color: Clr().primaryColor,
                            height: 25,
                            width: 0.5,
                          ),
                          Column(
                            children: [
                              Text(
                                "Amount Payable",
                                style: Sty()
                                    .microText
                                    .copyWith(color: Clr().grey2),
                              ),
                              SizedBox(
                                height: Dim().d4,
                              ),
                              Text(
                                "₹405(Est.)",
                                style: Sty().smallText.copyWith(
                                    color: Clr().green,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: Dim().d20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dim().d12),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        child: Divider(
                          color: Clr().primaryColor,
                          thickness: 0.4,
                        ),
                      ),
                      SizedBox(
                        width: Dim().d12,
                      ),
                      Text(
                        "Goods type",
                        style: Sty().mediumText.copyWith(
                              color: Clr().primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(
                        width: Dim().d12,
                      ),
                      Expanded(
                          child: Divider(
                        color: Clr().primaryColor,
                        thickness: 0.4,
                      )),
                    ],
                  ),
                ),
                SizedBox(
                  height: Dim().d12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dim().d12),
                  child: Text(
                    'Electrical / Electronics / Home Appliances',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty().smallText.copyWith(color: Clr().primaryColor),
                  ),
                ),
                SizedBox(
                  height: Dim().d20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Clr().primaryColor,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      )),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dim().d16,
                      vertical: Dim().d8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '08:58',
                          style: Sty().mediumText.copyWith(
                              color: Clr().white, fontWeight: FontWeight.w600),
                        ),
                        Wrap(
                          children: [
                            InkWell(
                              onTap: () {
                                _cancelDialog(ctx);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(55),
                                    color: Clr().white,
                                    border: Border.all(
                                      color: Clr().primaryColor,
                                    )),
                                child: Padding(
                                  padding: EdgeInsets.all(Dim().d12),
                                  child: SvgPicture.asset("assets/cancel.svg"),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Dim().d20,
                            ),
                            InkWell(
                              onTap: () {
                                _rideConfirmedDialog(ctx);
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(55),
                                    color: Clr().white,
                                    border: Border.all(
                                      color: Clr().primaryColor,
                                    )),
                                child: Padding(
                                  padding: EdgeInsets.all(Dim().d12),
                                  child: SvgPicture.asset("assets/accept.svg"),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget HomePageLayout() {
    return Column(
      children: [
        threeCont(),
        SizedBox(
          height: Dim().d20,
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: 12,
          itemBuilder: (context, index) {
            // var v = notificationList[index];
            return CardLayout();
          },
          separatorBuilder: (context, index) {
            return SizedBox(
              height: Dim().d12,
            );
          },
        ),
      ],
    );
  }

  _rideConfirmedDialog(ctx) {
    AwesomeDialog(
      isDense: false,
      context: ctx,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      alignment: Alignment.centerLeft,
      body: Container(
        child: Column(
          children: [
            SvgPicture.asset("assets/accept_request.svg"),
            RichText(
              text: TextSpan(
                text: "Est.Fare ",
                style: Sty().smallText.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Clr().textcolor),
                children: <TextSpan>[
                  TextSpan(
                    text: '₹405',
                    style: Sty().smallText.copyWith(
                          color: Clr().secondary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: Dim().d8,
            ),
            Text(
              'Are you sure you will provide the Vehicle?',
              textAlign: TextAlign.center,
              style: Sty().mediumText.copyWith(
                    color: Clr().textGrey,
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
            ),
            SizedBox(
              height: Dim().d24,
            ),
            Row(
              children: [
                SizedBox(
                  width: Dim().d8,
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Clr().white,
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Clr().primaryColor),
                              borderRadius: BorderRadius.circular(50),
                            )),
                        child: Text(
                          'No',
                          style: Sty().mediumText.copyWith(
                                fontSize: 16,
                                color: Clr().primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        )),
                  ),
                ),
                SizedBox(
                  width: Dim().d12,
                ),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                        onPressed: () {
                          // if (formKey.currentState!.validate()) {
                          //   STM().checkInternet(context, widget).then((value) {
                          //     if (value) {
                          //       // sendOtp();
                          STM().redirect2page(ctx, MyRides());
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
                          'Yes',
                          style: Sty().mediumText.copyWith(
                                fontSize: 16,
                                color: Clr().white,
                                fontWeight: FontWeight.w600,
                              ),
                        )),
                  ),
                ),
                SizedBox(
                  width: Dim().d8,
                ),
              ],
            ),
            SizedBox(
              height: Dim().d16,
            ),
          ],
        ),
      ),
    ).show();
  }

  _cancelDialog(ctx) {
    AwesomeDialog(
      isDense: true,
      context: ctx,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      alignment: Alignment.centerLeft,
      body: StatefulBuilder(builder: (context, setState) {
        return Container(
          child: Column(
            children: [
              Text(
                'Cancellation Reason',
                style: Sty().mediumText.copyWith(
                      color: Clr().textcolor,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
              ),
              ListView.separated(
                shrinkWrap: true,
                itemCount: cancelList.length,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isSelected = selectedIndex == index;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2.0, horizontal: 16.0),
                      child: Row(
                        children: [
                          isSelected
                              // work.contains(workTypeList[index]) || (selectAll && index > 0)
                              // ?Icon(Icons.circle):Icon(Icons.circle_outlined),
                              ? SvgPicture.asset(
                                  'assets/tick.svg',
                                  width: 23,
                                  color: Clr().secondary,
                                )
                              : Icon(Icons.circle_outlined,
                                  size: 24,
                                  color: Clr().shimmerColor,
                                  weight: 0.5),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            cancelList[index].toString(),
                            style: TextStyle(
                              color: isSelected
                                  ? Clr().secondary
                                  : Clr().textcolor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: Dim().d12,
                  );
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
                        // STM().redirect2page(ctx, MyRides());
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Clr().primaryColor,
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      child: Text(
                        'Submit',
                        style: Sty().mediumText.copyWith(
                              fontSize: 16,
                              color: Clr().white,
                              fontWeight: FontWeight.w600,
                            ),
                      )),
                ),
              ),
              SizedBox(
                height: Dim().d24,
              ),
            ],
          ),
        );
      }),
    ).show();
  }

  Widget drawerLayout() {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        child: Drawer(
          width: MediaQuery.of(context).size.width * 0.75,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(color: Clr().white),
            child: WillPopScope(
              onWillPop: () async {
                if (scaffoldState.currentState!.isDrawerOpen) {
                  scaffoldState.currentState!.openEndDrawer();
                }
                return true;
              },
              child: ListView(
                children: <Widget>[
                  Container(
                    color: Clr().white,
                    child: Column(
                      children: [
                        Padding(
                            padding: EdgeInsets.only(
                                top: Dim().d60, right: Dim().d20),
                            child: Image.asset(
                              "assets/home_logo.png",
                              width: 250,
                            )),
                        SizedBox(
                          height: Dim().d20,
                        ),
                        Divider()
                      ],
                    ),
                    // width: 150,
                    height: 180,
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_truck.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'My Rides',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          STM().redirect2page(ctx, MyRides());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_notification.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Notification',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          STM().redirect2page(ctx, NotificationPage());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_privacy_policy.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Privacy Policy',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          // STM().redirect2page(ctx, FeedbackPage());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_t&c.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Terms & Conditions',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          // STM().redirect2page(ctx, MyProfile());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_share.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Share App',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_about.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'About Us',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          // STM().redirect2page(ctx, Contact());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_contact.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Contact Us',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          sValue = "Home";
                          scaffoldState.currentState?.closeEndDrawer();
                          // STM().redirect2page(ctx, Contact());
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8, left: 8),
                    // decoration: BoxDecoration(color: Color(0xffABE68C)),
                    child: ListTile(
                      leading: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/d_log_out.svg',
                        ),
                      ),
                      title: Transform.translate(
                        offset: Offset(-10, 0),
                        child: Text(
                          'Log Out',
                          style: Sty().mediumText.copyWith(
                              fontSize: 14,
                              color: Clr().textcolor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Log Out',
                                    style: Sty().mediumBoldText),
                                content: Text('Are you sure want to Log Out?',
                                    style: Sty().mediumText),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() async {
                                          SharedPreferences sp =
                                              await SharedPreferences
                                                  .getInstance();
                                          sp.setBool('login', false);
                                          sp.clear();
                                          STM().finishAffinity(ctx, Login());
                                        });
                                        // deleteProfile();
                                      },
                                      child: Text('Yes',
                                          style: Sty().smallText.copyWith(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w600))),
                                  TextButton(
                                      onPressed: () {
                                        STM().back2Previous(ctx);
                                      },
                                      child: Text('No',
                                          style: Sty().smallText.copyWith(
                                              fontWeight: FontWeight.w600))),
                                ],
                              );
                            });
                        // deleteData();
                      },
                    ),
                  ),
                  SizedBox(
                    height: Dim().d20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void getHomeApi() async {
    FormData body = FormData.fromMap({
      'uuid': OneSignal.User.pushSubscription.id,
    });
    var result =
        await STM().postget(ctx, Str().loading, 'get_request', body, usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        loading = true;
        incomeData = result['total_income'];
        ridesTodayData = result['rides_today'];
        leadsTodayData = result['leads_today'];
        requestList = result['data'];
      });
    } else {
      setState(() {
        loading = true;
        pageType = result['data'];
      });
      STM().errorDialog(ctx, result['message'],
          type: result['data']['status'] == 0
              ? DialogType.noHeader
              : DialogType.error);
    }
  }
}
