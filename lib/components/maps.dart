import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(14.834999, -91.518669),// Latitud y longitud corregidas
    zoom: 13,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;

  @override void dispose (){
    _googleMapController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text ('Google Maps'),
        actions: [
          TextButton(
            onPressed: _origin == null 
            ? null       
            : ()=>_googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _origin!.position,
                  zoom: 15,
                  tilt: 50.0,
                  ),
              ),
            ), 
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('ORIGIN'),
            ),
          
           TextButton(
            onPressed: _destination == null 
            ? null       
            : ()=>_googleMapController.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                  target: _origin!.position,
                  zoom: 15,
                  tilt: 50.0,
                  ),
              ),
            ), 
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('DEST'),
            ),
        ],
      ),
      body: GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (controller) {
          _googleMapController = controller;
        },
        markers: {
          if(_origin != null) _origin!,
          if(_destination != null) _destination!,
        },
        onLongPress: _addMarker,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed: () => _googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(_initialCameraPosition),
        ),
          child: const Icon(Icons.center_focus_strong),
        ),
    );
  }

  void _addMarker(LatLng pos){
    if (_origin == null || (_origin != null && _destination != null)){
      //origin is not set or Origin/Destination are both set
      //set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
          );

          //reset destination
          _destination: null;
      });
    }else{
      //origin is already set
      //Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      });
    }

  }
}