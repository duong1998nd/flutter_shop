import 'dart:convert';

import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/provider/CartProvider.dart';
import 'package:btl_sem4/screens/admin/AdminHomeScreen.dart';
import 'package:btl_sem4/screens/user/MyHomePage.dart';
import 'package:btl_sem4/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final _keys = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;
  bool _validate = false;
  bool _isLoading = false;

  void _validateAndLogin() {
    setState(() {
      _usernameError = usernameController.text.isEmpty ? 'Hay nhap ten dang nhap' : null;
      _passwordError = passwordController.text.isEmpty ? 'Hay nhap mat khau' : null;

      if (_usernameError == null && _passwordError == null) {
        // Proceed with login if there are no errors
        _login();
      }
    });
  }
  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse("${Common.domain}/api/auth/authenticate"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );
    if (response.statusCode == 200) {
      final token = response.body;
      print('Response Body: ${response.body}');
      print("bearer: $token");

      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = parts[1];

        // Add padding if necessary
        final padding = '=' * ((4 - payload.length % 4) % 4);
        final normalizedPayload = payload + padding;

        final decodedPayload = jsonDecode(utf8.decode(base64Url.decode(normalizedPayload)));
        final List<dynamic> authorities = decodedPayload['authorities'];

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        Provider.of<CartProvider>(context, listen: false).loadCart();
        Provider.of<CartProvider>(context, listen: false).recalculateTotalPrice();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        if (authorities.any((auth) => auth['authority'] == 'ADMIN')) {
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => AdminHomeScreen(), // Navigate to admin page
            ),
          );
        } else if (authorities.any((auth) => auth['authority'] == 'USER')){
          Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => HomeScreen(), // Navigate to user home page
            ),
          );
        }
      } else {
          setState(() {
            _isLoading = false;
          });
      }
    } else {
        setState(() {
          _isLoading = false;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Đăng nhập"),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _keys,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 110.0, bottom: 15),
                child: Center(
                  child: Container(
                      width: 200,
                      height: 100,
                      /*decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(50.0)),*/
                      child: Image.asset('assets/images/login_image.jpeg')),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Tên đăng nhập',
                    hintText: 'Nhập tên đăng nhập',
                    errorText: _usernameError,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Mật khẩu',
                    hintText: 'Nhập mật khẩu',
                    errorText: _passwordError,
                  ),
                ),
              ),

              SizedBox(
                height: 65,
                width: 360,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      child: Text( 'Đăng nhập', style: TextStyle(color: Colors.black87, fontSize: 20),
                      ),
                      onPressed: _validateAndLogin
                    ),
                  ),
                ),
              ),

              SizedBox(
                height: 50,
              ),
              Container(
                  child: Center(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 82),
                          child: Text('Bạn chưa có tài khoản? '),
                        ),

                        Padding(
                          padding: const EdgeInsets.only(left:1.0),
                          child: InkWell(
                              onTap: (){
                                Navigator.pushReplacement<void, void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) => RegisterScreen(),
                                  ),
                                );
                              },
                              child: Text('Đăng ký', style: TextStyle(fontSize: 14, color: Colors.blue),)),
                        )
                      ],
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}


// add product form
// import 'dart:convert';
// import 'dart:io';
// import 'package:btl_sem4/model/Category.dart';
// import 'package:btl_sem4/model/common.dart';
// import 'package:btl_sem4/services/CategoryService.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class NewProductForm1 extends StatefulWidget {
//   @override
//   _NewProductFormState createState() => _NewProductFormState();
// }
//
// class _NewProductFormState extends State<NewProductForm1> {
//   final _formKey = GlobalKey<FormState>();
//   final nameController = TextEditingController();
//   final priceController = TextEditingController();
//   final salePriceController = TextEditingController();
//   final desciptionController = TextEditingController();
//   final authorController = TextEditingController();
//   final categoryController = TextEditingController();
//
//   String? _selectedCategory;
//   List<Category> categories = [];
//   File? _image;  // Store the selected image
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//
//   }
//   void _loadCategories() async {
//     CategoryService().getCategories().then((value) {
//       var data =
//       jsonDecode(const Utf8Decoder().convert(value.bodyBytes)) as List;
//       setState(() {
//         categories = data.map((e) => Category.fromJson(e)).toList();
//       });
//     });
//   }
//
//   void _clearForm() {
//     nameController.clear();
//     priceController.clear();
//     salePriceController.clear();
//     desciptionController.clear();
//     authorController.clear();
//     setState(() {
//       _image = null;
//       _selectedCategory = null;
//     });
//   }
//
//
//   Future<void> pickImage() async {
//     final ImagePicker _picker = ImagePicker();
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _image = File(image.path);  // Store the selected image file
//       });
//     }
//   }
//
//   Future<void> addProduct() async {
//     String? token;
//     final pref = await SharedPreferences.getInstance();
//     token = pref.getString("token");
//     if (_formKey.currentState!.validate()) {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('${Common.domain}/api/admin/product'),  // Change to your API endpoint
//       );
//       request.headers['Authorization'] = 'Bearer $token';
//
//       // Add fields
//       request.fields['name'] = nameController.text;
//       request.fields['price'] = priceController.text;
//       request.fields['sale_price'] = salePriceController.text;
//       request.fields['desciption'] = desciptionController.text;
//       request.fields['author'] = authorController.text;
//       request.fields['category_id'] = _selectedCategory ?? '';
//
//       // Add the image file if it exists
//       if (_image != null) {
//         request.files.add(await http.MultipartFile.fromPath(
//           'image',  // The name of the field expected by the server
//           _image!.path,
//         ));
//       }
//
//       // Send the request
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         // Product added successfully
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thêm thành công!')));
//       } else {
//         // Handle error
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi.')));
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Thêm sản phẩm'),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(8.0),
//
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children:  [
//               TextFormField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   labelText: 'Tên sản phẩm',
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Tên sản phẩm không được để trống';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 5),
//               TextFormField(
//                 controller: priceController,
//                 decoration: InputDecoration(
//                   labelText: 'Giá',
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Giá không được để trống';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 5),
//               TextFormField(
//                 controller: salePriceController,
//                 decoration: InputDecoration(
//                   labelText: 'Giá khuyến mãi',
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Giá khuyến mãi không được để trống';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 5),
//               TextFormField(
//                 controller: desciptionController,
//                 decoration: InputDecoration(
//                   labelText: 'Mô tả',
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Mô tả không được để trống';
//                   }
//                   return null;
//                 },
//                 maxLines: 3,
//               ),
//               SizedBox(height: 5),
//               TextFormField(
//                 controller: authorController,
//                 decoration: InputDecoration(
//                   labelText: 'Tác giả',
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Tác giả không được để trống';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 5),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: 'Danh mục',
//                   labelStyle: TextStyle(color: Colors.grey),
//                   enabledBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.grey, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Colors.green, width: 2.0),
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 value: _selectedCategory,
//                 items: categories.map((Category category) {
//                   return DropdownMenuItem<String>(
//                     value: category.id.toString(),
//                     child: Text(category.name),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _selectedCategory = newValue;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Chọn danh mục';
//                   }
//                   return null;
//                 },
//               ),
//
//               SizedBox(height: 25),
//               // Image Picker
//               ElevatedButton(
//                 onPressed: pickImage,
//                 child: Text('Chọn ảnh'),
//               ),
//               if (_image != null)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 10.0),
//                   child: Image.file(_image!, width: 40, height: 40),
//                 ),
//               SizedBox(height: 20),
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: addProduct,
//                       child: Text(
//                         'Thêm mới',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: _clearForm,
//                       child: Icon(
//                         Icons.cancel,
//                         color: Colors.black,
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }}


