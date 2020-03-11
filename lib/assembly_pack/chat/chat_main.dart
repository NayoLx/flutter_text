import 'dart:math';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text/assembly_pack/chat/sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'image_zoomable.dart';

void main() => runApp(chatPackApp());

class chatPackApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "聊天室",
      home: ChatScene(),
    );
  }
}

class ChatScene extends StatefulWidget {
  @override
  ChatSceneState createState() => ChatSceneState();
}

//google登录
DatabaseReference reference;
GoogleSignIn googleSignIn = new GoogleSignIn(
  scopes: [
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class ChatSceneState extends State<ChatScene> {
  final auth = FirebaseAuth.instance; //监听用户UID
  final analytics = new FirebaseAnalytics(); //监听事件
  final TextEditingController _textEditingController =
      new TextEditingController(); //输入框
  bool isComposer;
  GoogleSignInAccount _currentUser;

  //生命周期
  void initState() {
    super.initState();
    _setDatabase();
  }

  //firebase database设置
  Future<void> _setDatabase() async {
    final App = await FirebaseApp.configure(
      name: 'db2',
      options: FirebaseOptions(
        googleAppID: '1:32984109309:android:30927d8d01aa5b244eae94',
        apiKey: 'AIzaSyDmY0jjaHswJ65DP9KI4oEA4iyCkXiCZxQ',
        databaseURL: 'https://flutter-talk-app-3ed74.firebaseio.com',
      ),
    );
    var db = FirebaseDatabase(app: App);
    reference = db.reference().child('messages');
  }

  //google登录 配置信息
  Future<void> _ensureLoggedIn() async {
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
    });
    if (_currentUser == null) await googleSignIn.signInSilently();
    if (_currentUser == null) {
      await googleSignIn.signIn();
      analytics.logSignUp(); //google事件日志
    }
    // google用户登录
    if (auth.currentUser != null) {
      GoogleSignInAuthentication credentials =
          await googleSignIn.currentUser.authentication;
      final AuthCredential credential = await GoogleAuthProvider.getCredential(
        idToken: credentials.idToken,
        accessToken: credentials.accessToken,
      );
      await auth.signInWithCredential(credential);
      await auth.currentUser();
    }
  }

  //删除聊天框里的消息并发送
  Future<void> _handleSubmitted(String text) async {
    _textEditingController.clear();
    setState(() {
      isComposer = false;
    });
    await _ensureLoggedIn();
    _sendMessage(text: text);
  }

  //发送消息
  void _sendMessage({String text, String imageUrl}) {
    reference.push().set({
      'text': text,
      'imageUrl': imageUrl,
      'senderName': googleSignIn.currentUser.displayName,
      'senderPhotoUrl': googleSignIn.currentUser.photoUrl,
    });
    analytics.logEvent(name: 'send_message'); //google事件日志
  }

  //选择图片
  void _pickerImage() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    int random = new Random().nextInt(100000);
    StorageReference ref =
        FirebaseStorage.instance.ref().child("image_$random.jpg");
    StorageUploadTask uploadTask = ref.putFile(imageFile);
    await uploadTask.onComplete;
    String downloadUrl = await uploadTask.lastSnapshot.ref.getDownloadURL();
    _sendMessage(imageUrl: downloadUrl);
  }

  //底部组件
  Widget _buildTextComposer() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: new EdgeInsets.symmetric(horizontal: 4.0),
            child: new IconButton(
                icon: new Icon(Icons.photo_camera),
                onPressed: () {
                  _pickerImage();
                }),
          ),
          Flexible(
            child: TextField(
              controller: _textEditingController,
              onChanged: (String text) {
                setState(() {
                  isComposer = text.length > 0;
                });
              },
              decoration: InputDecoration.collapsed(hintText: "发送消息"),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () => isComposer
                  ? _handleSubmitted(_textEditingController.text)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  //聊天消息查看
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("聊天"),
        actions: <Widget>[],
      ),
      body: Column(
        children: <Widget>[
          Flexible(
              child: FirebaseAnimatedList(
                  query: reference,
                  sort: (a, b) => b.key.compareTo(a.key),
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, DataSnapshot snapshot,
                      Animation<double> animation, __) {
                    return ChatMessage(
                        snapshot: snapshot, animation: animation);
                  })),
          Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }
}

//消息
class ChatMessage extends StatelessWidget {
  ChatMessage({this.snapshot, this.animation});

  final DataSnapshot snapshot;
  final Animation animation;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
                margin: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                    child: Image.network(snapshot.value['senderPhotoUrl']))),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(snapshot.value['senderName']),
                  Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: snapshot.value['imageUrl'] != null
                        ? GestureDetector(
                            onTap: () {

                            },
                            child: Image.network(
                              snapshot.value['imageUrl'],
                              width: 250.0,
                              height: 100.0,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Text(snapshot.value['text']),
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
