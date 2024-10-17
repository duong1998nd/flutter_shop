import 'package:btl_sem4/model/Category.dart';
import 'package:btl_sem4/screens/admin/AdminHomeScreen.dart';
import 'package:btl_sem4/services/CategoryService.dart';
import 'package:flutter/material.dart';

class CategoryForm extends StatefulWidget {

  Category? cat;
  @override
  State<StatefulWidget> createState() => _CategoryFormState();

}

class _CategoryFormState extends State<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  CategoryService catService = new CategoryService();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.cat != null) {
      final nameController = TextEditingController();
    }
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          Navigator.pop(context);
          return Future.value(false);
        },
        child: Scaffold(
          appBar: AppBar(
              title: Center(
                child: Text('Tạo mới danh mục'),
              )),
          body: Container(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                          BorderSide(color: Colors.blueGrey, width: 2.0)),
                      border: OutlineInputBorder(borderSide: BorderSide()),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Tên danh mục',
                      labelText: 'Tên danh mục',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Tên danh mục không được để trống';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        catService.addCategory(nameController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Danh mục đã được thêm thành công!'),
                          ),
                        );

                        Future.delayed(Duration(seconds: 2), () {
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => AdminHomeScreen()),
                            );
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Thêm mới',
                      style: TextStyle(color: Colors.black87),
                    ),
                  )

                ],
              ),
            ),
          ),
        ));
  }
}
// ElevatedButton(
// onPressed: addProduct,
// child: Text(
// 'Thêm mới',
// style: TextStyle(color: Colors.black),
// ),
// style: ElevatedButton.styleFrom(
// backgroundColor: Colors.blueAccent,
// ),
// ),