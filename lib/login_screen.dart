import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:clippy/main_screen.dart';
import 'package:clippy/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[  
              const Text(
                'Welcome back!',
                style: kTitleDecoration,
              ),
              const SizedBox(
                height: 20.0,
              ),     
              TextField(
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  email = value;
                },
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
              ),
              const SizedBox(
                height: 24.0,
              ),
              FloatingActionButton(
                child: const Text('Log In'),
                onPressed: () async {
                  //Go to login screen.
                  try {
                    setState(() {
                      _saving = true;
                    });
                    final dynamic response = await _auth.signInWithEmailAndPassword(email: email, password: password);
                    if (response != null) {
                      Navigator.pushNamedAndRemoveUntil(context, ClipboardItems.id, (route) => false);
                    }
      
                    setState(() {
                        _saving = false;
                    });
      
                  } catch (e) {
                    
                  Fluttertoast.showToast(
                    msg: e.toString(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0
                  );

                    setState(() {
                      _saving = false;
                    });
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
