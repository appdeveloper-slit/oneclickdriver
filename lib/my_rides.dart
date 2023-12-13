import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'manage/static_method.dart';
import 'loading_session.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class MyRides extends StatefulWidget {
  @override
  State<MyRides> createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  late BuildContext ctx;

  bool _isExpanded = false;
  bool isHasTrailing = false;

  String? _pinCode;
  TextEditingController otpCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<dynamic> resultList = [];
  List<dynamic> completeList = [];

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return WillPopScope(
      onWillPop: () async {
        STM().back2Previous(ctx);
        return false;
      },
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          bottomNavigationBar: bottomBarLayout(ctx, 2),
            backgroundColor: Clr().white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Clr().white,
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
                        decoration: BoxDecoration(
                            color: Clr().primaryColor, shape: BoxShape.circle),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Clr().white,
                            size: 18,
                          ),
                        )),
                  )),
              toolbarHeight: 60,
              title: Text(
                "My Rides",
                style: Sty()
                    .largeText
                    .copyWith(fontSize: 20, color: Clr().textcolor),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(40.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Clr().lightGrey),
                    ),
                  ),
                  child: TabBar(
                    indicatorColor: Clr().secondary,
                    labelColor: Clr().secondary,
                    labelStyle: Sty().smallText,
                    isScrollable: true,
                    unselectedLabelColor: Clr().textGrey,
                    tabs: const [
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Ongoing'),
                      Tab(text: 'Completed'),
                      Tab(text: 'Cancelled'),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                ListView.separated(
                  padding: EdgeInsets.all(Dim().d8),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return upcomingLayout(ctx, index, resultList);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: Dim().d20,
                    );
                  },
                ),
                ListView.separated(
                  padding: EdgeInsets.all(Dim().d8),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return onGoingLayout(ctx, index, resultList);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: Dim().d20,
                    );
                  },
                ),
                ListView.separated(
                  padding: EdgeInsets.all(Dim().d8),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return completeLayout(ctx, index, resultList);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: Dim().d20,
                    );
                  },
                ),
                ListView.separated(
                  padding: EdgeInsets.all(Dim().d8),
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return cancelLayout(ctx, index, resultList);
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: Dim().d20,
                    );
                  },
                ),
              ],
            )),
      ),
    );
  }

  /// Upcoming request Layout
  Widget upcomingLayout(ctx, index, list) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Clr().borderColor.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(
          //   color: Colors.grey,
          //   width: 0.5,
          // ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dim().d12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip ID : 2135563',
                    style: Sty().microText.copyWith(
                        color: Clr().grey2
                    ),),
                  Text('14/10/2023 | 12:30Pm',
                    style: Sty().microText.copyWith(
                        color: Color(0xff939393)
                    ),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d12),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: Sty().smallText.copyWith(
                      color: Clr().primaryColor,
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
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),

                  SizedBox(height: Dim().d8,),
                  Text(
                    'To',
                    style: Sty().smallText.copyWith(
                      color: Clr().red,
                    ),
                  ),

                  SizedBox(
                    height: Dim().d4,
                  ),
                  Text(
                    '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty()
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Goods type',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Building / Construction',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Date & Time',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Dec 18, 2023|12:30Pm',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Est. Fare',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('₹500',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Text('Pick up contact :',
                    style: Sty().mediumText.copyWith(
                      color: Color(0xff7a7a7a),
                    ),),
                  SizedBox(height: Dim().d8,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aniket Mahakal',
                        style: Sty().mediumText.copyWith(
                            color: Clr().primaryColor
                        ),),
                      Wrap(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 90,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff07CB55),
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Clr().white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: Dim().d8,
                                    ),
                                    Text(
                                      'Call',
                                      style: Sty().mediumText.copyWith(
                                        fontSize: 14,
                                        color: Clr().white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(width: Dim().d8,),
                          SizedBox(
                            height: 35,
                            width: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Clr().white,
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Color(0xff7a7a7a).withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: SvgPicture.asset('assets/pin.svg')),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  SizedBox(height: Dim().d12,),
                  Row(
                    children: [
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
                                    side: BorderSide(color: Clr().red),
                                    borderRadius: BorderRadius.circular(50),
                                  )),
                              child: Text(
                                'Cancel Ride',
                                style: Sty().mediumText.copyWith(
                                  fontSize: 16,
                                  color: Clr().red,
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
                                _enterOTPDialog(ctx);
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
                                'Start Ride',
                                style: Sty().mediumText.copyWith(
                                  fontSize: 16,
                                  color: Clr().white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d20,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

///On going Layout
  Widget onGoingLayout(ctx, index, list) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Clr().borderColor.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(
          //   color: Colors.grey,
          //   width: 0.5,
          // ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dim().d12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip ID : 2135563',
                    style: Sty().microText.copyWith(
                        color: Clr().grey2
                    ),),
                  Text('14/10/2023 | 12:30Pm',
                    style: Sty().microText.copyWith(
                        color: Color(0xff939393)
                    ),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d12),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: Sty().smallText.copyWith(
                      color: Clr().primaryColor,
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
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),

                  SizedBox(height: Dim().d8,),
                  Text(
                    'To',
                    style: Sty().smallText.copyWith(
                      color: Clr().red,
                    ),
                  ),

                  SizedBox(
                    height: Dim().d4,
                  ),
                  Text(
                    '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty()
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Goods type',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Building / Construction',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Date & Time',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Dec 18, 2023|12:30Pm',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Est. Fare',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('₹500',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Text('Pick up contact :',
                    style: Sty().mediumText.copyWith(
                      color: Color(0xff7a7a7a),
                    ),),
                  SizedBox(height: Dim().d8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Aniket Mahakal',
                        style: Sty().mediumText.copyWith(
                            color: Clr().primaryColor
                        ),),
                      Wrap(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 90,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff07CB55),
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Clr().white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: Dim().d8,
                                    ),
                                    Text(
                                      'Call',
                                      style: Sty().mediumText.copyWith(
                                        fontSize: 14,
                                        color: Clr().white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(width: Dim().d8,),
                          SizedBox(
                            height: 35,
                            width: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Clr().white,
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Color(0xff7a7a7a).withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: SvgPicture.asset('assets/pin.svg')),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Text('Receiver contact :',
                    style: Sty().mediumText.copyWith(
                      color: Color(0xff7a7a7a),
                    ),),
                  SizedBox(height: Dim().d8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Darshan Jadhav',
                        style: Sty().mediumText.copyWith(
                            color: Clr().primaryColor
                        ),),
                      Wrap(
                        children: [
                          SizedBox(
                            height: 35,
                            width: 90,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xff07CB55),
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.call,
                                      color: Clr().white,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: Dim().d8,
                                    ),
                                    Text(
                                      'Call',
                                      style: Sty().mediumText.copyWith(
                                        fontSize: 14,
                                        color: Clr().white,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                          SizedBox(width: Dim().d8,),
                          SizedBox(
                            height: 35,
                            width: 50,
                            child: ElevatedButton(
                                onPressed: () {
                                  // if (formKey.currentState!.validate()) {
                                  //   STM().checkInternet(context, widget).then((value) {
                                  //     if (value) {
                                  //       // sendOtp();
                                  // STM().redirect2page(ctx, RequestDetails());
                                  //     }
                                  //   });
                                  // };
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Clr().white,
                                    elevation: 0.5,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(color: Color(0xff7a7a7a).withOpacity(0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    )),
                                child: SvgPicture.asset('assets/pin.svg')),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),

                  Divider(),
                  SizedBox(height: Dim().d12,),
                  Center(
                    child: SizedBox(
                      height: 40,
                      width: 180,
                      child: ElevatedButton(
                          onPressed: () {
                            // if (formKey.currentState!.validate()) {
                            //   STM().checkInternet(context, widget).then((value) {
                            //     if (value) {
                            //       // sendOtp();
                            // STM().redirect2page(ctx, MyRides());
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
                            'Load Session',
                            style: Sty().mediumText.copyWith(
                              fontSize: 16,
                              color: Clr().white,
                              fontWeight: FontWeight.w600,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(height: Dim().d20,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// Completed Layout
  Widget completeLayout(ctx, index, list){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Clr().borderColor.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(
          //   color: Colors.grey,
          //   width: 0.5,
          // ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dim().d12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip ID : 2135563',
                    style: Sty().microText.copyWith(
                        color: Clr().grey2
                    ),),
                  Text('14/10/2023 | 12:30Pm',
                    style: Sty().microText.copyWith(
                        color: Color(0xff939393)
                    ),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d12),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: Sty().smallText.copyWith(
                      color: Clr().primaryColor,
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
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),

                  SizedBox(height: Dim().d8,),
                  Text(
                    'To',
                    style: Sty().smallText.copyWith(
                      color: Clr().red,
                    ),
                  ),

                  SizedBox(
                    height: Dim().d4,
                  ),
                  Text(
                    '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty()
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Goods type',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Building / Construction',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Date & Time',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Dec 18, 2023|12:30Pm',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Est. Fare',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('₹500',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Text('Pick up contact :',
                    style: Sty().mediumText.copyWith(
                      color: Color(0xff7a7a7a),
                    ),),
                  SizedBox(height: Dim().d8,),
                  Text('Aniket Mahakal',
                    style: Sty().mediumText.copyWith(
                        color: Clr().primaryColor
                    ),),
                  SizedBox(height: Dim().d8,),
                  Text('+91 25896 32145',
                    style: Sty().smallText.copyWith(
                        color: Clr().textcolor
                    ),),
                  SizedBox(height: Dim().d20,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  /// Cancel request Layout
  Widget cancelLayout(ctx, index, list) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Clr().borderColor.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          // side: BorderSide(
          //   color: Colors.grey,
          //   width: 0.5,
          // ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(Dim().d12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Trip ID : 2135563',
                    style: Sty().microText.copyWith(
                        color: Clr().grey2
                    ),),
                  Text('14/10/2023 | 12:30Pm',
                    style: Sty().microText.copyWith(
                        color: Color(0xff939393)
                    ),),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d12),
              child: Divider(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'From',
                    style: Sty().smallText.copyWith(
                      color: Clr().primaryColor,
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
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),

                  SizedBox(height: Dim().d8,),
                  Text(
                    'To',
                    style: Sty().smallText.copyWith(
                      color: Clr().red,
                    ),
                  ),

                  SizedBox(
                    height: Dim().d4,
                  ),
                  Text(
                    '1901 Thornridge Cir. Shiloh, Hawaii 81063',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty()
                        .microText
                        .copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Goods type',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Building / Construction',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Date & Time',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('Dec 18, 2023|12:30Pm',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d8,),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text('Est. Fare',
                          style: Sty().smallText.copyWith(
                            color: Color(0xff7a7a7a),
                          ),),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text('₹500',
                          style: Sty().smallText.copyWith(
                              color: Clr().textcolor
                          ),),
                      ),
                    ],
                  ),
                  SizedBox(height: Dim().d4,),
                  Divider(),
                  Text('Cancelation Reason:',
                    style: Sty().mediumText.copyWith(
                        color: Clr().primaryColor
                    ),),
                  SizedBox(height: Dim().d8,),
                  Text('Expected a shorter wait time',
                    style: Sty().smallText.copyWith(
                        color: Clr().textcolor
                    ),),
                  SizedBox(height: Dim().d20,)
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }


  _enterOTPDialog(ctx) {
    AwesomeDialog(
      isDense: true,
      context: ctx,
      dialogType: DialogType.NO_HEADER,
      animType: AnimType.BOTTOMSLIDE,
      alignment: Alignment.centerLeft,
      body: Container(
        child: Column(
          children: [
            Text(
              'Enter OTP',
              style: Sty().mediumText.copyWith(
                color: Clr().textcolor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: Dim().d8,
            ),
            Text(
              'OTP has been sent to Customer.enter the OTP to start ride.',
              textAlign: TextAlign.center,
              style: Sty().mediumText.copyWith(
                color: Clr().textGrey,
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
            SizedBox(
              height: Dim().d20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d12),
              child: PinCodeTextField(
                // controller: otpCtrl,
                // errorAnimationController: errorController,
                appContext: context,
                enableActiveFill: true,
                textStyle: Sty().largeText,
                length: 4,
                obscureText: false,
                keyboardType: TextInputType.number,
                // inputFormatters: <TextInputFormatter>[
                //   FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                // ],
                animationType: AnimationType.scale,
                cursorColor: Clr().primaryColor,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.circle,
                  // borderRadius: BorderRadius.circular(50),
                  fieldWidth: Dim().d52,
                  fieldHeight: Dim().d52,
                  selectedFillColor: Clr().white,
                  activeFillColor: Clr().white,
                  inactiveFillColor: Clr().grey,
                  borderWidth: 0.2,
                  inactiveColor: Clr().grey,
                  activeColor: Clr().textcolor,
                  selectedColor: Clr().textcolor,
                ),
                animationDuration: const Duration(milliseconds: 200),
                onChanged: (value) {
                  _pinCode = value;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty || !RegExp(r'(.{4,})').hasMatch(value)) {
                    return "";
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(
              height: Dim().d24,
            ),
            SizedBox(
              height: 50,
              width: 250,
              child: ElevatedButton(
                  onPressed: () {
                    // if (formKey.currentState!.validate()) {
                    //   STM().checkInternet(context, widget).then((value) {
                    //     if (value) {
                    //       // sendOtp();
                    STM().redirect2page(ctx, LoadingSession());
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
                    'Start Rides',
                    style: Sty().mediumText.copyWith(
                      fontSize: 16,
                      color: Clr().white,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ),
            SizedBox(
              height: Dim().d28 ,
            ),
          ],
        ),
      ),
    ).show();
  }
}
