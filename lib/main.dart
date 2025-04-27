import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 293,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: LatLng(42.8746, 74.6126)/*Показывает всегда бишкек */,
                            initialZoom: 10.0,
                            minZoom: 2,
                            maxZoom: 18,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                              userAgentPackageName: 'com.example.app', // <-- ОБЯЗАТЕЛЬНО для Web и мобилок!
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ), // Блок Карты
                const SizedBox(height: 10,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8, // 50% от ширины экрана,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Поиск компании', // Подсказка внутри поля
                        prefixIcon: Icon(Icons.search), // <-- Иконка лупы слева
                        border: OutlineInputBorder( // Чтобы было красиво с рамкой и скруглением
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                )  // Блок поиска
              ],
            ),
          ),
        ),
      ),
    );
  }
}
