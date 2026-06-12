import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: Scaffold(
    appBar: AppBar(title: Text('জুয়েলারি হিসাব'), backgroundColor: Colors.amber),
    body: Center(child: Text('আপনার জুয়েলারি অ্যাপটি সফলভাবে সচল হয়েছে!', style: TextStyle(fontSize: 18))),
  ),
));
