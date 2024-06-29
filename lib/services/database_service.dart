import 'package:chat_app/models/chat.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  CollectionReference? userCollection;
  CollectionReference? chatsCollection;
  DatabaseService() {
    setUpCollection();
  }
  void setUpCollection() {
    userCollection = firestore.collection('users').withConverter<UserProfile>(
        fromFirestore: (snapshot, _) => UserProfile.fromJson(snapshot.data()!),
        toFirestore: (userProfile, _) => userProfile.toJson());
    chatsCollection = firestore.collection('chats').withConverter<Chat>(
        fromFirestore: (snapshots, _) => Chat.fromJson(snapshots.data()!),
        toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile({required UserProfile userProfile}) async {
    await userCollection?.doc(userProfile.uid).set(userProfile);
  }

  Stream<QuerySnapshot<UserProfile?>> getUserProfiles() {
    if (auth.currentUser == null) {
      throw FirebaseAuthException(
          message: 'User is not authenticated', code: 'USER_NOT_AUTHENTICATED');
    }
    return userCollection!
        .where('uid', isNotEqualTo: auth.currentUser!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile?>>;
  }

  Future<bool> checkChatExists(String? uid1, String? uid2) async {
    List uids = [uid1, uid2];
    uids.sort();
    String chatID = uids.fold("", (id, uid) => "$id$uid");
    final result = await chatsCollection?.doc(chatID).get();
    if (result != null) return result.exists;
    return false;
  }

  String generateChatID(String uid1, String uid2) {
    List uids = [uid1, uid2];

    uids.sort();
    String chatID = uids.fold("", (id, uid) => "$id$uid");
    return chatID;
  }

  Future<void> createNewChat(String uid1, String uid2) async {
    String chatId = generateChatID(uid1, uid2);
    final docRef = chatsCollection?.doc(chatId);
    final chat = Chat(id: chatId, participants: [uid2, uid2], messages: []);
    await docRef!.set(chat);
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    String chatId = generateChatID(uid1, uid2);
    final docRef = chatsCollection!.doc(chatId);
    await docRef
        .update({'messages': FieldValue.arrayUnion(message.toJson() as List)});
  }
}
