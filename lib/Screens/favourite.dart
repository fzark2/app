import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fisrt_flutter/main.dart';
import 'package:firebase_core/firebase_core.dart';


class Favourite_Page extends StatelessWidget {
  Favourite_Page({Key? key}) : super(key: key);
  final Stream<QuerySnapshot> Jokes = FirebaseFirestore.instance.collection('Jokes').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Favourite Jokes"),
        leading: Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {Navigator.pop(context);},
              child: Icon(
                  Icons.arrow_back
              ),
            )
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(stream: Jokes, builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Text('Loading');

        final data = snapshot.requireData;

        return ListView.builder(
          itemCount: data.size,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
                  title: Text('${data.docs[index]['joke_text']}'),
                )
            );
          },);
      }
      ),
    );
  }
}
