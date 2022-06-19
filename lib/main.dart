import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fisrt_flutter/Screens/favourite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const url = 'https://api.chucknorris.io/jokes/random';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(title: 'Chuck Norris'),
        '/favourite': (context) => Favourite_Page(),
      },
    );
  }
}

Future<String> fetchJoke() async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return Joke.fromJson(jsonDecode(response.body)).value;
  } else {
    throw Exception('Failed to load album');
  }
}

class Joke {
  final String id;
  final String value;

  const Joke({
    required this.id,
    required this.value,
  });

  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'],
      value: json['value'],
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<String> futureJoke;
  final Stream<QuerySnapshot> Jokes=
      FirebaseFirestore.instance.collection('Jokes').snapshots();
  @override
  void initState() {
    super.initState();
    futureJoke = fetchJoke();
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference Jokes = FirebaseFirestore.instance.collection('Jokes');
    String? joke_text = "null";
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          GestureDetector(
            onTap: () { Navigator.pushNamed(context, '/favourite'); },
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
              child :Icon(
              Icons.favorite,
            ),
            )
          )
        ],
      ),
      body: Center(
        child: Padding(padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Push the button to get a Chuck Norris joke',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  backgroundColor: Colors.black,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              FutureBuilder<String>(
                  future: fetchJoke(),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("No joke");
                    }
                    else if (snapshot.hasData) {
                      joke_text = snapshot.data;
                      return Expanded(child:
                      Container(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text('${snapshot.data}',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),),),);
                    }
                    else {
                      return const Text("No joke");
                    }
                  }
                  ),
            ],
          ),
        ),
      ),

      floatingActionButton:Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Padding(padding: EdgeInsets.fromLTRB(30,0,0,0),
              child: FloatingActionButton(
              onPressed: () => setState((){
                Jokes.add({'joke_text': joke_text}).catchError((error) => print('Faild'));
              }),
              tooltip: 'Favorite',
              child: const Icon(Icons.add),
            ),),
            FloatingActionButton(
              onPressed: () => setState((){
              futureJoke = fetchJoke();
              }),
              tooltip: 'Refresh',
              child: const Icon(Icons.refresh),
            ),
        ]

      ),
    );
  }
}
