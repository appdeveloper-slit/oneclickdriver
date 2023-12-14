import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneclick_driver/home.dart';
import 'package:oneclick_driver/values/dimens.dart';
import 'package:oneclick_driver/vehicle_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'imageview.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/strings.dart';
import 'values/styles.dart';

class UploadDocuments extends StatefulWidget {
  final type, vehicleDetails;

  const UploadDocuments({super.key, this.type, this.vehicleDetails});

  @override
  State<UploadDocuments> createState() => _UploadDocumentsState();
}

class _UploadDocumentsState extends State<UploadDocuments> {
  late BuildContext ctx;

  final _formKey = GlobalKey<FormState>();
  File? imageFile, profilefile;
  var profile;
  String? sAadhar,
      sAdhaarError,
      sAdharFile,
      sBackAadhar,
      sAdhaarBackError,
      sAdhaarBackFile,
      sPan,
      sPanError,
      sPanFile;
  TextEditingController panNumCtrl = TextEditingController();
  TextEditingController aadharCtrl = TextEditingController();
  String? usertoken;
  var kycDetails;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      usertoken = sp.getString('token') ?? '';
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        print('usertoken : ${usertoken}');
        // getCategaory();
        widget.type == 'home' ? redoKycApi() : null;
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
        widget.type == 'home'
            ? STM().finishAffinity(ctx, Home())
            : SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Clr().white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Clr().white,
          leadingWidth: 52,
          centerTitle: true,
          title: RichText(
            text: TextSpan(
              text: "Upload ",
              style: Sty().smallText.copyWith(
                  fontSize: 20,
                  fontFamily: "MulshiBold",
                  fontWeight: FontWeight.w500,
                  color: Clr().secondary),
              children: <TextSpan>[
                TextSpan(
                  text: 'Documents',
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
          leading: InkWell(
              onTap: () {
                widget.type == 'home'
                    ? STM().finishAffinity(ctx, Home())
                    : SystemNavigator.pop();
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
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Dim().d16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: aadharCtrl,
                  cursorColor: Clr().textcolor,
                  style: Sty().mediumText,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: Sty().textFieldOutlineStyle.copyWith(
                        hintStyle: Sty().smallText.copyWith(
                              color: Clr().textGrey,
                            ),
                        filled: true,
                        fillColor: Clr().grey,
                        hintText: "Enter Aadhaar  Number",
                        counterText: "",
                      ),
                  maxLength: 12,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return Str().invalidEmpty;
                    } else {
                      return null;
                    }
                  },
                ),
                SizedBox(
                  height: Dim().d16,
                ),
                InkWell(
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
                                sAadhar != null
                                    ? 'Image selected'
                                    : 'Upload Aadhaar  front Photo',
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
                if (sAdhaarError != null) SizedBox(height: Dim().d4),
                if (sAdhaarError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sAdhaarError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d4,
                ),
                imageLayout(
                    fileimage: sAdharFile,
                    urlimage: kycDetails == null
                        ? null
                        : kycDetails['driver_document']
                        ['aadhar_front_photo']),
                SizedBox(
                  height: Dim().d16,
                ),
                InkWell(
                  onTap: () {
                    showCardBottomSheet(context, 'backAadhar',
                        'Upload Aadhaar Card Back Photo');
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
                                sBackAadhar != null
                                    ? 'Image selected'
                                    : 'Upload Aadhaar  back photo',
                                // 'Upload Aadhaar  back photo',
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
                if (sAdhaarBackError != null) SizedBox(height: Dim().d4),
                if (sAdhaarBackError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sAdhaarBackError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(height: Dim().d4),
                imageLayout(
                    fileimage: sAdhaarBackFile,
                    urlimage: kycDetails == null
                        ? null
                        : kycDetails['driver_document']
                        ['aadhar_back_photo']),
                SizedBox(
                  height: Dim().d16,
                ),
                TextFormField(
                  controller: panNumCtrl,
                  cursorColor: Clr().textcolor,
                  style: Sty().mediumText,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: Sty().textFieldOutlineStyle.copyWith(
                        hintStyle: Sty().smallText.copyWith(
                              color: Clr().textGrey,
                            ),
                        filled: true,
                        fillColor: Clr().grey,
                        hintText: "Enter Pan card number ",
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
                  height: Dim().d16,
                ),
                InkWell(
                  onTap: () {
                    showCardBottomSheet(
                        context, 'pan', 'Upload Pan Card Photo');
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
                                sPan != null
                                    ? 'Image selected'
                                    : 'Upload Pan card photo',
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
                if (sPanError != null) SizedBox(height: Dim().d4),
                if (sPanError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sPanError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(height: Dim().d4),
                imageLayout(
                    fileimage: sPanFile,
                    urlimage: kycDetails == null
                        ? null
                        : kycDetails['driver_document']['pan_photo']),
                SizedBox(
                  height: Dim().d32,
                ),
                Center(
                  child: SizedBox(
                    height: 50,
                    width: 285,
                    child: ElevatedButton(
                        onPressed: () {
                          widget.type == 'home'
                              ? STM()
                                  .checkInternet(context, widget)
                                  .then((value) {
                                  if (value) {
                                    _formKey.currentState!.validate() ? updateProject() : null;
                                  }
                                })
                              : _formKey.currentState!.validate()
                                  ? validate()
                                  : null;
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
              ],
            ),
          ),
        ),
      ),
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
        switch (type) {
          case "aadhar":
            sAdharFile = pickedFile.path.toString();
            sAadhar = base64Encode(image);
            break;
          case "backAadhar":
            sAdhaarBackFile = pickedFile.path.toString();
            sBackAadhar = base64Encode(image);
            break;
          case "pan":
            sPanFile = pickedFile.path.toString();
            sPan = base64Encode(image);
            break;
        }
        ;
      });
    }
  }

  validate() {
    if (sAadhar == null) {
      setState(() {
        sAdhaarError = 'Aadhaar front photo is required';
      });
    } else if (sBackAadhar == null) {
      setState(() {
        sAdhaarBackError = 'Aadhaar back photo is required';
      });
    } else if (sPan == null) {
      setState(() {
        sPanError = 'Pan card photo is required';
      });
    } else {
      STM().checkInternet(context, widget).then((value) {
        if (value) {
          updateProject();
        }
      });
    }
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

  void updateProject() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //Input
    FormData body = FormData.fromMap({
      'aadhar_number': aadharCtrl.text,
      'aadhar_front_photo': sAadhar,
      'aadhar_back_photo': sBackAadhar,
      'pan_number': panNumCtrl.text,
      'pan_photo': sPan,
    });
    //Output
    var result = await STM().postWithToken(
        ctx, Str().uploading, "upload_document", body, usertoken);
    var message = result['message'];
    var success = result['success'];
    if (success) {
      if (widget.type == 'home') {
        widget.vehicleDetails
            ? STM().redirect2page(
                ctx,
                VehicleDetails(
                  type: 'home',
                ))
            : STM().successDialogWithAffinity(ctx, message, Home());
      } else {
        setState(() {
          sp.setBool('kyc', true);
        });
        STM().redirect2page(ctx, VehicleDetails());
        STM().displayToast(message);
      }
    } else {
      var message = result['message'];
      STM().errorDialog(ctx, message);
    }
  }

  Widget imageLayout({fileimage, urlimage}) {
    return fileimage == null
        ? urlimage == null ? Container() : InkWell(
            onTap: () {
              STM().redirect2page(
                  ctx,
                  Imageview(
                    urlimage: urlimage,
                  ));
            },
            child: SizedBox(
              height: Dim().d120,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(Dim().d12)),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: urlimage,
                  placeholder: (context, url) => STM().loadingPlaceHolder(),
                ),
              ),
            ),
          )
        : InkWell(
            onTap: () {
              STM().redirect2page(ctx, Imageview(fileimage: fileimage));
            },
            child: SizedBox(
              height: Dim().d120,
              width: double.infinity,
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(Dim().d12)),
                  child: Image.file(
                    File(fileimage),
                    fit: BoxFit.cover,
                  )),
            ),
          );
  }

  void redoKycApi() async {
    var result = await STM().getWithoutDialog(ctx, 'redo_kyc', usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        kycDetails = result['data'];
        aadharCtrl = TextEditingController(
            text:
                result['data']['driver_document']['aadhar_number'].toString());
        panNumCtrl = TextEditingController(
            text: result['data']['driver_document']['pan_number'].toString());
      });
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }
}
