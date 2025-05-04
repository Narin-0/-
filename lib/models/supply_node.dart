import 'package:latlong2/latlong.dart';

class SupplyNode {
  final String name;
  final LatLng location;
  final String type;
  final bool isEthical;
  final List<String> certifications;
  final List<String> nextSteps;

  SupplyNode({
    required this.name,
    required this.location,
    required this.type,
    required this.isEthical,
    required this.certifications,
    required this.nextSteps,
  });

  // Если нужно, можно добавить метод toJson
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': location.latitude,
      'lng': location.longitude,
      'type': type,
      'isEthical': isEthical,
      'certifications': certifications,
      'nextSteps': nextSteps,
    };
  }
}
