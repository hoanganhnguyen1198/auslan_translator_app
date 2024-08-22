import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LibraryData {
  final List<dynamic> data;

  LibraryData({required this.data});

  factory LibraryData.fromJson(Map<String, dynamic> json) {
    return LibraryData(
      data: json['data'] as List<dynamic>,
    );
  }

  static Future<LibraryData> loadLibraryData() async {
    String jsonString = await rootBundle.loadString('assets/data.json');
    final jsonResponse = json.decode(jsonString);
    return LibraryData.fromJson(jsonResponse);
  }
}
