import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:oneclick_driver/ride_started.dart';
import 'package:oneclick_driver/values/strings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'destination.dart';
import 'home.dart';
import 'manage/static_method.dart';
import 'loading_session.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class MyRides extends StatefulWidget {
  final initialindex;

  const MyRides({super.key, this.initialindex});

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
  List<dynamic> upcomingList = [];
  List<dynamic> ongingList = [];
  List<dynamic> cancelledList = [];
  List<dynamic> cancelreasonList = [];
  var selectedCancelReason;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        print('usertoken : ${usertoken}');
        getrides();
        cancelReason();
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

    return WillPopScope(
      onWillPop: () async {
        STM().finishAffinity(ctx, Home());
        return false;
      },
      child: DefaultTabController(
        length: 4,
        initialIndex: widget.initialindex ?? 0,
        child: Scaffold(
            bottomNavigationBar: bottomBarLayout(ctx, 2),
            backgroundColor: Clr().white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Clr().white,
              leadingWidth: 52,
              leading: InkWell(
                  onTap: () {
                    STM().finishAffinity(ctx, Home());
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
                upcomingList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d20, vertical: Dim().d100),
                        child: Text(
                          'Currently, no upcoming rides are scheduled.',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : listLayout(upcomingList),
                ongingList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d20, vertical: Dim().d100),
                        child: Text(
                          'Currently, there are no ongoing rides at the moment.',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : listLayout(ongingList),
                completeList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d20, vertical: Dim().d100),
                        child: Text(
                          'Currently, there are no completed rides.',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : listLayout(completeList),
                cancelledList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d20, vertical: Dim().d100),
                        child: Text(
                          'Currently, there are no cancelled rides.',
                          style: Sty().mediumBoldText,
                        ),
                      )
                    : listLayout(cancelledList),
              ],
            )),
      ),
    );
  }

  Widget listLayout(list) {
    return ListView.separated(
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(top: Dim().d12),
              child: cardLayout(
                context,
                index,
                list,
              ));
        },
        separatorBuilder: (context, index) {
          return SizedBox(height: Dim().d12);
        },
        itemCount: list.length,
        padding: EdgeInsets.symmetric(horizontal: Dim().d12));
  }

  /// Upcoming request Layout
  Widget cardLayout(ctx, index, list) {
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
                  Text(
                    'Trip ID : ${list[index]['trip_id']}',
                    style: Sty().microText.copyWith(color: Clr().grey2),
                  ),
                  Text(
                    '${DateFormat('dd/MM/yyyy | h:mm a').format(DateTime.parse(list[index]['updated_at'].toString()))}',
                    style: Sty().microText.copyWith(color: Color(0xff939393)),
                  ),
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
                    '${list[index]['city'].toString()}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Sty().microText.copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  ListView.builder(
                    itemCount: list[index]['receiver_address'].length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index2) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            '${list[index]['receiver_address'][index2]['city']} ${list[index]['receiver_address'][index2]['pincode']}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: Sty()
                                .microText
                                .copyWith(color: Color(0xff7a7a7a)),
                          ),
                          SizedBox(
                            height: Dim().d8,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Goods type',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${list[index]['goods_type'].toString().replaceAll('[', '').replaceAll(']', '').replaceAll('"', '').replaceAll('"', '')}',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date & Time',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${list[index]['date']}|${list[index]['time']}',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  if(list[index]['status_text'] == 'Completed')
                    Padding(
                      padding:  EdgeInsets.only(bottom: Dim().d12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Company Charge',
                              style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${list[index]['company_charge']}',
                              style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if(list[index]['status_text'] == 'Completed')
                    Padding(
                      padding:  EdgeInsets.only(bottom: Dim().d12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Total Distance',
                              style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${list[index]['total_distance']}km',
                              style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if(list[index]['status_text'] == 'Completed')
                    Padding(
                      padding:  EdgeInsets.only(bottom: Dim().d12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Driver Payble Amount',
                              style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '₹${list[index]['driver_payble_amount']}',
                              style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Est. Fare',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${list[index]['total_charge']}',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  if (list[index]['status_text'] != 'Cancelled')
                    list[index]['status_text'] == 'Completed'
                        ? Container()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              Text(
                                'Pick up contact :',
                                style: Sty().mediumText.copyWith(
                                      color: Color(0xff7a7a7a),
                                    ),
                              ),
                              SizedBox(
                                height: Dim().d8,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${list[index]['pickup_name']}',
                                    style: Sty()
                                        .mediumText
                                        .copyWith(color: Clr().primaryColor),
                                  ),
                                  Wrap(
                                    children: [
                                      SizedBox(
                                        height: 35,
                                        width: 90,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              STM().openDialer(
                                                  '${list[index]['pickup_mobile']}');
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Color(0xff07CB55),
                                                elevation: 0.5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
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
                                                  style:
                                                      Sty().mediumText.copyWith(
                                                            fontSize: 14,
                                                            color: Clr().white,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                ),
                                              ],
                                            )),
                                      ),
                                      SizedBox(
                                        width: Dim().d8,
                                      ),
                                      SizedBox(
                                        height: 35,
                                        width: 50,
                                        child: ElevatedButton(
                                            onPressed: () {
                                              MapsLauncher.launchCoordinates(
                                                  double.parse(list[index]
                                                          ['latitude']
                                                      .toString()),
                                                  double.parse(list[index]
                                                          ['longitude']
                                                      .toString()));
                                            },
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Clr().white,
                                                elevation: 0.5,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    color: Color(0xff7a7a7a)
                                                        .withOpacity(0.5),
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                )),
                                            child: SvgPicture.asset(
                                                'assets/pin.svg')),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  if (list[index]['status_text'] == 'Completed')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Complete',
                            style: Sty()
                                .mediumBoldText
                                .copyWith(color: Clr().green),
                            textAlign: TextAlign.right),
                      ],
                    ),
                  if (list[index]['status_text'] == 'Ongoing')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text(
                          'Receiver contact :',
                          style: Sty().mediumText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                        SizedBox(
                          height: Dim().d8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${list[index]['receiver_name']}',
                              style: Sty()
                                  .mediumText
                                  .copyWith(color: Clr().primaryColor),
                            ),
                            Wrap(
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 90,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        STM().openDialer(
                                            '${list[index]['receiver_mobile']}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xff07CB55),
                                          elevation: 0.5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(50),
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
                                SizedBox(
                                  width: Dim().d8,
                                ),
                                // SizedBox(
                                //   height: 35,
                                //   width: 50,
                                //   child: ElevatedButton(
                                //       onPressed: () {
                                //         MapsLauncher.launchCoordinates(
                                //             double.parse(
                                //                 list[index]['receiver_address']['latitude'].toString()),
                                //             double.parse(
                                //                 list[index]['receiver_address']['longitude'].toString()));
                                //       },
                                //       style: ElevatedButton.styleFrom(
                                //           backgroundColor: Clr().white,
                                //           elevation: 0.5,
                                //           shape: RoundedRectangleBorder(
                                //             side: BorderSide(
                                //               color:
                                //               Color(0xff7a7a7a).withOpacity(0.5),
                                //             ),
                                //             borderRadius: BorderRadius.circular(50),
                                //           )),
                                //       child: SvgPicture.asset('assets/pin.svg')),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  if (list[index]['status_text'] == 'Upcoming')
                    SizedBox(
                      height: Dim().d12,
                    ),
                  if (list[index]['status_text'] == 'Upcoming')
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton(
                                onPressed: () {
                                  _cancelDailog(ctx, list[index]['id']);
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
                                  _enterOTPDialog(ctx, list[index]['id']);
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
                  if (list[index]['status_text'] == 'Ongoing') Divider(),
                  if (list[index]['status_text'] == 'Ongoing')
                    list[index]['sub_status'] == '1' ||
                            list[index]['sub_status'] == '2' ||
                            list[index]['sub_status'] == '3'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    list[index]['sub_status'] == '1'
                                        ? STM().redirect2page(
                                            ctx,
                                            LoadingSession(
                                              times: list[index]['updated_at'],
                                              type: 'view',
                                              id: list[index]['id'],
                                            ))
                                        : list[index]['sub_status'] == '2'
                                            ? STM().redirect2page(
                                                ctx,
                                                RideStarted(
                                                  type: 'view',
                                                  times: list[index]
                                                      ['updated_at'],
                                                  id: list[index]['id'],
                                                ))
                                            : STM().redirect2page(
                                                ctx,
                                                Destination(
                                                  type: 'view',
                                                  times: list[index]
                                                      ['updated_at'],
                                                  id: list[index]['id'],
                                                ));
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Clr().primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(Dim().d20)),
                                      )),
                                  child: Center(
                                    child: Text(
                                        list[index]['sub_status'] == '1'
                                            ? 'View Loading Status'
                                            : list[index]['sub_status'] == '2'
                                                ? 'View Ride Status'
                                                : 'View Unloading Status',
                                        style: Sty()
                                            .mediumText
                                            .copyWith(color: Clr().white)),
                                  )),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    startLoad(list[index]['id'],
                                        list[index]['updated_at']);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Clr().primaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(Dim().d20)),
                                      )),
                                  child: Center(
                                    child: Text('Start Loading',
                                        style: Sty()
                                            .mediumText
                                            .copyWith(color: Clr().white)),
                                  )),
                            ],
                          ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  if (list[index]['status_text'] == 'Cancelled')
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(),
                        Text(
                          'Cancellation Reason:',
                          style: Sty()
                              .mediumText
                              .copyWith(color: Clr().primaryColor),
                        ),
                        SizedBox(
                          height: Dim().d8,
                        ),
                        Text(
                          '${list[index]['canellation_reason']}',
                          style: Sty().smallText.copyWith(color: Clr().red),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: Dim().d20,
                  )
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
                  Text(
                    'Trip ID : 2135563',
                    style: Sty().microText.copyWith(color: Clr().grey2),
                  ),
                  Text(
                    '14/10/2023 | 12:30Pm',
                    style: Sty().microText.copyWith(color: Color(0xff939393)),
                  ),
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
                    style: Sty().microText.copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
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
                    style: Sty().microText.copyWith(color: Color(0xff7a7a7a)),
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Goods type',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Building / Construction',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Date & Time',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Dec 18, 2023|12:30Pm',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Est. Fare',
                          style: Sty().smallText.copyWith(
                                color: Color(0xff7a7a7a),
                              ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹500',
                          style:
                              Sty().smallText.copyWith(color: Clr().textcolor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: Dim().d4,
                  ),
                  Divider(),
                  Text(
                    'Cancelation Reason:',
                    style: Sty().mediumText.copyWith(color: Clr().primaryColor),
                  ),
                  SizedBox(
                    height: Dim().d8,
                  ),
                  Text(
                    'Expected a shorter wait time',
                    style: Sty().smallText.copyWith(color: Clr().textcolor),
                  ),
                  SizedBox(
                    height: Dim().d20,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _enterOTPDialog(ctx, id) {
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
                    startRide(id, _pinCode);
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
              height: Dim().d28,
            ),
          ],
        ),
      ),
    ).show();
  }

  _cancelDailog(ctx, id) {
    return AwesomeDialog(
        context: ctx,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        body: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Cancellation Reason',
                        style: Sty().mediumText.copyWith(
                            color: Clr().textcolor,
                            fontSize: Dim().d20,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                SizedBox(height: Dim().d20),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: cancelreasonList.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: Dim().d12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: Dim().d8,
                              ),
                              InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectedCancelReason =
                                          cancelreasonList[index]['reason'];
                                    });
                                  },
                                  child: selectedCancelReason ==
                                          cancelreasonList[index]['reason']
                                      ? Icon(Icons.circle, size: Dim().d16)
                                      : Icon(Icons.circle_outlined,
                                          size: Dim().d16)),
                              SizedBox(
                                width: Dim().d12,
                              ),
                              Text('${cancelreasonList[index]['reason']}',
                                  style: Sty().mediumText),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: Dim().d12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Clr().primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(Dim().d20)))),
                        onPressed: () {
                          cancelRide(id, selectedCancelReason);
                        },
                        child: Center(
                          child: Text('Submit',
                              style: Sty().mediumText.copyWith(
                                  color: Clr().white,
                                  fontWeight: FontWeight.w500)),
                        )),
                  ],
                )
              ],
            );
          },
        )).show();
  }

  void getrides() async {
    var result = await STM().getWithoutDialog(ctx, 'get_ride', usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        upcomingList = result['data']['upcoming'];
        ongingList = result['data']['ongoing'];
        completeList = result['data']['completed'];
        cancelledList = result['data']['cancelled'];
      });
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }

  void cancelReason() async {
    var result = await STM().getWithoutDialog(ctx, 'cancel_reasons', usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        cancelreasonList = result['data'];
      });
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }

  void cancelRide(id, reason) async {
    FormData body = FormData.fromMap({
      'request_id': id,
      'reason': reason,
    });
    var result = await STM()
        .postWithToken(ctx, Str().cancelling, 'cancel_ride', body, usertoken);
    var success = result['success'];
    if (success) {
      STM().replacePage(ctx, MyRides(initialindex: 3));
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }

  void startRide(id, otp) async {
    FormData body = FormData.fromMap({
      'request_id': id,
      'otp': otp,
    });
    var result = await STM()
        .postWithToken(ctx, Str().cancelling, 'start_ride', body, usertoken);
    var success = result['success'];
    if (success) {
      STM().replacePage(ctx, MyRides(initialindex: 1));
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }

  void startLoad(id, time) async {
    FormData body = FormData.fromMap({
      'request_id': id,
    });
    var result = await STM()
        .postWithToken(ctx, Str().cancelling, 'load_session', body, usertoken);
    var success = result['success'];
    if (success) {
      STM().displayToast(result['message']);
      STM().redirect2page(
          ctx,
          LoadingSession(
            id: id,
          ));
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }
}
