import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'appointments_page.dart'; 

class BookAppointmentPage extends StatefulWidget {
  @override
  _BookAppointmentPageState createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  List<Map<String, dynamic>> doctors = [];
  List<Map<String, dynamic>> appointments = [];
  String? selectedDoctorId;
  String? patientName;
  String? patientSurname;
  String? patientTc;
  String? patientPhone;
  DateTime? selectedDate;
  String? selectedTime;

  final _formKey = GlobalKey<FormState>();
  final List<String> availableTimes = List.generate(
    9,
    (index) => DateFormat('HH:mm').format(DateTime(2024, 1, 1, 9 + index, 0)),
  ); // Available times from 09:00 to 17:00

  @override
  void initState() {
    super.initState();
    _loadDoctors();
    _loadAppointments();
  }

  Future<void> _loadDoctors() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedDoctors = prefs.getString('doctors');
    if (savedDoctors != null) {
      setState(() {
        doctors = List<Map<String, dynamic>>.from(json.decode(savedDoctors));
      });
    } else {
      try {
        final String response =
            await rootBundle.loadString('assets/data/doktorlar.json');
        final List<dynamic> data = json.decode(response);
        setState(() {
          doctors = data.cast<Map<String, dynamic>>();
        });
        await prefs.setString('doctors', json.encode(doctors));
      } catch (e) {
        print("Error loading doctors: $e");
      }
    }
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

  Future<void> _saveAppointment(Map<String, dynamic> appointment) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedAppointments = prefs.getString('appointments');
    List<Map<String, dynamic>> updatedAppointments = savedAppointments != null
        ? List<Map<String, dynamic>>.from(json.decode(savedAppointments))
        : [];
    updatedAppointments.add(appointment);
    await prefs.setString('appointments', json.encode(updatedAppointments));
    _loadAppointments();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool isDayFullyBooked(DateTime date) {
    final bookedTimesOnDate = appointments
        .where((app) =>
            app['doctorId'] == selectedDoctorId &&
            isSameDay(DateTime.parse(app['date']), date))
        .length;
    return bookedTimesOnDate >= 9; 
  }

  bool isTimeBooked(DateTime date, String time) {
    return appointments.any((app) =>
        app['doctorId'] == selectedDoctorId &&
        isSameDay(DateTime.parse(app['date']), date) &&
        app['time'] == time);
  }

  List<String> getAvailableTimes(DateTime date) {
    return availableTimes;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = selectedDate ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != selectedDate) {
      if (!isDayFullyBooked(picked)) {
        setState(() {
          selectedDate = picked;
          selectedTime = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Bu gün için tüm randevular dolu.'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorOptions = doctors.map<DropdownMenuItem<String>>((doctor) {
      return DropdownMenuItem<String>(
        value: doctor['id'].toString(),
        child: Text('${doctor['ad']} ${doctor['soyad']} (${doctor['bolum']})'),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Randevu Al'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Doktor Seçin'),
                  value: selectedDoctorId,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDoctorId = newValue;
                      selectedDate = null;
                      selectedTime = null;
                    });
                  },
                  items: doctorOptions,
                  validator: (value) =>
                      value == null ? 'Lütfen bir doktor seçin' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Adınız'),
                  onChanged: (value) {
                    patientName = value;
                  },
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Adınızı giriniz' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Soyadınız'),
                  onChanged: (value) {
                    patientSurname = value;
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Soyadınızı giriniz'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'T.C. Kimlik No'),
                  onChanged: (value) {
                    patientTc = value;
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'T.C. Kimlik No giriniz'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Telefon'),
                  onChanged: (value) {
                    patientPhone = value;
                  },
                  validator: (value) => value == null || value.isEmpty
                      ? 'Telefon numarası giriniz'
                      : null,
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Tarih',
                        hintText: selectedDate == null
                            ? 'Tarih seçiniz'
                            : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      ),
                      validator: (value) =>
                          selectedDate == null ? 'Tarih seçiniz' : null,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                if (selectedDate != null)
                  Wrap(
                    spacing: 8.0,
                    children:
                        getAvailableTimes(selectedDate!).map<Widget>((time) {
                      final isBooked = isTimeBooked(selectedDate!, time);
                      return ChoiceChip(
                        label: Text(time),
                        selected: selectedTime == time,
                        onSelected: isBooked
                            ? null
                            : (selected) {
                                setState(() {
                                  selectedTime = time;
                                });
                              },
                        selectedColor: Colors.blue,
                        disabledColor: Colors.grey,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isBooked
                              ? Colors.black.withOpacity(0.5)
                              : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final appointment = {
                        'doctorId': selectedDoctorId,
                        'name': patientName,
                        'surname': patientSurname,
                        'tc': patientTc,
                        'phone': patientPhone,
                        'date': DateFormat('yyyy-MM-dd').format(selectedDate!),
                        'time': selectedTime,
                      };
                      _saveAppointment(appointment);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentsPage(),
                        ),
                      );
                    }
                  },
                  child: Text('Randevu Al'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
