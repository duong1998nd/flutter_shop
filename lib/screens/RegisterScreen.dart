import 'package:btl_sem4/screens/login.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _fullnameError;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _phoneError;
  void _validateBeforeRegister() {
    setState(() {
      _fullnameError = _fullNameController.text.isEmpty ? 'Chua nhap ten' : null;
      _emailError = _emailController.text.isEmpty ? 'Chua nhap email' : null;
      _usernameError = _usernameController.text.isEmpty ? 'Hay nhap ten dang nhap' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Hay nhap mat khau' : null;
      _phoneError = _phoneController.text.isEmpty ? 'Hay nhap mat khau' : null;

      if (_fullnameError ==null && _emailError == null && _usernameError == null && _passwordError == null && _phoneError == null ) {
        // Proceed with login if there are no errors
        _register();
      }
    });
  }
  void _register() {
    if (_formKey.currentState!.validate()) {
      // Perform registration logic here
      print('Full Name: ${_fullNameController.text}');
      print('Email: ${_emailController.text}');
      print('Username: ${_usernameController.text}');
      print('Password: ${_passwordController.text}');
      print('Phone: ${_phoneController.text}');
      // You can also navigate to the next screen after successful registration
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_left),
          iconSize: 50,
          onPressed: () => Navigator.pushReplacement<void, void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => LoginScreen(),
            ),
          ),
        ),
        title: Text('ABC Shop'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Tao tai khoan moi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Nhanh chong va de dang',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _fullNameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Ho & ten ',
                          hintText: 'Nhap ho va ten o day',
                          errorText: _fullnameError,
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nhap email',
                          hintText: 'Nhap email o day',
                          errorText: _emailError,
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                            padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nhap ten dang nhap',
                          hintText: 'Nhap ten dang nhap o day',
                          errorText: _usernameError,
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Mat khau',
                          hintText: 'Nhap mat khau o day',
                          errorText: _passwordError,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Nhap so dien thoai',
                          hintText: 'Nhap so dien thoai o day',
                          errorText: _phoneError,
                          prefixIcon: Icon(Icons.person_outline),
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
                              child: Text( 'Dang ky',
                                style: TextStyle(color: Colors.black87, fontSize: 20),
                              ),
                              onPressed: _validateBeforeRegister

                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

}
