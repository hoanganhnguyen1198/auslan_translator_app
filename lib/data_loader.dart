import 'dart:convert';
import 'package:flutter/services.dart';

class DataLoader {
  Future<List<Map<String, dynamic>>> loadJsonData() async {
    // 读取JSON文件
    String jsonString = await rootBundle.loadString('assets/data.json');
    // 将JSON解析为动态类型的列表
    final List<dynamic> jsonData = json.decode(jsonString);

    // 调试时打印数据结构
    print(jsonData);

    // 返回类型转换后的数据
    return List<Map<String, dynamic>>.from(jsonData);
  }
}
