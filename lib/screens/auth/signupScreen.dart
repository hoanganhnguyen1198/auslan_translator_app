import 'package:flutter/material.dart';
//import 'package:shared_preferences/shared_preferences.dart';
import 'package:csit998_capstone_g16/utils/colors.dart';  
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // store username and other user info
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        // add other user info here if applicable
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration successful!')),
      );
      Navigator.pushNamed(context, '/login');
      // Perform further actions, such as navigation
    } on FirebaseAuthException catch (e) {
       print('Failed to register user: ${e.message}');
    } catch (e) {
       print('An error occurred: ${e.toString()}');
    }
  }
    
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Sign Up'),
        backgroundColor: bgColor,
      ),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 32),
              Text(
                'Sign Up with Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _signUp;
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  //style
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle the link to terms and conditions
                },
                child: Text(
                  'By continuing, you agree to accept \nour Privacy Policy & Term of Service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
*/
  
  /*
class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _saveSignupInfo() async {
    if (!_validatePassword(_passwordController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password must include at least 8 characters, including uppercase, lowercase, digit, and special characters.')),
      );
      return;
    }

    if (!(await _isUsernameUnique(_usernameController.text))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Username is already taken. Please choose another one.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('email', _emailController.text);
    await prefs.setString('password', _passwordController.text);
    await _saveUsername(_usernameController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signup info saved!')),
    );
  }

  bool _validatePassword(String password) {
    Pattern pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\$\@\$!%*?&])[A-Za-z\d\$\@\$!%*?&]{8,}';
    RegExp regex = RegExp(pattern.toString());
    return regex.hasMatch(password);
  }

  Future<bool> _isUsernameUnique(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final allUsernames = prefs.getStringList('usernames') ?? [];
    return !allUsernames.contains(username);
  }

  Future<void> _saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final allUsernames = prefs.getStringList('usernames') ?? [];
    allUsernames.add(username);
    await prefs.setStringList('usernames', allUsernames);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Sign Up'),
        backgroundColor: bgColor,
      ),
      body: Container(
        color: bgColor,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 32),
              Text(
                'Sign Up with Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: tfColor,
                  errorText: _passwordController.text.isNotEmpty && !_validatePassword(_passwordController.text) ? 'Invalid format' : null,
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  _saveSignupInfo();
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Sign Up'),
                style: ElevatedButton.styleFrom(
                  //style
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle the link to terms and conditions
                },
                child: Text(
                  'By continuing, you agree to accept \nour Privacy Policy & Term of Service.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
*/