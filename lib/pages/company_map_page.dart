import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:narin_0/models/supply_node.dart';
import '../main.dart';
import 'add_supply_node_page.dart';
import '../services/api_service.dart';


class CompanyMapPage extends StatefulWidget {
  final UserRole userRole;

  const CompanyMapPage({super.key, required this.userRole});

  @override
  State<CompanyMapPage> createState() => _CompanyMapPageState();
}

class _CompanyMapPageState extends State<CompanyMapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  List<SupplyNode> _supplyNodes = [];
  List<SupplyNode> _filteredNodes = [];
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showOnlyEthical = false;

  @override
  void initState() {
    super.initState();
    _loadNodes();
    _searchController.addListener(_applyFilters);
  }

  Future<void> _loadNodes() async {
    final nodes = await ApiService.fetchSupplyNodes();
    setState(() {
      _supplyNodes = nodes.cast<SupplyNode>(); // Явное приведение типа
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNodes = _supplyNodes.where((node) {
        final matchesQuery = node.name.toLowerCase().contains(query);
        final matchesEthical = !_showOnlyEthical || node.isEthical;
        return matchesQuery && matchesEthical;
      }).toList();
    });
  }

  void _showNodeOnMap(SupplyNode node) {
    setState(() {
      _markers = [
        Marker(
          point: node.location,
          width: 40,
          height: 40,
          child: Icon(
            Icons.location_on,
            size: 40,
            color: node.isEthical ? Colors.green : Colors.red,
          ),
        ),
      ];

      _polylines = node.nextSteps.map((nextName) {
        final nextNode = _supplyNodes.firstWhere(
              (n) => n.name == nextName,
          orElse: () => SupplyNode(
            name: "",
            location: LatLng(0, 0),
            type: "",
            isEthical: false,
            certifications: [],
            nextSteps: [],
          ),
        );
        return Polyline(
          points: [node.location, nextNode.location],
          color: Colors.blueAccent,
          strokeWidth: 4.0,
        );
      }).toList();
    });

    _mapController.move(node.location, 13);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Карта цепочки поставок")),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(42.8746, 74.6126),
                        initialZoom: 10.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                          userAgentPackageName: 'com.example.app',
                        ),
                        PolylineLayer(polylines: _polylines),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    title: const Text("Показывать только этичные звенья"),
                    value: _showOnlyEthical,
                    onChanged: (val) {
                      setState(() {
                        _showOnlyEthical = val;
                        _applyFilters();
                      });
                    },
                  ),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Поиск звена...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _filteredNodes.length,
                      itemBuilder: (context, index) {
                        final node = _filteredNodes[index];
                        return ListTile(
                          title: Text(node.name),
                          subtitle: Text('${node.type} • ${node.isEthical ? "Этичный" : "Нарушения"}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: () => _showNodeOnMap(node),
                          ),
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(node.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    Text("Тип: ${node.type}"),
                                    Text("Этичный: ${node.isEthical ? "Да" : "Нет"}"),
                                    Text("Сертификации: ${node.certifications.join(", ")}"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (widget.userRole == UserRole.company)
              Positioned(
                bottom: 80,
                right: 32,
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddSupplyNodePage(
                          existingNodes: _supplyNodes,
                          onNodeAdded: (newNode) async {
                            await ApiService.addSupplyNode(newNode as SupplyNode);
                            await _loadNodes();
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
