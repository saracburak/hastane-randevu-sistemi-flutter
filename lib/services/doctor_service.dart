import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DoctorService {
  Future<List<dynamic>> fetchDoctors() async {
    final String response = await rootBundle.loadString('assets/data/doktorlar.json');
    final List<dynamic> data = json.decode(response);
    return data;
  }
}
