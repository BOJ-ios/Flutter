import 'dart:async';
import 'dart:math';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '로또번호 생성기',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '로또번호 생성기'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _Balls extends StatelessWidget {
  final List<String> data;
  const _Balls({required this.data});
  @override
  Widget build(BuildContext context) {
    List<Widget> balls = data.map((number) {
      return Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }).toList();

    List<Widget> spacedBalls = [];
    for (int i = 0; i < 6; i++) {
      spacedBalls.add(balls[i]);
      if (i != balls.length - 1) {
        spacedBalls.add(const SizedBox(width: 5));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...spacedBalls,
      ],
    );
  }
}

class _BarChart extends StatelessWidget {
  final List<int> data;
  const _BarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    const double maxHeight = 150.0; // maximum height of the bar
    const double barWidth = 6.0; // width of each bar
    const double barSpacing = 2.0; // space between each bar
    int maxDataValue = data.reduce(max);
    List<Widget> bars = data.map((value) {
      double barHeight = (value.toDouble() / maxDataValue) * maxHeight;
      return Container(
        width: barWidth,
        height: barHeight,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(5.0),
        ),
      );
    }).toList();

    List<Widget> spacedBars = [];
    for (int i = 0; i < bars.length; i++) {
      spacedBars.add(bars[i]);
      if (i != bars.length - 1) {
        spacedBars.add(const SizedBox(width: barSpacing));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...spacedBars,
      ],
    );
  }
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _numbers = ['?', '?', '?', '?', '?', '?'];
  List<int> numbers = [];
  int min = 0;
  int max = 0;
  double mean = 0;
  double sd = 0.0;
  int count = 0;
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.txt');
  }

  Future<File> writeFile(String txt) async {
    final file = await _localFile;
    return file.writeAsString(txt);
  }

  Future<List<int>> readIntListFromFile() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      List<String> parts = contents.split(',');
      List<int> numbers = parts.map((part) => int.parse(part)).toList();

      return numbers;
    } catch (e) {
      if (numbers.isEmpty) {
        for (int i = 0; i < 45; i++) {
          numbers.add(0);
        }
      }
      return numbers;
    }
  }

  Timer? _timer;
  void calculateSD() {
    double sum = 0.0;
    double squaredDiffSum = 0.0;
    min = numbers.reduce((a, b) => a < b ? a : b);
    max = numbers.reduce((a, b) => a > b ? a : b);
    for (int i = 0; i < 45; i++) {
      sum += numbers[i];
    }

    mean = sum / 45;

    for (int i = 0; i < 45; i++) {
      squaredDiffSum += pow(numbers[i] - mean, 2);
    }

    double variance = squaredDiffSum / 45;
    double standardDeviation = sqrt(variance);
    sd = standardDeviation;
  }

  void _createRandomKeep() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      _createRandom();
      count++;
    });
  }

  void _stopCreatingRandomNumbers() {
    _timer?.cancel();
    setState(() {
      _timer = null;
    });
  }

  void _createRandom() async {
    numbers = await readIntListFromFile();
    setState(() {
      _numbers = [];
      while (_numbers.length < 6) {
        int seed = DateTime.now().millisecondsSinceEpoch +
            (Random().nextInt(4294967296) ~/
                Random().nextInt(4294967296) ~/
                pi);
        var intValue = Random(seed).nextInt(45) + 1;
        if (!_numbers.contains("$intValue")) {
          _numbers.add("$intValue");
        }
      }
      _numbers.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    });
    for (int i = 0; i < 6; i++) {
      int index = int.parse(_numbers[i]);
      numbers[index - 1]++;
    }
    calculateSD();
    String output = "";
    for (int i = 0; i < 45; i++) {
      output += "$numbers[i]";
      if (i != 44) {
        output += ",";
      }
    }
    await writeFile(output);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Flexible(
            flex: 3,
            child: Text(
              '오늘의 로또 번호는!!!!!!',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            flex: 1,
            child: Center(
              child: _Balls(data: _numbers),
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Visibility(
                  visible: numbers.isNotEmpty,
                  child: _BarChart(data: numbers),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '1~45까지 출현 빈도 그래프',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    )
                  ],
                ),
              ],
            ),
          ),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '무한생성',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _timer == null
                        ? _createRandomKeep()
                        : _stopCreatingRandomNumbers();
                  },
                  icon: Icon(
                    _timer == null ? Icons.repeat : Icons.stop_circle_outlined,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text(
                          "표준편차",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          sd.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "최대빈도",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "$min",
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text(
                          "최대빈도",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "$max",
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '생성수 : ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "$count",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
