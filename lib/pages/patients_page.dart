import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientsPage extends StatefulWidget {
  @override
  _PatientsPageState createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  List<Map<String, dynamic>> patients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAppointments = prefs.getString('appointments');
    if (savedAppointments != null) {
      final List<Map<String, dynamic>> appointments =
          List<Map<String, dynamic>>.from(json.decode(savedAppointments));
      setState(() {
        patients = appointments.map((app) {
          return {
            'name': app['name'],
            'surname': app['surname'],
            'tc': app['tc'],
            'phone': app['phone'],
          };
        }).toList();
        filteredPatients = patients; // Initialize with all patients
      });
    }
  }

  void _filterPatients(String query) {
    setState(() {
      searchQuery = query;
      filteredPatients = patients.where((patient) {
        final name = '${patient['name']} ${patient['surname']}';
        return name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasta Bilgileri'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Hasta Ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterPatients,
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true, // En son eklenen hasta en üstte görünsün
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      '${patient['name']} ${patient['surname']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('T.C. Kimlik No: ${patient['tc']}'),
                        Text('Telefon: ${patient['phone']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
