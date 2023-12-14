import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'manage/static_method.dart';
import 'values/colors.dart';
import 'values/dimens.dart';
import 'values/styles.dart';

class MapLocation extends StatefulWidget {
  final lat, lng, type;
  MapLocation({super.key, this.lat, this.lng, this.type});

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  late BuildContext ctx;
  final Set<Marker> _markers = {};
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();

  var Lat, Lng, address,selectAddress;
  List<Placemark> list = [];
  GoogleMapController? _controller;

  _handleTap(LatLng point) async {
    _markers.clear();
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(point.toString()),
        position: point,
        infoWindow: InfoWindow(title: address.toString()),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
  getSession() async {
    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('Marker'),
          position: LatLng(double.parse(widget.lat),double.parse(widget.lng)),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getSession();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Clr().white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(ctx).size.height,
              child: GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
                markers: _markers,
                onTap: _handleTap,
                indoorViewEnabled: true,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                mapType: MapType.hybrid, initialCameraPosition: CameraPosition(zoom: 10,target: LatLng(double.parse(widget.lat),double.parse(widget.lng))),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
