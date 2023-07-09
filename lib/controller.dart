// import 'dart:math';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class HomePageController extends GetxController {
//   final Location location = Location();
//   final Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
//   GoogleMapController? mapController;
//   final Map<MarkerId, Marker> markers = {};
//
//   @override
//   void onInit() {
//     super.onInit();
//     _getCurrentLocation();
//     _retrieveMarkersFromFirestore();
//   }
//   void onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }
//
//   Future<void> _getCurrentLocation() async {
//     try {
//       final LocationData locationData = await location.getLocation();
//       currentLocation.value =
//           LatLng(locationData.latitude!, locationData.longitude!);
//     } catch (error) {
//       print(error);
//     }
//   }
//
//   void _retrieveMarkersFromFirestore() async {
//     // Assuming you have a collection called "locations" in Firestore
//     final QuerySnapshot snapshot =
//     await FirebaseFirestore.instance.collection('excel').get();
//
//     // Loop through the documents and create a marker for each location
//     snapshot.docs.forEach((DocumentSnapshot document) {
//       final LatLng latLng = LatLng(
//         document['lat'] as double,
//         document['lng'] as double,
//       );
//       final MarkerId markerId = MarkerId(document.id);
//
//       // Create a MarkerOptions object to customize the appearance of the marker
//       final Marker marker = Marker(
//         markerId: markerId,
//         position: latLng,
//         icon: BitmapDescriptor.defaultMarkerWithHue(
//           BitmapDescriptor.hueBlue,
//         ),
//         infoWindow: InfoWindow(title: document['title'] as String),
//       );
//       markers[markerId] = marker;
//     });
//
//     // Calculate and set the distances for each marker
//     final LatLng currentLatLng = currentLocation.value!;
//     markers.forEach((MarkerId markerId, Marker marker) {
//       final double distance = calculateDistance(currentLatLng, marker.position);
//       markers[markerId] = marker.copyWith(infoWindowParam: InfoWindow(
//         title: marker.infoWindow.title,
//         snippet: 'Distance: ${distance.toStringAsFixed(2)} km',
//       ));
//     });
//
//     // Sort the markers by distance
//     markers.entries.toList()
//       ..sort((MapEntry<MarkerId, Marker> a, MapEntry<MarkerId, Marker> b) {
//         final double distanceA =
//         calculateDistance(currentLatLng, a.value.position);
//         final double distanceB =
//         calculateDistance(currentLatLng, b.value.position);
//         return distanceA.compareTo(distanceB);
//       });
//   }
//   double calculateDistance(LatLng latLng1, LatLng latLng2) {
//     const int earthRadius = 6371;
//     double lat1 = _toRadians(latLng1.latitude);
//     double lon1 = _toRadians(latLng1.longitude);
//     double lat2 = _toRadians(latLng2.latitude);
//     double lon2 = _toRadians(latLng2.longitude);
//     double dLat = lat2 - lat1;
//     double dLon = lon2 - lon1;
//
//     double a = pow(sin(dLat / 2), 2) +
//         cos(lat1) * cos(lat2) * pow(sin(dLon / 2), 2);
//     double c = 2 * asin(sqrt(a));
//     double distanceInMeters = earthRadius * c * 1000;
//
//     return distanceInMeters;
//   }
//
//   double _toRadians(double degree) {
//     return degree * pi / 180;
//   }
//
//   void addMarkersToMap(List<DocumentSnapshot> documents) {
//     documents.forEach((document) {
//       Map<String, dynamic>? data = document.data() as Map<String, dynamic>?;
//       if (data != null && data["lat"] is GeoPoint) {
//         GeoPoint geoPoint = data["lng"] as GeoPoint;
//         LatLng latLng = LatLng(geoPoint.latitude, geoPoint.longitude);
//         Marker marker = Marker(
//           markerId: MarkerId(document.id),
//           position: latLng,
//           infoWindow: InfoWindow(title: data["name"] as String),
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueViolet,
//           ),
//         );
//         markers[marker.markerId] = marker;
//       }
//     });
//     update();
//   }
//
// }


