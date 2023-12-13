import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oneclick_driver/my_rides.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class RideComplete extends StatefulWidget {
  @override
  State<RideComplete> createState() => _RideCompleteState();
}

class _RideCompleteState extends State<RideComplete> {
  late BuildContext ctx;

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
          "Ride Complete",
          style: Sty().largeText.copyWith(fontSize: 20, color: Clr().textcolor),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(ctx).size.height,
        child: Column(
          children: [
            Container(
                height: 245,
                width: MediaQuery.of(ctx).size.width,
                decoration: BoxDecoration(color: Color(0xffFFF3F3)),
                child: Center(child: SvgPicture.asset("assets/ride_complete.svg"))),
            SizedBox(
              height: Dim().d32,
            ),

            Text(
              'Bil Details',
              style: Sty().mediumText.copyWith(
                  fontSize: 20,
                  color: Clr().textcolor, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: Dim().d16,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dim().d16),
              child: Container(
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
                  child: Padding(
                    padding: EdgeInsets.all(Dim().d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Distance Traveled',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('0 - km',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                          ],
                        ),
                        SizedBox(height: Dim().d12,),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Load-Time',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('00m : 00s',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                          ],
                        ),
                        SizedBox(height: Dim().d12,),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Unload Time',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('00m : 00s',
                                style: Sty().smallText.copyWith(
                                  color: Clr().textGrey,
                                ),),
                            ),
                          ],
                        ),
                        SizedBox(height: Dim().d12,),
                        Divider(),
                        SizedBox(height: Dim().d4,),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text('Total Fare',
                                style: Sty().mediumText.copyWith(
                                  color: Clr().primaryColor,
                                    fontWeight: FontWeight.w600
                                ),),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text('1000.00',
                                style: Sty().smallText.copyWith(
                                  color: Clr().primaryColor,fontWeight: FontWeight.w600
                                ),),

                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Dim().d32,),
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
                      'Upload Document',
                      style: Sty().mediumText.copyWith(
                        fontSize: 16,
                        color: Clr().white,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
              ),
            ),

            SizedBox(height: Dim().d20,),
            Text('Skip',
              style: Sty().mediumText.copyWith(
                  color: Clr().primaryColor,
                  fontWeight: FontWeight.w400
              ),),
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
