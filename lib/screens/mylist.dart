import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('My Saved Words'),
        ),
        body: Center(
          child: Text('Please log in to view your saved words.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Saved Words'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('savedWords')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final words = snapshot.data!.docs;

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(words[index]['word']),
              );
            },
          );
        },
      ),
    );
  }
}
