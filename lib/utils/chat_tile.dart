import 'package:chat_app/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;
  const ChatTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onTap();
      },
      leading: Icon(Icons.person),
      title: Text(userProfile.name!),
    );
  }
}
