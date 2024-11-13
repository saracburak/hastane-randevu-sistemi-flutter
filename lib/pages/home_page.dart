import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  Future<List<dynamic>> fetchDoktorlar() async {
    final String response =
        await rootBundle.loadString('assets/data/doktorlar.json');
    final List<dynamic> data = json.decode(response);
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hastane Randevu Sistemi',
          style: TextStyle(fontFamily: 'Montserrat', fontSize: 20),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Giriş yapma işlemi
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            child:
                const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              // Üye olma işlemi
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
            ),
            child: const Text('Üye Ol', style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            ListTile(
              title: const Text('Doktorlar',
                  style: TextStyle(fontFamily: 'Montserrat')),
              onTap: () {
                Navigator.pushNamed(context, '/doctors');
              },
            ),
            ListTile(
              title: const Text('Hastalar',
                  style: TextStyle(fontFamily: 'Montserrat')),
              onTap: () {
                Navigator.pushNamed(context, '/patients');
              },
            ),
            ListTile(
              title: const Text('Randevular',
                  style: TextStyle(fontFamily: 'Montserrat')),
              onTap: () {
                Navigator.pushNamed(context, '/appointments');
              },
            ),
            ListTile(
              title: const Text('Randevu Al',
                  style: TextStyle(fontFamily: 'Montserrat')),
              onTap: () {
                Navigator.pushNamed(context, '/book-appointment');
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 180.0,
              child: CarouselSlider(
                options: CarouselOptions(
                  autoPlay: true,
                  viewportFraction: 1.0,
                  aspectRatio: 16 / 9,
                ),
                items: <String>[
                  'assets/images/hospital_1.jpg',
                  'assets/images/hospital_2.jpg',
                  'assets/images/hospital_3.jpg',
                ].map((imagePath) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Hastanemize Hoşgeldiniz',
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Montserrat',
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              width: double.infinity,
              height: 350.0,
              child: FutureBuilder<List<dynamic>>(
                future: fetchDoktorlar(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Veri yüklenirken bir hata oluştu.'));
                  } else {
                    return CarouselSlider(
                      options: CarouselOptions(
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        viewportFraction: 0.8,
                        aspectRatio: 1.2,
                        enlargeCenterPage: true,
                      ),
                      items: snapshot.data!.map((doctor) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: double.infinity,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(15.0),
                                        topRight: Radius.circular(15.0),
                                      ),
                                      child: Image.asset(
                                        doctor['resim'],
                                        fit: BoxFit.fitHeight,
                                        width: double.infinity,
                                        height: 220.0,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            '${doctor['ad']} ${doctor['soyad']}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            doctor['bolum'],
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text(
                                            doctor['aciklama'],
                                            style: const TextStyle(
                                              fontSize: 12.0,
                                              fontFamily: 'Montserrat',
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
