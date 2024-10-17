import 'package:btl_sem4/model/common.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryEditScreen extends StatefulWidget {
  final int categoryId;

  const CategoryEditScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  _CategoryEditScreenState createState() => _CategoryEditScreenState();
}

class _CategoryEditScreenState extends State<CategoryEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late int _status;

  @override
  void initState() {
    super.initState();
    _fetchCategory();
  }

  Future<void> _fetchCategory() async {
    final response = await http.get(Uri.parse('${Common.domain}/api/admin/category/details?id=${widget.categoryId}'));
    if (response.statusCode == 200) {
      final category = json.decode(response.body);
      setState(() {
        _name = category['name'];
        _status = category['status'];
      });
    } else {
      // Handle error
    }
  }

  Future<void> _updateCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final response = await http.put(
        Uri.parse('http://your-api-url/api/categories/${widget.categoryId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': _name, 'status': _status}),
      );

      if (response.statusCode == 200) {
        // Handle success, e.g., show a success message or navigate back
        Navigator.pop(context);
      } else {
        // Handle error
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Category')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Category Name'),
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<int>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  DropdownMenuItem(value: 1, child: Text('Active')),
                  DropdownMenuItem(value: 0, child: Text('Inactive')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a status';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateCategory,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
