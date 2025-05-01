import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MyApp());
}

enum UserRole { company, individual }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  void _selectRole(BuildContext context, UserRole role) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyMapPage(userRole: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Выберите роль")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectRole(context, UserRole.individual),
              child: const Text("Частное лицо"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole(context, UserRole.company),
              child: const Text("Компания"),
            ),
          ],
        ),
      ),
    );
  }
}

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
}

class CompanyMapPage extends StatefulWidget {
  final UserRole userRole;

  const CompanyMapPage({Key? key, required this.userRole}) : super(key: key);

  @override
  _CompanyMapPageState createState() => _CompanyMapPageState();
}

class _CompanyMapPageState extends State<CompanyMapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  final List<SupplyNode> _supplyNodes = [
    SupplyNode(
      name: "Ферма «Зеленый лист»",
      location: LatLng(41.0, 74.0),
      type: "Ферма",
      isEthical: true,
      certifications: ["Organic", "Fair Trade"],
      nextSteps: ["Производство Чайной фабрики"],
    ),
    SupplyNode(
      name: "Производство Чайной фабрики",
      location: LatLng(42.0, 74.5),
      type: "Производитель",
      isEthical: false,
      certifications: [],
      nextSteps: ["Склад компании ABC"],
    ),
    SupplyNode(
      name: "Склад компании ABC",
      location: LatLng(42.8, 74.6),
      type: "Дистрибьютор",
      isEthical: true,
      certifications: ["ISO 14001"],
      nextSteps: [],
    ),
  ];

  List<SupplyNode> _filteredNodes = [];
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showOnlyEthical = false;

  @override
  void initState() {
    super.initState();
    _filteredNodes = _supplyNodes;
    _searchController.addListener(_applyFilters);
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
      floatingActionButton: widget.userRole == UserRole.company
          ? FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddSupplyNodePage(
                existingNodes: _supplyNodes,
                onNodeAdded: (newNode) {
                  setState(() {
                    _supplyNodes.add(newNode);
                    _applyFilters();
                  });
                },
              ),
            ),
          );
        },
      )
          : null,
      body: SafeArea(
        child: Padding(
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
              const SizedBox(height: 10),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
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
                        tooltip: 'Показать на карте',
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
      ),
    );
  }
}

class AddSupplyNodePage extends StatefulWidget {
  final List<SupplyNode> existingNodes;
  final Function(SupplyNode) onNodeAdded;

  const AddSupplyNodePage({
    super.key,
    required this.existingNodes,
    required this.onNodeAdded,
  });

  @override
  State<AddSupplyNodePage> createState() => _AddSupplyNodePageState();
}

class _AddSupplyNodePageState extends State<AddSupplyNodePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();
  final TextEditingController _certsController = TextEditingController();

  String _type = "Ферма";
  bool _isEthical = true;
  List<String> _selectedNextSteps = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Добавить звено")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Название"),
                validator: (val) => val == null || val.isEmpty ? 'Введите название' : null,
              ),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: "Широта (Lat)"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Введите число' : null,
              ),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: "Долгота (Lng)"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Введите число' : null,
              ),
              DropdownButtonFormField(
                value: _type,
                items: ["Ферма", "Производитель", "Склад", "Ритейлер"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _type = val!),
                decoration: const InputDecoration(labelText: "Тип"),
              ),
              SwitchListTile(
                title: const Text("Этичный"),
                value: _isEthical,
                onChanged: (val) => setState(() => _isEthical = val),
              ),
              TextFormField(
                controller: _certsController,
                decoration: const InputDecoration(labelText: "Сертификации (через запятую)"),
              ),
              const SizedBox(height: 10),
              const Text("Следующие этапы (nextSteps)"),
              ...widget.existingNodes.map((node) {
                return CheckboxListTile(
                  value: _selectedNextSteps.contains(node.name),
                  title: Text(node.name),
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedNextSteps.add(node.name);
                      } else {
                        _selectedNextSteps.remove(node.name);
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text("Добавить"),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newNode = SupplyNode(
                      name: _nameController.text,
                      location: LatLng(
                        double.parse(_latController.text),
                        double.parse(_lngController.text),
                      ),
                      type: _type,
                      isEthical: _isEthical,
                      certifications: _certsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList(),
                      nextSteps: _selectedNextSteps,
                    );
                    widget.onNodeAdded(newNode);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
