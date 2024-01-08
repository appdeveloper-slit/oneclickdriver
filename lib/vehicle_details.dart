import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:oneclick_driver/values/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';
import 'imageview.dart';
import 'manage/static_method.dart';
import 'values/dimens.dart';
import 'values/strings.dart';
import 'values/styles.dart';

class VehicleDetails extends StatefulWidget {
  final type;

  const VehicleDetails({super.key, this.type});

  @override
  State<VehicleDetails> createState() => _VehicleDetailsState();
}

class _VehicleDetailsState extends State<VehicleDetails> {
  late BuildContext ctx;
  final _formKey = GlobalKey<FormState>();
  File? imageFile, profilefile;
  var profile;
  var sVehiclePhotoFile,
      sVehiclePhotoError,
      sLicensePhotoFile,
      sLicensePhotoError,
      sRcPhotoFile,
      sRcPhotoError,
      sCanChequePhotoFile,
      sCanChequePhotoError,
      sVehicleTypeError,
      vehicleDetails;

  String? sLicense, sVehicle, sRC, sCheque;
  List<dynamic> vehicleTypeList = [];
  TextEditingController bankNameCtrl = TextEditingController();
  TextEditingController accNumCtrl = TextEditingController();
  TextEditingController ifscCtrl = TextEditingController();
  TextEditingController accNameCtrl = TextEditingController();
  TextEditingController licenseCtrl = TextEditingController();
  TextEditingController vehicleNoCtrl = TextEditingController();
  TextEditingController rcNoCtrl = TextEditingController();
  String? usertoken;
  var vehicleType;

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      usertoken = sp.getString('token') ?? '';
    });
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        redoKycApi();
        getVehicleType();
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
                DropdownButtonFormField<dynamic>(
                  value: vehicleType,
                  decoration: Sty().textFieldOutlineStyle.copyWith(
                        hintText: 'Select Vehicle Type',
                        hintStyle:
                            Sty().mediumText.copyWith(color: Clr().hintColor),
                        filled: true,
                        fillColor: Clr().grey,
                      ),
                  items: vehicleTypeList.map((e) {
                    return DropdownMenuItem<dynamic>(
                        value: e['id'].toString(),
                        child: Text(e['name'], style: Sty().mediumText));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      vehicleType = value.toString();
                    });
                  },
                ),
                if (sVehicleTypeError != null) SizedBox(height: Dim().d4),
                if (sVehicleTypeError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sVehicleTypeError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d16,
                ),
                TextFormField(
                  controller: vehicleNoCtrl,
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
                        hintText: "Vehicle Number",
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
                      context,
                      'vehicle',
                      'Upload Vehicle Photo',
                    );
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
                                sVehicle != null
                                    ? 'Image selected'
                                    : 'Upload Vehicle Photo',
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
                if (sVehiclePhotoError != null) SizedBox(height: Dim().d4),
                if (sVehiclePhotoError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sVehiclePhotoError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d4,
                ),
                if(vehicleDetails != null)
                imageLayout(
                    fileimage: sVehiclePhotoFile,
                    urlimage: vehicleDetails['vehicle_detail'] == null
                        ? null
                        : vehicleDetails['vehicle_detail']['vehicle_photo']),
                SizedBox(
                  height: Dim().d16,
                ),
                TextFormField(
                  controller: licenseCtrl,
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
                        hintText: "License Number",
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
                      context,
                      'license',
                      'Upload License Photo',
                    );
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
                                sLicense != null
                                    ? 'Image selected'
                                    : 'Upload License Photo',
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
                if (sLicensePhotoError != null) SizedBox(height: Dim().d4),
                if (sLicensePhotoError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sLicensePhotoError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d4,
                ),
                if(vehicleDetails != null)
                imageLayout(
                    fileimage: sLicensePhotoFile,
                    urlimage: vehicleDetails['vehicle_detail'] == null
                        ? null
                        : vehicleDetails['vehicle_detail']['license_photo']),
                SizedBox(
                  height: Dim().d16,
                ),
                TextFormField(
                  controller: rcNoCtrl,
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
                        hintText: "RC Number",
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
                    showCardBottomSheet(context, 'rc', 'Upload RC Photo');
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
                                sRC != null
                                    ? 'Image selected'
                                    : 'Upload RC Photo',
                                // 'Upload RC Photo',
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
                if (sRcPhotoError != null) SizedBox(height: Dim().d4),
                if (sRcPhotoError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sRcPhotoError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d4,
                ),
                if(vehicleDetails != null)
                imageLayout(
                    fileimage: sRcPhotoFile,
                    urlimage: vehicleDetails['vehicle_detail'] == null
                        ? null
                        : vehicleDetails['vehicle_detail']['rc_photo']),
                SizedBox(
                  height: Dim().d32,
                ),
                RichText(
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
                SizedBox(
                  height: Dim().d20,
                ),
                TextFormField(
                  controller: bankNameCtrl,
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
                        hintText: "Bank Name",
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
                TextFormField(
                  controller: accNumCtrl,
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
                        hintText: "Account Number",
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
                TextFormField(
                  controller: ifscCtrl,
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
                        hintText: "IFSC Code",
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
                TextFormField(
                  controller: accNameCtrl,
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
                        hintText: "Account Holder Name",
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
                        context, 'cheque', 'Upload Cancelled Cheque');
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
                                sCheque != null
                                    ? 'Image selected'
                                    : 'Upload Cancelled Cheque',
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
                if (sCanChequePhotoError != null) SizedBox(height: Dim().d4),
                if (sCanChequePhotoError != null)
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: Dim().d20),
                      child: Text('$sCanChequePhotoError',
                          style:
                              Sty().smallText.copyWith(color: Clr().errorRed))),
                SizedBox(
                  height: Dim().d4,
                ),
                if(vehicleDetails != null)
                imageLayout(
                    fileimage: sCanChequePhotoFile,
                    urlimage: vehicleDetails['vehicle_detail'] == null
                        ? null
                        : vehicleDetails['vehicle_detail']['cheque_photo']),
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
                              :
                            _formKey.currentState!.validate() ? validate() : null;
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
                  height: Dim().d32,
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
          case "vehicle":
            sVehiclePhotoFile = pickedFile.path.toString();
            sVehicle = base64Encode(image);
            break;
          case "license":
            sLicensePhotoFile = pickedFile.path.toString();
            sLicense = base64Encode(image);
            break;
          case "rc":
            sRcPhotoFile = pickedFile.path.toString();
            sRC = base64Encode(image);
            break;
          case "cheque":
            sCanChequePhotoFile = pickedFile.path.toString();
            sCheque = base64Encode(image);
            break;
        }
        ;
      });
    }
  }

  Widget imageLayout({fileimage, urlimage}) {
    return fileimage == null
        ? urlimage == null
            ? Container()
            : InkWell(
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

  validate() {
    if (sVehicle == null) {
      setState(() {
        sVehiclePhotoError = 'Vehicle photo is required';
      });
    } else if (sLicense == null) {
      setState(() {
        sLicensePhotoError = 'License photo is required';
      });
    } else if (sRC == null) {
      setState(() {
        sRcPhotoError = 'Rc photo is required';
      });
    } else if (sCheque == null) {
      setState(() {
        sCanChequePhotoError = 'Cancel Cheque photo is required';
      });
    } else if (vehicleType == null) {
      setState(() {
        sVehicleTypeError = 'Vehicle type is required';
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

  void getVehicleType() async {
    var result =
        await STM().getWithoutDialog(ctx, 'get_vehicle_type', usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        vehicleTypeList = result['data'];
      });
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }

  void updateProject() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    //Input
    FormData body = FormData.fromMap({
      'vehicle_type': vehicleType,
      'vehicle_number': vehicleNoCtrl.text,
      'vehicle_photo': sVehicle,
      'license_number': licenseCtrl.text,
      'license_photo': sLicense,
      'rc_number': rcNoCtrl.text,
      'rc_photo': sRC,
      'bank_name': bankNameCtrl.text,
      'account_number': accNumCtrl.text,
      'ifsc_code': ifscCtrl.text,
      'account_holder_name': accNameCtrl.text,
      'cheque_photo': sCheque,
    });
    //Output
    var result = await STM().postWithToken(
        ctx, Str().uploading, "add_vehicle_details", body, usertoken);
    // if (!mounted) return;
    var message = result['message'];
    var success = result['success'];
    if (success) {
      setState(() {
        setState(() {
          sp.setBool('is_login', true);
        });
      });
      STM().finishAffinity(ctx, Home());
      STM().displayToast(message);
    } else {
      var message = result['message'];
      STM().errorDialog(ctx, message);
    }
  }

  void redoKycApi() async {
    var result = await STM().getWithoutDialog(ctx, 'redo_kyc', usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        vehicleDetails = result['data'];
        if(vehicleDetails != null){
          vehicleType = vehicleDetails['vehicle_detail']['vehicle_id'].toString();
          vehicleNoCtrl = TextEditingController(
              text:
              vehicleDetails['vehicle_detail']['vehicle_number'].toString());
          licenseCtrl = TextEditingController(
              text:
              vehicleDetails['vehicle_detail']['license_number'].toString());
          rcNoCtrl = TextEditingController(
              text: vehicleDetails['vehicle_detail']['rc_number'].toString());
          bankNameCtrl = TextEditingController(
              text: vehicleDetails['vehicle_detail']['bank_name'].toString());
          accNumCtrl = TextEditingController(
              text:
              vehicleDetails['vehicle_detail']['account_number'].toString());
          accNameCtrl = TextEditingController(
              text: vehicleDetails['vehicle_detail']['account_holder_name']
                  .toString());
          ifscCtrl = TextEditingController(
              text: vehicleDetails['vehicle_detail']['ifsc_code'].toString());
        }
      });
    } else {
      STM().errorDialog(ctx, result['message']);
    }
  }
}
