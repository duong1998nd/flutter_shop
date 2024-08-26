import 'dart:convert';

import 'package:btl_sem4/model/common.dart';
import 'package:btl_sem4/model/user.dart';
import 'package:btl_sem4/screens/MyHomePage.dart';
import 'package:btl_sem4/screens/RegisterScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      setState(() {
        _isLoading = false;
      });

      Navigator.pushReplacement<void, void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => HomeScreen(),
        ),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Dang nhap fail');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login Page"),
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
                    labelText: 'Nhap ten dang nhap',
                    hintText: 'Nhap ten dang nhap o day',
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
                    labelText: 'Mat khau',
                    hintText: 'Nhap mat khau o day',
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
                          child: Text('Chua co tai khoan? '),
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
                              child: Text('Dang ky', style: TextStyle(fontSize: 14, color: Colors.blue),)),
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

