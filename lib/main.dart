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
      theme: ThemeData.light(), // светлая тема
      darkTheme: ThemeData.dark(), // тёмная тема
      themeMode: ThemeMode.system, // автоматически по системной теме
      home: const CompanyMapPage(),
    );
  }
}

class CompanyMapPage extends StatefulWidget {
  const CompanyMapPage({Key? key}) : super(key: key);

  @override
  _CompanyMapPageState createState() => _CompanyMapPageState();
}

class _CompanyMapPageState extends State<CompanyMapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Список компаний и их координаты
  final Map<String, LatLng> _companyLocations = {
    "Компания 1 (Бишкек)": LatLng(42.8746, 74.6126),
    "Компания 2 (Бишкек)": LatLng(42.8800, 74.6000),
    "Компания 3 (Ош)": LatLng(40.5283, 72.7985),
    "Компания 4 (Талас)": LatLng(42.5228, 72.2425),
    "Компания 5 (Талас)": LatLng(0, 0),
  };

  List<String> _filteredCompanies = [];
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _filteredCompanies = _companyLocations.keys.toList();
    _searchController.addListener(_filterCompanies);
  }

  void _filterCompanies() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCompanies = _companyLocations.keys
          .where((company) => company.toLowerCase().contains(query))
          .toList();
    });
  }

  void _showCompanyOnMap(String companyName) {
    final location = _companyLocations[companyName];
    if (location != null) {
      setState(() {
        _markers = [
          Marker(
            point: location,
            width: 40,
            height: 40,
            child: Icon(
              Icons.circle,
              size: 40,
              color: Colors.red.withOpacity(0.8), // например, 80% видимости
            ),
          ),
        ];
      });

      _mapController.move(location, 14); // Переместить и приблизить
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(42.8746, 74.6126),
                          initialZoom: 10.0,
                          minZoom: 2,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: 'com.example.app',
                          ),
                          MarkerLayer(markers: _markers),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск компании',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCompanies.length,
                  itemBuilder: (context, index) {
                    final company = _filteredCompanies[index];
                    return ListTile(
                      title: Text(company),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_location_alt),
                        tooltip: 'Показать на карте',
                        onPressed: () {
                          _showCompanyOnMap(company);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
