import 'package:chat_flutter/chat_screen.dart';
import 'package:flutter/material.dart';

void main() async{
  runApp(
    MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ChatScreem(),
    theme: ThemeData(
      primarySwatch: Colors.blue,
      iconTheme: IconThemeData(
        color: Colors.blue
      ),
    ),
  ));
}