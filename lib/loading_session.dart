import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:oneclick_driver/bottom_navigation/bottom_navigation.dart';
import 'package:oneclick_driver/my_rides.dart';
import 'home.dart';
import 'manage/static_method.dart';
import 'ride_started.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/strings.dart';
import 'values/styles.dart';

class LoadingSession extends StatefulWidget {
  final times, type, id;

  const LoadingSession({super.key, this.times, this.type, this.id});

  @override
  State<LoadingSession> createState() => _LoadingSessionState();
}

class _LoadingSessionState extends State<LoadingSession> {
  late BuildContext ctx;
  Duration? diff;
  int minutes = 0;
  int seconds = 0;

  void getMinutes() {
    setState(() {
      final getDate = DateTime.parse(widget.times);
      final now = DateTime.now();
      diff = now.difference(getDate);
    });
  }

  @override
  void initState() {
    widget.type == 'view' ? getMinutes() : null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        STM().replacePage(
            ctx,
            const MyRides(
              initialindex: 1,
            ));
        return false;
      },
      child: Scaffold(
        bottomNavigationBar: bottomBarLayout(ctx, 0, b: true),
        backgroundColor: Clr().white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().white,
          leadingWidth: 52,
          leading: InkWell(
              onTap: () {
                STM().replacePage(ctx, const MyRides(initialindex: 1));
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    padding: EdgeInsets.all(10),
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        color: Clr().primaryColor, shape: BoxShape.circle),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: Clr().white,
                      size: 18,
                    )),
              )),
          title: Text(
            "Loading Session",
            style:
                Sty().largeText.copyWith(fontSize: 20, color: Clr().textcolor),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(ctx).size.height,
          child: Column(
            children: [
              SvgPicture.asset("assets/loading.svg"),
              SizedBox(
                height: Dim().d32,
              ),
              Text(
                'Loading Session',
                style: Sty().mediumText.copyWith(
                    fontSize: 20,
                    color: Clr().textcolor,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: Dim().d16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dim().d24,
                ),
                child: Text(
                  'Lorem Ipsum is simply dummy text of the printing and typesetting industry.',
                  textAlign: TextAlign.center,
                  style: Sty().smallText.copyWith(
                        color: Clr().textGrey,
                      ),
                ),
              ),
              SizedBox(
                height: Dim().d32,
              ),
              TweenAnimationBuilder<Duration>(
                  duration: const Duration(hours: 24),
                  tween: Tween(
                      begin: Duration(
                          minutes: widget.type == 'view' ? diff!.inMinutes : 0,
                          seconds:
                              widget.type == 'view' ? diff!.inSeconds % 60 : 0),
                      end: const Duration(hours: 24)),
                  onEnd: () {
                    setState(() {
                      STM().replacePage(ctx, MyRides(initialindex: 1));
                    });
                  },
                  builder:
                      (BuildContext context, Duration value, Widget? child) {
                    minutes = value.inMinutes;
                    seconds = value.inSeconds % 60;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                              color: Clr().yellow,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: "${minutes}",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Clr().white),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 'm',
                                    style: Sty().smallText.copyWith(
                                        color: Clr().white,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "MulshiSemi",
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Dim().d8),
                        Text(":",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Clr().textcolor)),
                        SizedBox(width: Dim().d8),
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                              color: Clr().grey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: RichText(
                              text: TextSpan(
                                text: "${seconds}",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: Clr().textcolor),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: 's',
                                    style: Sty().smallText.copyWith(
                                        color: Clr().textcolor,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "MulshiSemi",
                                        fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
              SizedBox(
                height: Dim().d40,
              ),
              Center(
                child: SizedBox(
                  height: 50,
                  width: 285,
                  child: ElevatedButton(
                      onPressed: () {
                        startLoad(widget.id, '$minutes:$seconds');
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Clr().primaryColor,
                          elevation: 0.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      child: Text(
                        'Proceed To Ride',
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
        ),
      ),
    );
  }

// _rideConfirmedDialog(ctx) {
//   AwesomeDialog(
//     isDense: false,
//     context: ctx,
//     dialogType: DialogType.NO_HEADER,
//     animType: AnimType.BOTTOMSLIDE,
//     alignment: Alignment.centerLeft,
//     body: Container(
//       padding: EdgeInsets.all(Dim().d12),
//       child: Column(
//         children: [
//           SvgPicture.asset("assets/ride_confirm.svg"),
//           SizedBox(height: Dim().d20,),
//           Text(
//             'Ride is Confirmed',
//             style: Sty().mediumText.copyWith(
//               color: Clr().textcolor,
//               fontWeight: FontWeight.w600,
//               fontSize: 20,
//             ),
//           ),
//           SizedBox(height: Dim().d8,),
//           Text(
//             'We have found a driver',
//             style: Sty().mediumText.copyWith(
//               color: Clr().textGrey,
//               fontWeight: FontWeight.w400,
//               fontSize: 16,
//             ),
//           ),
//           SizedBox(height: Dim().d24,),
//           Center(
//             child: SizedBox(
//               height: 50,
//               width: MediaQuery.of(ctx).size.width * 100,
//               child: ElevatedButton(
//                   onPressed: () {
//                     // if (formKey.currentState!.validate()) {
//                     //   STM().checkInternet(context, widget).then((value) {
//                     //     if (value) {
//                     //       // sendOtp();
//                     // STM().redirect2page(ctx, MyRequest());
//                     //     }
//                     //   });
//                     // }
//                     // ;
//
//                   },
//                   style: ElevatedButton.styleFrom(
//                       backgroundColor: Clr().primaryColor,
//                       elevation: 0.5,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50),
//                       )),
//                   child: Text(
//                     'See Details',
//                     style: Sty().mediumText.copyWith(
//                       fontSize: 16,
//                       color: Clr().white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   )),
//             ),
//           ),
//           SizedBox(height: Dim().d16,),
//         ],
//       ),
//     ),
//   ).show();
// }

  void startLoad(id, time) async {
    FormData body = FormData.fromMap({
      'request_id': id,
      'time': time,
    });
    var result = await STM().postWithToken(
        ctx, Str().processing, 'proceed_to_ride', body, usertoken);
    var success = result['success'];
    if (success) {
      STM().displayToast(result['message']);
      STM().replacePage(ctx, RideStarted(id: id,));
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }
}
