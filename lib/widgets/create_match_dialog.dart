import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/match_provider.dart';

class CreateMatchDialog extends StatefulWidget {
  const CreateMatchDialog({super.key});

  @override
  State<CreateMatchDialog> createState() => _CreateMatchDialogState();
}

class _CreateMatchDialogState extends State<CreateMatchDialog> {
  final _f1NameController = TextEditingController();
  final _f2NameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  int _duration = 300; // Default 5 minutes
  String _f1Color = '#0066cc'; // Blue
  String _f2Color = '#cc0000'; // Red

  final List<int> _durationOptions = [180, 300, 420, 600, 900]; // 3, 5, 7, 10, 15 minutes
  
  final List<String> _colorOptions = [
    '#0066cc', // Blue
    '#cc0000', // Red
    '#00cc00', // Green
    '#cc6600', // Orange
    '#6600cc', // Purple
    '#666666', // Gray
    '#000000', // Black
    '#ffffff', // White
  ];

  @override
  void dispose() {
    _f1NameController.dispose();
    _f2NameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Match'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _f1NameController,
                decoration: const InputDecoration(
                  labelText: 'Fighter 1 Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter fighter 1 name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  ..._colorOptions.map((color) => GestureDetector(
                    onTap: () => setState(() => _f1Color = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: _f1Color == color
                            ? Border.all(color: Colors.black, width: 2)
                            : color == '#ffffff'
                                ? Border.all(color: Colors.grey, width: 1)
                                : null,
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _f2NameController,
                decoration: const InputDecoration(
                  labelText: 'Fighter 2 Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter fighter 2 name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Color: '),
                  const SizedBox(width: 8),
                  ..._colorOptions.map((color) => GestureDetector(
                    onTap: () => setState(() => _f2Color = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                        shape: BoxShape.circle,
                        border: _f2Color == color
                            ? Border.all(color: Colors.black, width: 2)
                            : color == '#ffffff'
                                ? Border.all(color: Colors.grey, width: 1)
                                : null,
                      ),
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _duration,
                decoration: const InputDecoration(
                  labelText: 'Duration',
                  border: OutlineInputBorder(),
                ),
                items: _durationOptions.map((duration) {
                  final minutes = duration ~/ 60;
                  return DropdownMenuItem(
                    value: duration,
                    child: Text('$minutes minutes'),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _duration = value!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createMatch,
          child: const Text('Create'),
        ),
      ],
    );
  }

  void _createMatch() {
    if (_formKey.currentState!.validate()) {
      final matchProvider = Provider.of<MatchProvider>(context, listen: false);
      
      matchProvider.createMatch(
        f1Name: _f1NameController.text.trim(),
        f2Name: _f2NameController.text.trim(),
        duration: _duration,
        f1Color: _f1Color,
        f2Color: _f2Color,
      );
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match created successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}