import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../models/intermediate_stop_model.dart';

class GoogleDirectionsService {
  static String get _apiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? "";
  }

  static double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if ((lat1 == 0.0 && lon1 == 0.0) || (lat2 == 0.0 && lon2 == 0.0)) {
      return 0.0;
    }
    const double p = 0.017453292519943295;
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) *
            cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p)) /
            2;
    final double km = 12742 * asin(sqrt(a.clamp(0.0, 1.0)));
    return km;
  }

  static double calculateSegmentDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2, {
    double fallbackKm = 2.5,
  }) {
    if ((lat1 == 0.0 && lon1 == 0.0) || (lat2 == 0.0 && lon2 == 0.0)) {
      return fallbackKm;
    }
    final straight = calculateHaversineDistance(lat1, lon1, lat2, lon2);
    if (straight <= 0.0) return fallbackKm;
    return double.parse((straight * 1.3).toStringAsFixed(1));
  }

  static double calculateRouteDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<IntermediateStopModel>? stops,
    double fallbackKm = 12.4,
  }) {
    if ((startLat == 0.0 && startLng == 0.0) ||
        (endLat == 0.0 && endLng == 0.0)) {
      return fallbackKm;
    }

    final points = <(double, double)>[(startLat, startLng)];
    if (stops != null && stops.isNotEmpty) {
      for (final s in stops) {
        if (s.latitude != 0.0 && s.longitude != 0.0) {
          points.add((s.latitude, s.longitude));
        }
      }
    }
    points.add((endLat, endLng));

    double totalDist = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDist += calculateHaversineDistance(
        points[i].$1,
        points[i].$2,
        points[i + 1].$1,
        points[i + 1].$2,
      );
    }

    if (totalDist <= 0.0) return fallbackKm;
    return double.parse((totalDist * 1.3).toStringAsFixed(1));
  }

  static Future<double> fetchRoadDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<IntermediateStopModel>? stops,
    double fallbackKm = 12.4,
  }) async {
    if ((startLat == 0.0 && startLng == 0.0) ||
        (endLat == 0.0 && endLng == 0.0)) {
      return fallbackKm;
    }

    final validStops = stops
            ?.where((s) => s.latitude != 0.0 && s.longitude != 0.0)
            .toList() ??
        [];

    final apiKey = _apiKey;
    if (apiKey.isNotEmpty) {
      try {
        String urlStr =
            'https://maps.googleapis.com/maps/api/directions/json?origin=$startLat,$startLng&destination=$endLat,$endLng&alternatives=true&key=$apiKey';
        if (validStops.isNotEmpty) {
          final waypointsStr = validStops
              .map((p) => '${p.latitude},${p.longitude}')
              .join('|');
          urlStr += '&waypoints=optimize:true|$waypointsStr';
        }

        final url = Uri.parse(urlStr);
        final response =
            await http.get(url).timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['status'] == 'OK' &&
              data['routes'] != null &&
              (data['routes'] as List).isNotEmpty) {
            final List routes = data['routes'];

            int minDistanceMeters = 1 << 30;

            for (final r in routes) {
              final legs = r['legs'] as List? ?? [];
              int routeDistanceMeters = 0;
              for (final leg in legs) {
                routeDistanceMeters +=
                    (leg['distance']?['value'] as int? ?? 0);
              }

              if (routeDistanceMeters > 0 &&
                  routeDistanceMeters < minDistanceMeters) {
                minDistanceMeters = routeDistanceMeters;
              }
            }

            if (minDistanceMeters > 0 && minDistanceMeters != (1 << 30)) {
              final double distanceKm = minDistanceMeters / 1000.0;
              return double.parse(distanceKm.toStringAsFixed(1));
            }
          }
        }
      } catch (e) {
        debugPrint('Notice fetching road distance via Google Directions: $e');
      }
    }

    return calculateRouteDistance(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      stops: stops,
      fallbackKm: fallbackKm,
    );
  }
}
