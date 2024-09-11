import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csit998_capstone_g16/screens/userScreen/mylist.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  int _currentIndex = 3;
  String username = "Guest"; 

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  void fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          username = userData['username'] ?? 'No Name';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 154),
                Text(
                  "Hi, $username!",  
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 44),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/vocabList');
                  },
                  child: Text('MY LIST'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6f8c51).withOpacity(0.6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
           switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, '/auslan');
                break;
              case 1:
                Navigator.pushReplacementNamed(context, '/search');
                break;
              case 2:
                Navigator.pushReplacementNamed(context, '/library');
                break;
              case 3:
                Navigator.pushReplacementNamed(context, '/user');
                break;
            }
        },
        backgroundColor: Colors.black,  
        selectedItemColor: Colors.blue, 
        unselectedItemColor: Colors.green, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Auslan To Text',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
       ],
     ),

    );
  }
}
