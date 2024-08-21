import 'dart:convert';
import 'package:csit998_capstone_g16/models/words.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../utils/colors.dart';
import 'resultScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Translate text into Auslan signs easily.',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2.h),
            Text('Enter the word here:', style: TextStyle(fontSize: 24)),
            SizedBox(height: 2.h),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: lightGreen,
                focusColor: lightGreen,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: lightGreen, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: lightGreen, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: lightGreen, width: 2.0),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 90.w,
              height: 8.h,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    height: 1.2,
                    fontFamily: 'Dubai',
                    fontSize: 13,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () async {
                  Map<String, List<Definition>> results =
                      await searchLocalJson(_messageController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultPage(results: results),
                    ),
                  );
                },
                child: const Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> loadJsonData() async {
    String jsonString =
        await rootBundle.loadString('assets/jsons/words_latest.json');
    return json.decode(jsonString);
  }

  Future<Map<String, List<Definition>>> searchLocalJson(String query) async {
    Map<String, dynamic> jsonData = await loadJsonData();

    Map<String, List<Definition>> results = {};
    jsonData.forEach((key, value) {
      List<Definition> definitions =
          List<Definition>.from(value.map((item) => Definition.fromJson(item)));

      List<Definition> filteredDefinitions = definitions.where((definition) {
        return definition.keywords.any(
            (keyword) => keyword.toLowerCase().contains(query.toLowerCase()));
      }).toList();

      if (filteredDefinitions.isNotEmpty) {
        results[key] = filteredDefinitions;
      }
    });
    return results;
  }
}
