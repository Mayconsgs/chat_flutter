import 'dart:io';

import 'package:chat_flutter/chat_message.dart';
import 'package:chat_flutter/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreem extends StatefulWidget {
  @override
  _ChatScreemState createState() => _ChatScreemState();
}

class _ChatScreemState extends State<ChatScreem> {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  FirebaseUser _currentUser;

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = authResult.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      appBar: AppBar(
        title: Text(_currentUser != null ? "Olá, ${_currentUser.displayName}" : "Chat App"),
        elevation: 5,
        actions: <Widget>[
          _currentUser != null ? IconButton(icon: Icon(Icons.exit_to_app), onPressed: (){
            FirebaseAuth.instance.signOut();
            googleSignIn.signOut();
            _key.currentState.showSnackBar(SnackBar(
              content: Text("Logout"),
            ));
          }) : Container(),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance.collection('messages').orderBy('time', descending: true).snapshots(),
              builder: (context, snapshots) {
                switch (snapshots.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                    break;
                  case ConnectionState.active:
                    List<DocumentSnapshot> documents = snapshots.data.documents;
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index) {
                          return ChatMessage(documents[index].data, documents[index].data["uid"] == _currentUser?.uid);
                        });
                    break;
                  case ConnectionState.done:
                    return Container();
                    break;
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }

  void _sendMessage({String text, File imgFile}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível realizar login"),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl
    };

    if (imgFile != null) {

      setState(() {
        _isLoading = true;
      });

      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(imgFile);

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      data["imgUrl"] = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        _isLoading = false;
      });
    }

    if (text != null) data["text"] = text;
    data["time"] = Timestamp.now();

    Firestore.instance.collection("messages").add(data);
  }
}
