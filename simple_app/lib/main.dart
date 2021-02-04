import 'package:flutter/material.dart';
import 'screens/home.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
      theme: ThemeData(
          primaryColor: Colors.purple[700], accentColor: Colors.purple[700]),
    ));
