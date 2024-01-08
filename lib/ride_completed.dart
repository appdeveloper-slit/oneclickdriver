import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneclick_driver/my_rides.dart';
import 'bottom_navigation/bottom_navigation.dart';
import 'home.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/strings.dart';
import 'values/styles.dart';

class RideComplete extends StatefulWidget {
  final id,detail;
  const RideComplete({super.key, this.id,this.detail});

  @override
  State<RideComplete> createState() => _RideCompleteState();
}

class _RideCompleteState extends State<RideComplete> {
  late BuildContext ctx;
  File? imageFile;
  var sdocument;

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return WillPopScope(
      onWillPop: () async {
        STM().replacePage(
            ctx,
            MyRides(
              initialindex: 2,
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
                STM().replacePage(ctx, MyRides(initialindex: 2));
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
            style:
                Sty().largeText.copyWith(fontSize: 20, color: Clr().textcolor),
          ),
          centerTitle: true,
        ),
        body: Container(
          height: MediaQuery.of(ctx).size.height,
          child: Column(
            children: [
              STM().imageView({'url': "assets/ride_complete.svg",'height': Dim().d240,'width': double.infinity}),
              SizedBox(
                height: Dim().d32,
              ),
              Text(
                'Bil Details',
                style: Sty().mediumText.copyWith(
                    fontSize: 20,
                    color: Clr().textcolor,
                    fontWeight: FontWeight.w600),
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
                                child: Text(
                                  'Distance Traveled',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${widget.detail['total_distance']}km',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dim().d12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Load-Time',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${widget.detail['loading_time']}',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dim().d12,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Unload Time',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${widget.detail['unloading_time']}',
                                  style: Sty().smallText.copyWith(
                                        color: Clr().textGrey,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dim().d12,
                          ),
                          Divider(),
                          SizedBox(
                            height: Dim().d4,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Total Fare',
                                  style: Sty().mediumText.copyWith(
                                      color: Clr().primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '₹${widget.detail['total_charge']}',
                                  style: Sty().smallText.copyWith(
                                      color: Clr().primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: Dim().d12,
              ),
              Padding(
                padding:  EdgeInsets.symmetric(horizontal: Dim().d12),
                child: InkWell(
                  onTap: () {
                    showCardBottomSheet(
                        context, 'aadhar', 'Upload Aadhaar Card Front Photo');
                  },
                  child: DottedBorder(
                    color: Clr().primaryColor,
                    borderType: BorderType.RRect,
                    radius: Radius.circular(55),
                    //color of dotted/dash line
                    strokeWidth: 1,
                    //thickness of dash/dots
                    dashPattern: [6, 4],

                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                sdocument != null
                                    ? 'Image selected'
                                    : 'Upload Document Photo',
                                style: Sty()
                                    .smallText
                                    .copyWith(color: Clr().primaryColor),
                              ),
                              SvgPicture.asset("assets/upload.svg"),
                            ],
                          ),
                        )),
                  ),
                ),
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
                        if(sdocument != null){
                          completeride(widget.id);
                        }else{
                          STM().errorDialog(ctx, 'Please upload a document');
                        }
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
              SizedBox(
                height: Dim().d20,
              ),
              InkWell(
                onTap: () {
                  STM().replacePage(
                      ctx,
                      MyRides(
                        initialindex: 2,
                      ));
                },
                child: Text(
                  'Skip',
                  style: Sty().mediumText.copyWith(
                      color: Clr().primaryColor, fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showCardBottomSheet(BuildContext context, type, name) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Clr().background1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dim().d14),
          topRight: Radius.circular(Dim().d14),
        ),
      ),
      builder: (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dim().d12,
                vertical: Dim().d20,
              ),
              child: Text(
                name,
                // 'Upload Aadhar Card Back',
                style: Sty().mediumBoldText,
              ),
            ),
            SizedBox(height: Dim().d28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera(ImageSource.camera, type);
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Clr().primaryColor,
                    size: Dim().d32,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _getFromCamera(ImageSource.gallery, type);
                  },
                  child: Icon(
                    Icons.yard_outlined,
                    size: Dim().d32,
                    color: Clr().primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: Dim().d40),
          ],
        );
      },
    );
  }

  _getFromCamera(ImageSource source, type) async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
        STM().back2Previous(ctx);
        var image = imageFile!.readAsBytesSync();
        sdocument = base64Encode(image);
      });
    }
  }

  void completeride(id) async {
    FormData body = FormData.fromMap({
      'request_id': id,
      'ride_document': sdocument,
    });
    var result = await STM().postWithToken(ctx, Str().processing, 'upload_ride_document', body, usertoken);
    var success = result['success'];
    if (success) {
      STM().displayToast(result['message']);
      STM().successDialogWithReplace(ctx, result['message'],MyRides(initialindex: 2,));
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }


}
