import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:notes_app_hive/form_note.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory pathApplication = await path.getApplicationDocumentsDirectory();
  Hive.init(pathApplication.path);
  await Hive.openBox('notes');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.blue)),
      darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(),
          appBarTheme: const AppBarTheme(backgroundColor: Colors.black)),
      // home: const TestQRScanner(),
      home: const MyHomePage(title: 'Notes'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List data = [];
  final box = Hive.box('notes');
  Future<void> getNotes() async {
    try {
      setState(() {
        data = box.keys.map((e) => box.get(e)).toList();
        if (kDebugMode) {
          print(data);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    box.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(spacing: 10, runSpacing: 10, children: [
          for (int i = 0; i < data.length; i++) noteCard(data[i])
        ]),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FormNote(callback: getNotes)));
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget noteCard(item) => Material(
        color: cardsColor[Random().nextInt(cardsColor.length)],
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => FormNote(
                        index: data.indexOf(item), callback: getNotes)));
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
              padding: const EdgeInsets.all(8.0),
              width: MediaQuery.of(context).size.width * 0.5 - 20 - 5,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'],
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4.0),
                    Text(item['content'],
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87)),
                    const SizedBox(height: 8.0),
                    Text(item['created_at'],
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black38)),
                  ])),
        ),
      );
}

List<Color> cardsColor = [
  Colors.blue.shade100,
  Colors.red.shade100,
  Colors.pink.shade100,
  Colors.orange.shade100,
  Colors.yellow.shade100,
  Colors.green.shade100,
  Colors.blue.shade100,
  Colors.blueGrey.shade100,
];
