import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:oneclick_driver/bottom_navigation/bottom_navigation.dart';
import 'package:oneclick_driver/demo.dart';
import 'package:oneclick_driver/login.dart';
import 'package:oneclick_driver/my_profile.dart';
import 'package:oneclick_driver/upload_documents.dart';
import 'package:oneclick_driver/values/colors.dart';
import 'package:oneclick_driver/values/dimens.dart';
import 'package:oneclick_driver/vehicle_details.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timelines/timelines.dart';
import 'package:upgrader/upgrader.dart';
import 'manage/static_method.dart';
import 'map.dart';
import 'my_rides.dart';
import 'notification.dart';
import 'values/strings.dart';
import 'values/styles.dart';
import 'package:double_back_to_close/double_back_to_close.dart';

var curtLng, curtLat, usertoken, city;
final service = FlutterBackgroundService();
bool? checkRun;
Timer homeApiTimer = Timer(Duration(seconds: 1),() {

},);
Timer? locationApiTimer;

checkAppPermission() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  bool check = await Permission.location.isGranted;
  if (check) {
    Position? position = await Geolocator.getCurrentPosition();
    List<Placemark> list =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    city = list[0].subLocality ?? list[1].subLocality;
    FormData body = FormData.fromMap({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
    //Output
    await STM().postWithoutDialogMethod2(
        "update_location", body, sp.getString('token'));
    print('api run');
  } else {
    locationApiTimer!.cancel();
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'OneClickDriver', // id
    'One Click Driver Current Location Fetching', // title
    // description: 'Current Location: $city', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      // auto start service
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'OneClickDriver',
      initialNotificationTitle: 'One Click Driver',
      initialNotificationContent: 'Current Location Fetching',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,
      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,
      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  Timer.periodic(Duration(minutes: 1), (timer) async {
    checkAppPermission();
  });
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late BuildContext ctx;
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  // this will be used as notification channel id
  var notificationChannelId = 'my_foreground';

  locationApiTime() {
    locationApiTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      print('location timer start');
      checkAppPermission();
    });
  }

  homeApiTime() {
    homeApiTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      print('home timer start');
      getHomeApi();
    });
  }

// this will be used for notification id, So you can update your custom notification with this id.
  var notificationId = 888;
  int _currentState = 1;
  bool? loading;
  int selectedIndex = -1;

  var pageType,
      incomeData,
      ridesTodayData,
      leadsTodayData,
      pageUpdate,
      walletBalance;
  String? sValue;
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
  Upgrader _upgrader = Upgrader();

  getSession() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      usertoken = sp.getString('token');
    });
    if (usertoken == null) {
      setState(() {
        sp.clear();
        STM().errorDialogWithAffinity(
            ctx, 'Something went wrong!! Please Login', Login());
      });
    }
    STM().checkInternet(context, widget).then((value) {
      if (value) {
        print('usertoken : ${usertoken}');
        homeApiTime();
        getHomeApi();
      }
    });
    bool check = await Permission.location.isGranted;
    if (check) {
      Position? position = await Geolocator.getCurrentPosition();
      locationApiTime();
    } else {
      setState(() {
        locationApiTimer!.cancel();
      });
      locationDialog();
    }
  }

  @override
  void initState() {
    getSession();
    _upgrader.initialize();
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
                actions: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: Dim().d8, bottom: Dim().d8, right: Dim().d12),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dim().d52)),
                        color: Clr().primaryColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Dim().d12, vertical: Dim().d12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SvgPicture.asset('assets/wallet.svg'),
                            SizedBox(
                              width: Dim().d12,
                            ),
                            Text(
                                '₹ ${STM().formatAmount(int.parse(walletBalance == null ? '0' : walletBalance.toString()))}')
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
        drawer: pageType != null && pageType['status'] == 2 ? null : drawerLayout(),
        body: loading == true
            ? UpgradeAlert(
                upgrader: Upgrader(
                  canDismissDialog: false,
                  dialogStyle: UpgradeDialogStyle.material,
                  durationUntilAlertAgain: const Duration(minutes: 2),
                  showReleaseNotes: true,
                  onUpdate: () {
                    Future.delayed(Duration(seconds: 1), () {
                      SystemNavigator.pop();
                    });
                    return true;
                  },
                  showIgnore: pageUpdate ?? true,
                  showLater: pageUpdate ?? true,
                ),
                child: SingleChildScrollView(
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
        Container(
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
                      height: 36,
                      child: Text(
                        "Total Income",
                        overflow: TextOverflow.fade,
                      )),
                  Text(
                    STM().formatAmount(incomeData ?? 0),
                    style: Sty().smallText.copyWith(
                        color: Color(0xffFFE08F), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
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
                      height: 36,
                      child: Text(
                        "Rides (Today)",
                        overflow: TextOverflow.fade,
                      )),
                  Text(
                    STM().formatAmount(ridesTodayData ?? 0),
                    style: Sty().smallText.copyWith(
                        color: Color(0xff07CB55), fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
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
                      height: Dim().d36,
                      child: const Text(
                        "Leads (Today)",
                        overflow: TextOverflow.fade,
                      )),
                  Text(
                    STM().formatAmount(leadsTodayData ?? 0),
                    style: Sty().smallText.copyWith(
                        color: Color(0xff928FFF), fontWeight: FontWeight.w800),
                  ),
                ],
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
                                style: Sty()
                                    .mediumBoldText
                                    .copyWith(color: Clr().black)),
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

  CardLayout(v, index,list) {
    bool? twincon;
    int? minutes, seconds;
    final now = DateTime.now();
    final timeGet = DateTime.parse(v['created_at'].toString());
    final aftercurrentTime = timeGet.add(Duration(minutes: 10));
    if (now.isBefore(aftercurrentTime)) {
      minutes = int.parse(DateFormat('mm').format(aftercurrentTime)) -
          int.parse(DateFormat('mm').format(now));
      seconds = int.parse(DateFormat('ss').format(aftercurrentTime)) -
          int.parse(DateFormat('ss').format(now));
    }
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Clr().borderColor.withOpacity(1),
                  spreadRadius: 0.1,
                  blurRadius: 6,
                  offset: const Offset(
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
                Padding(
                  padding: EdgeInsets.only(left: Dim().d28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
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
                                  '${v['city']}',
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
                          v['user']['type'] == 'Cash'
                              ? SvgPicture.asset("assets/cash.svg")
                              : SvgPicture.asset("assets/billing.svg"),
                          SizedBox(
                            height: Dim().d12,
                          ),
                          InkWell(
                            onTap: () {
                              MapsLauncher.launchCoordinates(
                                  double.parse(v['longitude']),
                                  double.parse(v['latitude']));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(right: Dim().d8),
                              child: Text(
                                "View Map",
                                style: Sty().smallText.copyWith(
                                    height: 1.2,
                                    color: Clr().primaryColor,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Clr().primaryColor),
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: Dim().d12,
                ),
                Padding(
                  padding: EdgeInsets.only(left: Dim().d12, top: Dim().d8),
                  child: FixedTimeline.tileBuilder(
                    mainAxisSize: MainAxisSize.min,
                    verticalDirection: VerticalDirection.down,
                    theme: TimelineThemeData(
                      indicatorTheme:
                          IndicatorThemeData(size: Dim().d8, position: 0),
                      color: Clr().primaryColor,
                      connectorTheme: ConnectorThemeData(
                        color: Clr().primaryColor.withOpacity(0.4),
                        thickness: 2.0,
                        indent: 3.0,
                      ),
                      indicatorPosition: 0,
                      nodePosition: 0,
                    ),
                    builder: TimelineTileBuilder.connectedFromStyle(
                      connectorStyleBuilder: (context, index) {
                        return ConnectorStyle.dashedLine;
                      },
                      indicatorStyleBuilder: (context, index) {
                        return IndicatorStyle.dot;
                      },
                      contentsAlign: ContentsAlign.basic,
                      oppositeContentsBuilder: (context, index) =>
                          SizedBox.shrink(),
                      lastConnectorStyle: ConnectorStyle.transparent,
                      firstConnectorStyle: ConnectorStyle.transparent,
                      contentsBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                              left: Dim().d12, bottom: Dim().d12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          '${v['receiver_address'][index]['city']}',
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: Sty().smallText.copyWith(
                                              color: Clr().primaryColor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  MapsLauncher.launchCoordinates(
                                      double.parse(v['receiver_address'][index]
                                          ['latitude']),
                                      double.parse(v['receiver_address'][index]
                                          ['longitude']));
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        "View Map",
                                        style: Sty().smallText.copyWith(
                                            height: 1.2,
                                            color: Clr().primaryColor,
                                            fontWeight: FontWeight.w500,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                Clr().primaryColor),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: v['receiver_address'].length,
                    ),
                  ),
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
                                "${v['date']}",
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
                                "${v['time']}",
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
                                "₹0(Est.)",
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
                        "Goods Type",
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
                    '${v['goods_type']}',
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
                    child: twincon == true ? Container() :  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TweenAnimationBuilder<Duration>(
                            duration: Duration(minutes: minutes!, seconds: seconds!),
                            tween: Tween(
                                begin: Duration(minutes: minutes, seconds: seconds),
                                end: Duration.zero),
                            onEnd: () {
                              setState(() {
                                twincon = true;
                              });
                            },
                            builder: (BuildContext context, Duration value,
                                Widget? child) {
                              final minutes = value.inMinutes;
                              final seconds = value.inSeconds % 60;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Text(
                                  "0$minutes:$seconds",
                                  textAlign: TextAlign.center,
                                  style: Sty().smallText.copyWith(
                                      color: Clr().secondary,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: "MulshiSemi",
                                      fontSize: Dim().d28),
                                ),
                              );
                            }),
                        Wrap(
                          children: [
                            // InkWell(
                            //   onTap: () {
                            //     _cancelDialog(ctx);
                            //   },
                            //   child: Container(
                            //     height: 50,
                            //     width: 50,
                            //     decoration: BoxDecoration(
                            //         borderRadius: BorderRadius.circular(55),
                            //         color: Clr().white,
                            //         border: Border.all(
                            //           color: Clr().primaryColor,
                            //         )),
                            //     child: Padding(
                            //       padding: EdgeInsets.all(Dim().d12),
                            //       child: SvgPicture.asset("assets/cancel.svg"),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: Dim().d20,
                            // ),
                            InkWell(
                              onTap: () {
                                _rideConfirmedDialog(ctx,v['id']);
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
        if (requestList.isEmpty) emptyLeadsLayout(),
        if (requestList.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: requestList.length,
            itemBuilder: (context, index) {
              // var v = notificationList[index];
              return CardLayout(requestList[index], index,requestList);
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

  emptyLeadsLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: Dim().d12),
        SvgPicture.asset("assets/notound.svg"),
        SizedBox(height: Dim().d12),
        Text(
            "No leads to display as of now You will be notified when you will receive the leads",
            textAlign: TextAlign.center,
            style: Sty().mediumText.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: Dim().d20,
                )),
      ],
    );
  }

  _rideConfirmedDialog(ctx,id) {
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
                    text: '₹0',
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
                          acceptRide(id);
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
        await STM().postWithoutDialog(ctx, 'get_request', body, usertoken);
    var success = result['success'];
    if (success) {
      setState(() {
        loading = true;
        incomeData = result['data']['total_income'];
        ridesTodayData = result['data']['rides_today'];
        leadsTodayData = result['data']['leads_today'];
        requestList = result['data']['requests'];
        pageUpdate = result['data']['update'];
        walletBalance = result['data']['wallet_balance'];
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

  ///location dialog
  locationDialog() {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.noHeader,
        animType: AnimType.scale,
        width: double.infinity,
        dismissOnBackKeyPress: false,
        dismissOnTouchOutside: false,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: Dim().d12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/loc.png', fit: BoxFit.fitWidth),
              Text('Location permission is required',
                  style: Sty().mediumText.copyWith(
                      color: Clr().primaryColor,
                      fontSize: Dim().d16,
                      fontWeight: FontWeight.w700)),
              Text(
                  'To enhance your experience and provide accurate address information, please grant permission to enable location services on your device.',
                  textAlign: TextAlign.center,
                  style: Sty().mediumText.copyWith(
                      color: Clr().textcolor,
                      fontSize: Dim().d14,
                      fontWeight: FontWeight.w400)),
              SizedBox(height: Dim().d20),
              ElevatedButton(
                  onPressed: () async {
                    STM().back2Previous(ctx);
                    getCurrentLct();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Clr().primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dim().d16),
                      )),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: Dim().d12),
                    child: Center(
                      child: Text('Continue',
                          style: Sty().mediumText.copyWith(
                              color: Clr().white,
                              fontWeight: FontWeight.w500,
                              fontSize: Dim().d16)),
                    ),
                  )),
              SizedBox(height: Dim().d20),
            ],
          ),
        )).show();
  }

  /// currentLocation
  getCurrentLct() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    LocationPermission permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position? position = await Geolocator.getCurrentPosition();
      // await initializeService();
      locationApiTime();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        locationApiTimer!.cancel();
      });
      AwesomeDialog(
          context: ctx,
          width: double.infinity,
          dialogType: DialogType.noHeader,
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dim().d12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Kindly grant location permission through your device settings.',
                    style: Sty().mediumText.copyWith(
                        color: Clr().primaryColor,
                        fontWeight: FontWeight.w400)),
                SizedBox(
                  height: Dim().d12,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            await Geolocator.openAppSettings().then((value) {
                              setState(() {
                                sp.clear();
                                SystemNavigator.pop();
                              });
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Clr().primaryColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(Dim().d8),
                            child: Text(
                              'Go Settings',
                              style:
                                  Sty().smallText.copyWith(color: Clr().white),
                            ),
                          )),
                    ),
                    SizedBox(
                      width: Dim().d12,
                    ),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              sp.clear();
                              SystemNavigator.pop();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Clr().primaryColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(Dim().d8),
                            child: Text(
                              'Close App',
                              style:
                                  Sty().smallText.copyWith(color: Clr().white),
                            ),
                          )),
                    ),
                  ],
                )
              ],
            ),
          )).show();
    }
  }


  /// accept ride
 void acceptRide(id) async {
    FormData body = FormData.fromMap({
      'request_id': id,
    });
    var result = await STM().postWithoutDialog(ctx, 'accept_ride', body, usertoken);
    var success = result['success'];
    if(success){
      STM().successDialog(ctx, result['message'], MyRides(initialindex: 0));
    }else{
      STM().errorDialog(ctx, result['message']);
    }
 }

}
