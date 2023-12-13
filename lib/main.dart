import 'package:flutter/material.dart';
import 'package:oneclick_driver/upload_documents.dart';
import 'package:oneclick_driver/vehicle_details.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // MediaQueryData windowData = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  // windowData = windowData.copyWith(textScaleFactor: 1.0,);                                                                                                                     nnnnnnnnnnn
  //Remove this method to stop OneSignal Debugging
  OneSignal.logout();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize('2af239b4-e6b3-448b-bf3a-783a4d88fd62');
  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
  OneSignal.Notifications.requestPermission(true);
  SharedPreferences sp = await SharedPreferences.getInstance();
  // bool isLogin =
  // sp.getBool('is_login') != null ? sp.getBool("is_login")! : false;
  bool isID = sp.getString('user_id') != null ? true : false;
  bool isLogin = sp.getBool('is_login') ?? false;
  bool typeRegis = sp.getBool('register') ?? false;
  bool kyc = sp.getBool('kyc') ?? false;
  bool vehicle = sp.getBool('vehicledetails') ?? false;

  ///Code for notifications
  // OneSignal.shared.setAppId('cae3483f-464a-4ef9-b9e1-a772c3968ba9');
  // GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // OneSignal.shared.setNotificationOpenedHandler((value) {
  //   navigatorKey.currentState!.push(
  //     MaterialPageRoute(
  //       builder: (context) => NotificationPage(),
  //     ),
  //   );
  // });
  ///End Code for notifications

  await Future.delayed(const Duration(seconds: 3));
  runApp(
    MaterialApp(
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      debugShowCheckedModeBanner: false,
      home: isLogin
          ? Home()
          : typeRegis
              ? kyc
                  ? VehicleDetails()
                  : UploadDocuments()
              : Login(),
    ),
  );
}
