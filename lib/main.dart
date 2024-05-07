import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doa Doa Harian',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController();
  bool isSearchVisible = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  Future<List<dynamic>> fetchDoaList() async {
    var response =
        await http.get(Uri.parse('https://doa-doa-api-ahmadramadhan.fly.dev/api'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  void toggleSearchVisibility() {
    setState(() {
      isSearchVisible = !isSearchVisible;
      if (isSearchVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Doa Doa Harian',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[900], // Warna navbar hijau tua
        elevation: 20, // Menambahkan bayangan pada navbar
        actions: [
          IconButton(
            onPressed: toggleSearchVisibility,
            icon: Icon(Icons.search),
            color: Colors.white, // Ubah warna ikon menjadi putih
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            height: isSearchVisible ? 60.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: AppBar(
              backgroundColor: Colors.transparent, // Mengatur latar belakang menjadi transparan
              elevation: 0.0, // Menghilangkan bayangan
              flexibleSpace: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Cari doa...',
                            contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      onPressed: toggleSearchVisibility,
                      icon: Icon(Icons.close),
                      color: Colors.red, // Ubah warna ikon menjadi merah
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('img/background.jpg'), // Ganti dengan path gambar Anda
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: FutureBuilder<List<dynamic>>(
                  future: fetchDoaList(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Card(
                              elevation: 4, // Menambahkan bayangan pada card
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.data![index]['doa'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    SizedBox(height: 8.0), // Jarak antara doa dan ayat
                                    Text(
                                      '${snapshot.data![index]['ayat']}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center, // Teks ayat ditengah
                                    ),
                                    SizedBox(height: 4.0), // Jarak antara ayat dan latin
                                    Text(
                                      'Latin: ${snapshot.data![index]['latin']}',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center, // Teks latin ditengah
                                    ),
                                    SizedBox(height: 4.0), // Jarak antara latin dan artinya
                                    Text(
                                      'Artinya: "${snapshot.data![index]['artinya']}"',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center, // Teks artinya ditengah
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
