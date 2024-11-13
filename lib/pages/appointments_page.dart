import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Tarih formatı için gerekli

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> doctors = [];

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _loadDoctors();
  }

  Future<void> _loadAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAppointments = prefs.getString('appointments');
    if (savedAppointments != null) {
      setState(() {
        appointments =
            List<Map<String, dynamic>>.from(json.decode(savedAppointments));
      });
    }
  }

  Future<void> _loadDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedDoctors = prefs.getString('doctors');
    if (savedDoctors != null) {
      setState(() {
        doctors = List<Map<String, dynamic>>.from(json.decode(savedDoctors));
      });
    }
  }

  Map<String, dynamic> _getDoctorDetails(String doctorId) {
    return doctors.firstWhere(
      (doc) => doc['id'].toString() == doctorId,
      orElse: () => {'ad': 'Bilinmiyor', 'soyad': '', 'bolum': 'Bilinmiyor'},
    );
  }

  String _formatDate(String date) {
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Geçersiz Tarih';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Randevularım'),
      ),
      body: appointments.isEmpty
          ? Center(child: Text('Henüz randevunuz bulunmuyor.'))
          : ListView.builder(
              reverse: true, // Listeyi ters çevirir
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appointment = appointments[index];
                final doctor = _getDoctorDetails(appointment['doctorId']);
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medical_services, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              '${doctor['ad']} ${doctor['soyad']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueAccent, // Ad ve soyadı koyu renk
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bölüm: ${doctor['bolum']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tarih: ${_formatDate(appointment['date'])}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          'Saat: ${appointment['time']}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Hasta Bilgileri:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Adı: ${appointment['name']}'),
                        Text('Soyadı: ${appointment['surname']}'),
                        Text('T.C. Kimlik No: ${appointment['tc']}'),
                        Text('Telefon: ${appointment['phone']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
