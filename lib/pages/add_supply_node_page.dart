import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/supply_node.dart';

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
                decoration: const InputDecoration(labelText: "Широта"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Введите число' : null,
              ),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: "Долгота"),
                keyboardType: TextInputType.number,
                validator: (val) => val == null || double.tryParse(val) == null ? 'Введите число' : null,
              ),
              DropdownButtonFormField(
                value: _type,
                decoration: const InputDecoration(labelText: "Тип"),
                items: ["Ферма", "Производитель", "Склад", "Ритейлер"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _type = val!),
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
              const Text("Следующие этапы"),
              ...widget.existingNodes.map((node) {
                return CheckboxListTile(
                  title: Text(node.name),
                  value: _selectedNextSteps.contains(node.name),
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
