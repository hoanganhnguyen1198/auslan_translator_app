import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('data'),
          Align(
              alignment: Alignment.bottomLeft,
              child: InkWell(
                onTap: tap,
                child: Text('send again  ',
                    style: TextStyle(
                      height: 1.2,
                      fontFamily: 'Dubai',
                      fontSize: 13,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    )),
              )),
          Text('data'),
          Text('data'),
        ],
      ),
    );
  }
}

tap() {}
