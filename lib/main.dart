import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  runApp(const MyApp());
}

class CenteredRoundedCard extends StatelessWidget {
  final Widget child;

  const CenteredRoundedCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double cardWidth = constraints.maxWidth * 0.96;
          cardWidth = cardWidth > 500 ? 500 : cardWidth;

          return Container(
            width: cardWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Talk Time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentIndex = -1;
  List<List<dynamic>>? listData;
  List<List<dynamic>>? listDataZh;
  int lang = 0; // 0 is english, 1 is chinese

  Future<void> loadData() async {
    final rawData = await rootBundle.loadString("assets/data.csv");
    final rawDataZh = await rootBundle.loadString("assets/data_zh.csv");
    List<List<dynamic>> data = const CsvToListConverter(
      fieldDelimiter: ',', // Change this if you use a different delimiter
      eol: '\n', // Change this if you use a different line ending
    ).convert(rawData);
    List<List<dynamic>> dataZh = const CsvToListConverter(
      fieldDelimiter: ',', // Change this if you use a different delimiter
      eol: '\n', // Change this if you use a different line ending
    ).convert(rawDataZh);
    setState(() {
      currentIndex = Random().nextInt(data.length);
      listData = data;
      listDataZh = dataZh;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    var selectedData = lang == 0 ? listData : listDataZh;
    bool isLoading = selectedData == null;
    var selectedTitle = selectedData?[currentIndex][0];
    var selectedDescription = selectedData?[currentIndex][1];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Talk Time"),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.language),
            onSelected: (value) {
              if (value == 'English') {
                lang = 0;
              } else {
                lang = 1;
              }
              setState(() {
                lang = lang;
              });
              // Handle menu item selection
              // handleMenuSelection(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'English',
                child: Text('English'),
              ),
              PopupMenuItem<String>(
                value: 'Chinese',
                child: Text('中文'),
              ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.waveDots(
                  color: Theme.of(context).colorScheme.primary, size: 100))
          : CenteredRoundedCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    selectedTitle,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedDescription,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentIndex = Random().nextInt(selectedData!.length);
                        });
                      },
                      child: Text(
                        "Next",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
