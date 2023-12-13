import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oneclick_driver/bottom_navigation/bottom_navigation.dart';
import 'manage/static_method.dart';
import 'ride_started.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class LoadingSession extends StatefulWidget {
  @override
  State<LoadingSession> createState() => _LoadingSessionState();
}

class _LoadingSessionState extends State<LoadingSession> {
  late BuildContext ctx;

  // Set the initial time to 10 minutes
  int _timeInSeconds = 1;
  Timer? _timer;

  //Start timing
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeInSeconds > 0) {
          _timeInSeconds++;
        } else {
          _timer?.cancel();
          // You can add code here to handle timer completion, e.g., show a dialog.
        }
      });
    });
  }

  getSessionData() async {
    startTimer();
  }

  @override
  void initState() {
    getSessionData();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;

    return Scaffold(
      bottomNavigationBar: bottomBarLayout(ctx, 0, b: true),
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
          style: Sty().largeText.copyWith(fontSize: 20, color: Clr().textcolor),
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
                  color: Clr().textcolor, fontWeight: FontWeight.w600),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(color: Clr().yellow,borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child:   RichText(
                      text: TextSpan(
                        text: "${(_timeInSeconds ~/ 60).toString().padLeft(2, '0')}",
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
                  decoration: BoxDecoration(color: Clr().grey,borderRadius: BorderRadius.circular(10)),
                  child:Center(
                    child:   RichText(
                      text: TextSpan(
                        text: "${(_timeInSeconds % 60).toString().padLeft(2, '0')}",
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
            ),
            SizedBox(
              height: Dim().d40,
            ),
            Center(
              child: SizedBox(
                height: 50,
                width: 285,
                child: ElevatedButton(
                    onPressed: () {
                      // if (formKey.currentState!.validate()) {
                      //   STM().checkInternet(context, widget).then((value) {
                      //     if (value) {
                      //       // sendOtp();
                      STM().redirect2page(ctx, RideStarted());
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
}
