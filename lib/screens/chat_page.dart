import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;
  const ChatPage({Key? key, required this.chatUser}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

ChatUser user = ChatUser(
  id: '1',
  firstName: 'Charles',
  lastName: 'Leclerc',
);

class _ChatPageState extends State<ChatPage> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   TextEditingController messageController = TextEditingController();
//   DatabaseService databaseService = DatabaseService();
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _firestore.collection('chats').snapshots().listen((data) {
      setState(() {
        messages = data.docs.map((doc) {
          return ChatMessage(
            user: ChatUser(
              id: doc.data()['uid'],
              firstName: doc.data()['name'],
            ),
            createdAt: (doc.data()['createdAt'] as Timestamp).toDate(),
          );
        }).toList();
      });
    });
  }

  void onSend(ChatMessage message) {
    _firestore.collection('chats').add({
      'text': message.text,
      'uid': widget.chatUser.uid,
      'name': widget.chatUser.name,
      'createdAt': FieldValue.serverTimestamp(),
    }).then((value) {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text(widget.chatUser.name!)),
//         body: DashChat(
//           messageOptions: MessageOptions(showTime: true),
//           currentUser: widget.chatUser as ChatUser,
//           inputOptions: InputOptions(alwaysShowSend: true),
//           onSend: (message) {},
//           messages: messages,
//         ));
//   }
// }

  // List<ChatMessage> messages = <ChatMessage>[
  //   ChatMessage(
  //     text: 'Hey!',
  //     user: user,
  //     createdAt: DateTime.now(),
  //   ),
  // ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 82, 152, 210),
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 2,
              ),
              const CircleAvatar(
                child: Icon(Icons.person_2),
                maxRadius: 20,
              ),
              const SizedBox(
                width: 12,
              ),
              Text(
                widget.chatUser.name.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 25),
              )
            ]),
          ),
        ),
      ),
      body: DashChat(
          messages: messages,
          currentUser: ChatUser(
              id: widget.chatUser.uid.toString(),
              firstName: widget.chatUser.name.toString()),
          onSend: onSend),
    );
  }
}
