import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<int> numbers = [];
  void counterPlus() {
    setState(() {
      numbers.add(numbers.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.red,
          ),
        ),
      ),
      home: const Scaffold(
        backgroundColor: Color(0xfff4eddb),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myTitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class myTitle extends StatelessWidget {
  const myTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Click Count",
      style: TextStyle(fontSize: 30),
    );
  }
}
