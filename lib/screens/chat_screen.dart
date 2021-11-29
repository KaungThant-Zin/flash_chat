import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User loggedInUser;
  late String message;
  final textfieldController = TextEditingController();

  void getCurrentUser() {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
        debugPrint(loggedInUser.email);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // void getMessage() async {
  //   QuerySnapshot messages = await _firestore.collection('messages').get();
  //   for (var msgData in messages.docs) {
  //     print(msgData.data());
  //   }
  // }

  //getmessage using strean
  // void getMessageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     for (var msgData in snapshot.docs) {
  //       print(msgData.data());
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              //Implement logout functionality
              _auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ShowMessageStream(firestore: _firestore),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textfieldController,
                      onChanged: (value) {
                        //Do something with the user input.
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      //Implement send functionality.
                      textfieldController.clear();
                      debugPrint(message);
                      _firestore.collection('messages').add({
                        'sender': loggedInUser.email,
                        'text': message,
                      });
                    },
                    child: const Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//refactor messageStream
class ShowMessageStream extends StatelessWidget {
  const ShowMessageStream({
    Key? key,
    required FirebaseFirestore firestore,
  })  : _firestore = firestore,
        super(key: key);

  final FirebaseFirestore _firestore;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data!.docs;
          List<MessageStyleBubble> msgWidget = [];
          for (var msgData in messages) {
            final text = msgData['text'];
            final sender = msgData['sender'];
            final addMsgWidget = MessageStyleBubble(text: text, sender: sender);
            msgWidget.add(addMsgWidget);
          }
          return Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: msgWidget,
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

//refactor and  styling MessageStyleBubble
class MessageStyleBubble extends StatelessWidget {
  final String text;
  final String sender;
  const MessageStyleBubble({
    Key? key,
    required this.text,
    required this.sender,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            sender,
            style: const TextStyle(
              color: Colors.black38,
              fontSize: 12.0,
            ),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(20.0),
            color: Colors.lightBlueAccent,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
