import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:narin_0/models/supply_node.dart';

class ApiService {
  static const String baseUrl = 'https://script.google.com/macros/s/AKfycbwbXe8uaiPSeSXN_jwx2nW_c8yKkGpRwEd2_3mWQdQ7LQm61YG8_00LCt4pmqyZuc1gXg/exec';
  // <-- сюда вставь твой URL
  //                                https://script.google.com/macros/s/AKfycbwCMNCksW7OXW6nlqu00V553srEK7Vh3ZL0j9XQnV5jkY2HFLN-P7sSCL7gpnamHq61dQ/exec
  // https://script.google.com/macros/s/AKfycbwG5bJTPBkK_olVXfu5RSbH3XDhWzH_e13gVRkEGqmFZdU4lPtifO8CwCokgctWhR-RKA/exec
  static Future<void> addSupplyNode(SupplyNode node) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(node.toJson()),
    );
  }

  static Future<List<SupplyNode>> fetchSupplyNodes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) {
        return SupplyNode(
          name: json['name'],
          location: LatLng(
            double.tryParse(json['lat'].toString()) ?? 0,
            double.tryParse(json['lng'].toString()) ?? 0,
          ),
          type: json['type'],
          isEthical: json['isEthical'].toString().toLowerCase() == 'true',
          certifications: (json['certifications'] as String).split(',').map((e) => e.trim()).toList(),
          nextSteps: (json['nextSteps'] as String).split(',').map((e) => e.trim()).toList(),
        );
      }).toList();
    } else {
      throw Exception('Ошибка при загрузке данных');
    }
  }
}
