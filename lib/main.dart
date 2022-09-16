import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<Giphy> futureImage;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureImage = fetchImage('cats');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC8E2F7),
      appBar: AppBar(
        title: const Text('Search Gifs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Enter you category',
                suffixIcon: IconButton(
                  onPressed: () {
                    controller.clear();
                  },
                  icon: const Icon(Icons.close, color: Colors.blue),
                ),
              ),
              onSubmitted: (String text) {
                setState(() {});
                futureImage = fetchImage(text);
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: FutureBuilder<Giphy>(
                  future: futureImage,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Data> items = snapshot.data!.data!;
                      List<ClipRRect> images = [];
                      for (int i = 0; i < items.length; i++) {
                        final image = ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            items[i].images!.original!.url!,
                            fit: BoxFit.cover,
                          ),
                        );
                        images.add(image);
                      }
                      return GridView(
                          scrollDirection: Axis.vertical,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 3 / 2.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10),
                          children: images);
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const CircularProgressIndicator();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Giphy> fetchImage(String textStr) async {
  final response = await http.get(Uri.parse(
      'https://api.giphy.com/v1/gifs/search?api_key=$secretKey&q=$textStr&limit=$number&offset=0&rating=g&lang=en'));

  if (response.statusCode == 200) {
    return Giphy.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load gifs');
  }
}

const secretKey = "1acxOvY44is3fNujCIHsllhgxvlpbtHB";
const number = 12;

class Giphy {
  List<Data>? data;
  Giphy({this.data});

  Giphy.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((i) {
        data!.add(Data.fromJson(i));
      });
    }
  }
}

class Data {
  Images? images;
  Data({this.images});
  Data.fromJson(Map<String, dynamic> json) {
    images = json['images'] != null ? Images.fromJson(json['images']) : null;
  }
}

class Images {
  Original? original;
  Images({this.original});
  Images.fromJson(Map<String, dynamic> json) {
    original =
        json['original'] != null ? Original.fromJson(json['original']) : null;
  }
}

class Original {
  String? url;
  Original({this.url});
  Original.fromJson(Map<String, dynamic> json) {
    url = json['url'];
  }
}
