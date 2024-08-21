import 'dart:convert';
import 'package:flutter/services.dart';

class DataLoader {
  Future<List<Map<String, dynamic>>> loadJsonData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    final jsonData = json.decode(jsonString);
    return List<Map<String, dynamic>>.from(jsonData['data']);
  }
}
