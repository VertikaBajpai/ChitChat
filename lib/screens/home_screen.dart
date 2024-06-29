import 'package:chat_app/models/user_profile.dart';
import 'package:chat_app/screens/chat_page.dart';
import 'package:chat_app/screens/login_screen.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/utils/chat_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final DatabaseService databaseService = DatabaseService();

  Future<bool> logout() async {
    try {
      await auth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void showToast(String text) {
    try {
      DelightToastBar(
          autoDismiss: true,
          position: DelightSnackbarPosition.top,
          builder: (context) {
            return ToastCard(title: Text(text));
          }).show(context);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 82, 152, 210),
        actions: [
          IconButton(
              onPressed: () async {
                bool result = await logout();
                if (result) {
                  showToast('Successfully Logged Out');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()));
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: _chatList(),
        ),
      ),
    );
  }

  Widget _chatList() {
    // CollectionReference userCollection = firestore.collection('users');

    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load data'),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            print('No data found');
            return const Center(
              child: Text('No users'),
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // return ListView.builder(
            //     itemCount: snapshot.data?.docs.length,
            //     itemBuilder: (context, index) {
            //       UserProfile? user = snapshot.data!.docs[index].data();
            //       if (user != null) {
            //         return Padding(
            //             padding: const EdgeInsets.all(5.0),
            //             child: ChatTile(
            //               userProfile: user,
            //               onTap: () async {
            //                 final chatExists =
            //                     await databaseService.checkChatExists(
            //                         auth.currentUser?.uid, user.uid);
            //                 if (!chatExists) {
            //                   await databaseService.createNewChat(
            //                       auth.currentUser!.uid, user.uid!);
            //                 }
            //                 Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) =>
            //                             ChatPage(chatUser: user)));
            //               },
            //             ));
            return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;

              return ListTile(
                title: Text(data['name'] ?? 'No name'),
                leading: const CircleAvatar(
                  radius: 20,
                  child: Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                ),
                onTap: () {
                  UserProfile user =
                      UserProfile(name: data['name'], uid: data['uid']);
                  // final chatExists = await databaseService.checkChatExists(
                  //     auth.currentUser?.uid, user.uid);
                  // if (!chatExists) {
                  //   await databaseService.createNewChat(
                  //       auth.currentUser!.uid, user.uid!);
                  // }

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatPage(
                                chatUser: user,
                              )));
                },
              );
            }).toList());
          } else {
            return const Center(child: Text('Error'));
          }
        });
  }
}
