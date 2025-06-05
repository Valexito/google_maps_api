import 'package:dio/dio.dart';
import 'package:google_maps_api/components/directions_module.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '.env.dart';

class DirectionsRepository {
  static const String _baseURL =
      'https://maps.googleapis.com/maps/api/directions/json';

  final Dio _dio;

  DirectionsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _dio.get(
      _baseURL,
      queryParameters: {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'key': googleAPIKey,
      },
    );

    //AFTER THE HTTP CALL (RETURNS STATUS CODE)
    //(error handling?)
    if (response.statusCode == 200) {
      try {
        print('Respuesta completa de la API: ${response.data}');
        return Directions.fromMap(response.data);
      } catch (e) {
        print('Failed to parse directions: $e');
        return null;
      }
    }
    return null;
  }
}
