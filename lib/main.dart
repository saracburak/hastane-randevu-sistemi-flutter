import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/doctors_page.dart';
import 'pages/patients_page.dart';
import 'pages/appointments_page.dart';
import 'pages/book_appointment_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hastane Randevu Sistemi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Montserrat',
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => HomePage());
          case '/doctors':
            return MaterialPageRoute(builder: (context) => DoctorsPage());
          case '/patients':
            return MaterialPageRoute(builder: (context) => PatientsPage());
          case '/appointments':
            return MaterialPageRoute(builder: (context) => AppointmentsPage());
          case '/book-appointment':
            return MaterialPageRoute(
                builder: (context) => BookAppointmentPage());
          default:
            return MaterialPageRoute(builder: (context) => HomePage());
        }
      },
    );
  }
}
