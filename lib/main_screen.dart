import 'package:clippy/welcome_screen.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clippy/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';

final _firestore = FirebaseFirestore.instance;
User? loggedInUser;

class ClipboardItems extends StatefulWidget {
  static const String id = 'main_screen';
  const ClipboardItems({super.key});

  @override
  State<ClipboardItems> createState() => _ClipboardItemsState();
}

class _ClipboardItemsState extends State<ClipboardItems> {
  final _auth = FirebaseAuth.instance;
  Widget? data;
  Future<void> getCurrentUser() async {
    try {
      final user = await _auth.currentUser;
      loggedInUser = user;
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser().then((value) {
      setState(() {
        data = const MessagesStream();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? _text;
    final messageTextController = TextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        elevation: 4,
        shadowColor: Theme.of(context).shadowColor,
        toolbarHeight: 70.0,
        title: const Text('📋 Clippy'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () async {
              try {
                await _auth.signOut();
                Navigator.popAndPushNamed(context, WelcomeScreen.id);
                Fluttertoast.showToast(
                  msg: "Successfully logged out!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
              } catch (e){
                Fluttertoast.showToast(
                  msg: e.toString(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey,
                  textColor: Colors.white,
                  fontSize: 16.0
                );
                return;
              }
            },
          )
        ],
      ),
      body: DoubleBackToCloseApp(
        snackBar: const SnackBar(
          content: Text('Tap back again to leave'),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Tap on the tiles to copy to clipboard',
              ),
            ),
            Expanded(child: data == null ? Container() : data!),
            TextField(
              controller: messageTextController,
              decoration: kTextFieldDecoration.copyWith(
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ), 
                hintText: 'Send text across all your devices...',
                suffixIcon: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_text == null || loggedInUser == null) {
                    return;
                  }
                  //Implement send functionality.
                  messageTextController.clear();
                  _firestore.collection('users').doc('${loggedInUser!.uid.toString()}').collection('clipboard_data').add({
                    'text': _text,
                    'senderId': loggedInUser!.uid.toString(),
                    'email': loggedInUser!.email.toString(),
                    'sentTime': Timestamp.now(),
                  });
                }),
              ),
              onChanged: (value) {
                _text = value;
              },
            ),
          ],
        ),
      )
    );
  }
}

class MessagesStream extends StatelessWidget {
  const MessagesStream({super.key});

  Future<void> setClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    if (loggedInUser == null) {
      return const Column(children: []);
    }
    return StreamBuilder(
      stream: _firestore.collection('users').doc('${loggedInUser!.uid.toString()}').collection('clipboard_data').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          );
        }
        final messages = snapshot.data?.docs;
        final maps = [];
        for (var item in messages!.toList()) {
          maps.add(item.data());
        }
        maps.sort((a, b) => (b['sentTime']).compareTo(a['sentTime']));
        List<MessageBubble> messageBubbles = [];
        for (var message in maps) {
          final clipboardItem = message['text'];
          final messageBubble = MessageBubble(text: clipboardItem);
          messageBubbles.add(messageBubble);
        }
        return ListView(
          children: messageBubbles
        );
      }
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String? text;
  const MessageBubble({super.key, this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 120.0,
            child: GestureDetector(
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: "$text"));
              },
              child: Material(
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                ),
                elevation: 4.0,
                shadowColor: Theme.of(context).shadowColor,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: CupertinoScrollbar(
                  thumbVisibility: true,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      children: [
                        Text(
                          '$text',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15.0
                          ),
                        ),
                      ]
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]
      ),
    );
  }
}
