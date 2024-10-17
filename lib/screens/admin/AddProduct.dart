
//
import 'dart:convert';
import 'dart:io';
import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/screens/admin/AdminHomeScreen.dart';
import 'package:btl_sem4/screens/user/MyHomePage.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewProductForm extends StatefulWidget {
  @override
  _NewProductFormState createState() => _NewProductFormState();
}

class _NewProductFormState extends State<NewProductForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final salePriceController = TextEditingController();
  final desciptionController = TextEditingController();
  final authorController = TextEditingController();
  final categoryController = TextEditingController();

  String? _selectedCategory;
  List<Category> categories = [];
  File? _image;  // Store the selected image

  @override
  void initState() {
    super.initState();
    _loadCategories();

  }
  void _loadCategories() async {
    CategoryService().getCategories().then((value) {
      var data =
      jsonDecode(const Utf8Decoder().convert(value.bodyBytes)) as List;
      setState(() {
        categories = data.map((e) => Category.fromJson(e)).toList();
      });
    });
  }

  void _clearForm() {
    nameController.clear();
    priceController.clear();
    salePriceController.clear();
    desciptionController.clear();
    authorController.clear();
    setState(() {
      _image = null;
      _selectedCategory = null;
    });
  }


  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> addProduct() async {
    String? token;
    final pref = await SharedPreferences.getInstance();
    token = pref.getString("token");
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Common.domain}/api/admin/product'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = nameController.text;
      request.fields['price'] = priceController.text;
      request.fields['sale_price'] = salePriceController.text;
      request.fields['desciption'] = desciptionController.text;
      request.fields['author'] = authorController.text;
      request.fields['category_id'] = _selectedCategory ?? '';

      if (_image != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _image!.path,
        ));
      }
      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thêm thành công!')));
        Future.delayed(Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminHomeScreen()),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi, hãy thử lại.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_left),
          tooltip: 'back',
          iconSize: 35,
          onPressed: () => Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => AdminHomeScreen(),
            ),
          ),
        ),
        title: Text('Thêm sản phẩm'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),

        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children:  [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tên sản phẩm không được để trống';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Giá',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Giá không được để trống';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: salePriceController,
                decoration: InputDecoration(
                  labelText: 'Giá khuyến mãi',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Giá khuyến mãi không được để trống';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: desciptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mô tả không được để trống';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              SizedBox(height: 5),
              TextFormField(
                controller: authorController,
                decoration: InputDecoration(
                  labelText: 'Tác giả',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tác giả không được để trống';
                  }
                  return null;
                },
              ),
              SizedBox(height: 5),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Danh mục',
                  labelStyle: TextStyle(color: Colors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                value: _selectedCategory,
                items: categories.map((Category category) {
                  return DropdownMenuItem<String>(
                    value: category.id.toString(),
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Chọn danh mục';
                  }
                  return null;
                },
              ),

              SizedBox(height: 25),
              // Image Picker
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Chọn ảnh'),
              ),
              if (_image != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Image.file(_image!, width: 40, height: 40),
                ),
              SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: addProduct,
                      child: Text(
                        'Thêm mới',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _clearForm,
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }}
