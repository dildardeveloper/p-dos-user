import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../layouts/botomsheet.dart';
import 'constant.dart';
import 'package:location/location.dart';
import 'namesearch.dart';

class MapPicker extends StatefulWidget {
  final latLng;
  MapPicker({required this.latLng});
  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _getMarkersFromFirestore();
  }

  LocationData? _currentLocation;

  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permission;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }

    _currentLocation = await location.getLocation();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentLocation == null
              ? Center(
                  child: CircularProgressIndicator(
                    color: appColor,
                  ),
                )
              : GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      _currentLocation?.latitude ?? 0.0,
                      _currentLocation?.longitude ?? 0.0,
                    ),
                    zoom: 10,
                  ),
                  markers: _markers,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    Marker? targetMarker = _markers.firstWhere(
                      (marker) =>
                          marker.position.latitude == widget.latLng.latitude &&
                          marker.position.longitude == widget.latLng.longitude,
                    );
                    _controller!.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: targetMarker.position,
                          zoom: 15,
                        ),
                      ),
                    );
                  },
                ),
          Positioned(
            left: 0,
            right: 12,
            top: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 100,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(NameSearch());
                    },
                    child: Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "Search by name, category or address",
                        style: textFieldStyle,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: appColor,
                    shape: BoxShape.circle,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(
                        NameSearch(),
                      );
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _getMarkersFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    firestore.collection('excel').snapshots().listen(
          (snapshot) {
        snapshot.docs.forEach(
              (doc) async {
            // Check if the document has any data before processing it
            if (doc.exists && doc.data() != null) {
              Map<String, dynamic> data = doc.data();
              // Extract the latitude and longitude values from the document
              String? latlngStr = data['Longitud/Latitud '] ?? data["Convicted yes/no"];
              List<String> latlngList = latlngStr?.split(',') ?? [];
              if (latlngList.length == 2) {
                double? lat = double.tryParse(latlngList[0].trim());
                double? lng = double.tryParse(latlngList[1].trim());
                if (lat != null && lng != null) {
                  LatLng latLng = LatLng(lat, lng);
                  print('object  $latLng');
                  final imageConfiguration =
                  ImageConfiguration(size: Size(30, 30));
                  try {
                    BitmapDescriptor markerIcon =
                    await BitmapDescriptor.fromAssetImage(
                      imageConfiguration,
                      'assets/images/Vector.png',
                    );
                    Marker marker = Marker(
                      markerId: MarkerId(doc.id),
                      position: latLng,
                      icon: markerIcon,
                      onTap: () {
                        String? latlngHttp = data['Longitud/Latitud '];
                        RegExp exp = RegExp(r'(https?:\/\/[^\s]+)');
                        String? http;
                        if (latlngHttp != null) {
                          Iterable<RegExpMatch> matches =
                          exp.allMatches(latlngHttp);
                          http = matches
                              .map((match) => match.group(0))
                              .firstWhere(
                                  (link) => link!.contains('https'),
                              orElse: () => null);
                        }
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 380,
                              child: LayoutBottomSheet(

                                name: data['Name'] ??
                                    data["name"] ??
                                    data["Name (våldtäkt mot barn)"] ??
                                    '',
                                category: data['Category'] ??
                                    data["category"] ??
                                    data["Conviction "] ??
                                    '',
                                address: data['Address']?.toString() ??
                                    data["address"] ??
                                    data['Adress'] ??
                                    '',
                                phone:
                                data['Personnummer: (NY) ']?.toString() ??
                                    data["Personnummer: (NY) "] ??
                                    '',
                                  http:http,
                              ),
                            );
                          },
                        );
                      },
                      infoWindow: InfoWindow(
                        title: data['Name'] ?? data["name"] ?? '',
                        snippet: '', // empty snippet for now
                      ),
                    );
                    setState(() {
                      _markers.add(marker);
                    });
                  } catch (e) {
                    print('Error loading marker icon: $e');
                  }
                }
              }
            }
          },
        );
      },
    );
  }
  // void _getMarkersFromFirestore() async {
  //   FirebaseFirestore firestore = FirebaseFirestore.instance;
  //   firestore.collection('excel').snapshots().listen(
  //     (snapshot) {
  //       snapshot.docs.forEach(
  //         (doc) async {
  //           // Check if the document has any data before processing it
  //           if (doc.exists && doc.data() != null) {
  //             Map<String, dynamic> data = doc.data();
  //             // Extract the latitude and longitude values from the document
  //             String? latlngStr = data['Longitud/Latitud '];
  //             if (latlngStr != null &&
  //                 !latlngStr.contains('?') &&
  //                 !latlngStr.contains('http')) {
  //               List<String> latlngList = latlngStr.split(',');
  //               if (latlngList.length == 2) {
  //                 double? lat = double.tryParse(latlngList[0].trim());
  //                 double? lng = double.tryParse(latlngList[1].trim());
  //                 if (lat != null && lng != null) {
  //                   LatLng latLng = LatLng(lat, lng);
  //                   print('object  $latLng');
  //                   final imageConfiguration =
  //                       ImageConfiguration(size: Size(30, 30));
  //                   try {
  //                     BitmapDescriptor markerIcon =
  //                         await BitmapDescriptor.fromAssetImage(
  //                       imageConfiguration,
  //                       'assets/images/Vector.png',
  //                     );
  //                     Marker marker = Marker(
  //                       markerId: MarkerId(doc.id),
  //                       position: latLng,
  //                       icon: markerIcon,
  //                       onTap: () {
  //                         String? latlngStr = data['Longitud/Latitud '];
  //                         showModalBottomSheet(
  //                           context: context,
  //                           builder: (BuildContext context) {
  //                             return Container(
  //                               height: 400,
  //                               child: LayoutBottomSheet(
  //                                 name: data['Name'] ??
  //                                     data["name"] ??
  //                                     data["Name (våldtäkt mot barn)"] ??
  //                                     '',
  //                                 category: data['Category'] ??
  //                                     data["category"] ??
  //                                     data["Conviction "] ??
  //                                     '',
  //                                 address: data['Address']?.toString() ??
  //                                     data["address"] ??
  //                                     data['Adress'] ??
  //                                     '',
  //                                 phone:
  //                                     data['Personnummer: (NY) ']?.toString() ??
  //                                         data["Personnummer: (NY) "] ??
  //                                         '',
  //                                 link: latlngStr?.contains('http') ?? false ? data['Longitud/Latitud '] : "",
  //                                 // link: latlngStr == latlngStr?.contains('http')
  //                                 //     ? data['Longitud/Latitud ']
  //                                 //     : "",
  //                               ),
  //                             );
  //                           },
  //                         );
  //                       },
  //                       infoWindow: InfoWindow(
  //                         title: data['Name'] ?? data["name"] ?? '',
  //                         snippet: '', // empty snippet for now
  //                       ),
  //                     );
  //                     setState(() {
  //                       _markers.add(marker);
  //                     });
  //                   } catch (e) {
  //                     print('Error loading marker icon: $e');
  //                   }
  //                 }
  //               }
  //             }
  //           }
  //         },
  //       );
  //     },
  //   );
  // }
}

// void _getMarkersFromFirestore() async {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   firestore.collection('excel').snapshots().listen((snapshot) {
//     snapshot.docs.forEach((doc) async {
//       Map<String, dynamic> data = doc.data();
//       double? lat = data.containsKey('Longitud/Latitud ')
//           ? double.tryParse(data['Longitud/Latitud '].toString())
//           : double.tryParse(data['lat'].toString()) ?? 0.0;
//       double? lng = data.containsKey('Longitud/Latitud ')
//           ? double.tryParse(data['Longitud/Latitud '].toString())
//           : double.tryParse(data['lng'].toString()) ?? 0.0;
//       LatLng latLng = LatLng(lat!, lng!);
//       print("object   $lat");
//       print(" hello   $lng");
//       print('object  $latLng');
//       final imageConfiguration = ImageConfiguration(size: Size(30, 30));
//       BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
//         imageConfiguration,
//         'assets/images/Vector.png',
//       );
//
//       Marker marker = Marker(
//         markerId: MarkerId(doc.id),
//         position: latLng,
//         icon: markerIcon,
//         onTap: () {
//           print("Latitude/Longitude $latLng");
//           showModalBottomSheet(
//             context: context,
//             builder: (BuildContext context) {
//               return Container(
//                 height: 350,
//                 child: LayoutBottomSheet(
//                   name: data['Name'] ?? data["name"] ?? '',
//                   category: data['Category'] ?? data["category"] ?? '',
//                   address:
//                       data['Address']?.toString() ?? data["address"] ?? '',
//                 ),
//               );
//             },
//           );
//         },
//         infoWindow: InfoWindow(
//           title: data['Name'] ?? data["name"] ?? '',
//           snippet: '', // empty snippet for now
//         ),
//       );
//
//       setState(() {
//         _markers.add(marker);
//       });
//     });
//   });
// }

// void _getMarkersFromFirestore() async {
//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   firestore.collection('excel').snapshots().listen((snapshot) {
//     snapshot.docs.forEach((doc) async {
//       Map<String, dynamic> data = doc.data();
//       double lat = double.tryParse(data.containsKey('Latitude') ? data['Latitude'] : data['lat'] ?? '0.0') ?? 0.0;
//       double lng = double.tryParse(data.containsKey('Longitude') ? data['Longitude'] : data['lng'] ?? '0.0') ?? 0.0;
//       LatLng latLng = LatLng(lat, lng);
//       print("object   $lat");
//       print(" hello   $lng");
//       print('object  $latLng');
//       final imageConfiguration = ImageConfiguration(size: Size(30, 30));
//       BitmapDescriptor markerIcon = await BitmapDescriptor.fromAssetImage(
//         imageConfiguration,
//         'assets/images/Vector.png',
//       );
//
//       Marker marker = Marker(
//         markerId: MarkerId(doc.id),
//         position: latLng,
//         icon: markerIcon,
//         onTap: () {
//           print("Latitude/Longitude $latLng");
//           showModalBottomSheet(
//             context: context,
//             builder: (BuildContext context) {
//               return Container(
//                 height: 350,
//                 child: LayoutBottomSheet(
//                   name: data['Name'] ?? data["name"] ?? '',
//                   category: data['Category'] ?? data["category"] ?? '',
//                   address:
//                   data['Address']?.toString() ?? data["address"] ?? '',
//                 ),
//               );
//             },
//           );
//         },
//         infoWindow: InfoWindow(
//           title: data['Name'] ?? data["name"] ?? '',
//           snippet: '', // empty snippet for now
//         ),
//       );
//
//       setState(() {
//         _markers.add(marker);
//       });
//     });
//   });
// }

// _calculateDistance();

// void _getCurrentLocation() async {
//   try {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = position;
//     });
//   } catch (e) {
//     print(e);
//   }
// }

// List<Marker> _markers = [];

// ...

// void _calculateDistance() {
//   LatLng currentLatLng = LatLng(
//     _currentPosition!.latitude,
//     _currentPosition!.longitude,
//   );
//   _markers.forEach((marker) {
//     LatLng markerLatLng = marker.position;
//     double distance = _distanceBetween(currentLatLng, markerLatLng);
//     String snippet = '${distance.round()} meters away';
//     Marker updatedMarker =
//         marker.copyWith(infoWindowParam: InfoWindow(snippet: snippet));
//     setState(() {
//       _markers.remove(marker);
//       _markers.add(updatedMarker);
//     });
//   });
// }

// Helper function to calculate distance between two coordinates
//   double _distanceBetween(LatLng coord1, LatLng coord2) {
//     double lat1 = _toRadians(coord1.latitude);
//     double lon1 = _toRadians(coord1.longitude);
//     double lat2 = _toRadians(coord2.latitude);
//     double lon2 = _toRadians(coord2.longitude);
//
//     double deltaLat = lat2 - lat1;
//     double deltaLon = lon2 - lon1;
//
//     double a = math.pow(math.sin(deltaLat / 2), 2) +
//         math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(deltaLon / 2), 2);
//
//     num c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
//
//     double earthRadius = 6371000; // in meters
//
//     return earthRadius * c;
//   }

// Helper function to convert degrees to radians
//   double _toRadians(double degrees) {
//     return degrees * math.pi / 180;
//   }

// void _getCurrentLocation() async {
//   try {
//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     setState(() {
//       _currentPosition = position;
//     });
//   } catch (e) {
//     print(e);
//   }
// }

// List<Marker> _markers = [];
