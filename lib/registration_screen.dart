import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:clippy/main_screen.dart';
import 'constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {

  final _auth = FirebaseAuth.instance;
  String email = "";
  String password = "";
  String confirm_password = "";
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
                'Welcome to\nClippy 📋',
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
                obscureText: true,
                onChanged: (value) {
                  password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password',
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                onChanged: (value) {
                  confirm_password = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your password again',
                ),
              ),
              const SizedBox(
                height: 24.0,
              ),
              FloatingActionButton(
                child: const Text('Register'),
                onPressed: () async {
                  setState(() {
                    _saving = true;
                  });

                  if (password != confirm_password) {
                    Fluttertoast.showToast(
                      msg: "Passwords do not match",
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

                    return;
                  }
                  
                  try {
                    final dynamic newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                    if (newUser != null) {
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
