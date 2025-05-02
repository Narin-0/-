import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/supply_node.dart';

class ApiService {
  static const String baseUrl = 'https://your-api.com';

  static Future<List<SupplyNode>> fetchSupplyNodes() async {
    final response = await http.get(Uri.parse('$baseUrl/nodes'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => SupplyNode(
        name: item['name'],
        location: LatLng(item['lat'], item['lng']),
        type: item['type'],
        isEthical: item['isEthical'],
        certifications: List<String>.from(item['certifications']),
        nextSteps: List<String>.from(item['nextSteps']),
      )).toList();
    } else {
      throw Exception('Не удалось загрузить данные с сервера');
    }
  }
}
