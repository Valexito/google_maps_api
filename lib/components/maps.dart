import 'package:flutter/material.dart';
import 'package:google_maps_api/components/directions_module.dart';
import 'package:google_maps_api/components/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

//COORDENADAS
class _MapScreenState extends State<MapScreen> {
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(14.834999, -91.518669),
    zoom: 13,
  );

  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  //INFO BETWEEN ABOVE VARIABLES (? CAN BE NULL)
  Directions? _info;

  //Cleaning memory out
  @override
  void dispose() {
    _googleMapController.dispose();
    super.dispose();
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Google Maps'),
        actions: [
          TextButton(
            onPressed:
                _origin == null
                    ? null
                    : () => _googleMapController.animateCamera(
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
            onPressed:
                _destination == null
                    ? null
                    : () => _googleMapController.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _destination!.position,
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
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _googleMapController = controller;
            },
            markers: {
              if (_origin != null) _origin!,
              if (_destination != null) _destination!,
            },

            //GOogle Maps Wiedet and polyline parameter
            polylines: {
              if (_info != null)
                Polyline(
                  polylineId: const PolylineId('overview_polyline'),
                  color: Colors.red,
                  width: 5,
                  points:
                      _info!.polylinePoints
                          .map((e) => LatLng(e.latitude, e.longitude))
                          .toList(),
                ),
            },

            onLongPress: _addMarker,
          ),
          if (_info != null)
            Positioned(
              top: 20.0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 12.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 2),
                      blurRadius: 6.0,
                    ),
                  ],
                ),

                child: Text(
                  '${_info!.totalDistance}, ${_info!.totalDuration}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),

      //floating button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        onPressed:
            //shows default location if a destination is not set
            () => _googleMapController.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info!.bounds, 100)
                  : CameraUpdate.newCameraPosition(_initialCameraPosition),
            ),
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  Future<void> _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
        _destination = null;
        _info = null;
      });
    } else {
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
      });

      final directions = await DirectionsRepository().getDirections(
        origin: _origin!.position,
        destination: pos,
      );

      setState(() {
        _info = directions;
      });
    }
  }
}
