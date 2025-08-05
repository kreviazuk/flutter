import 'package:flutter/material.dart';

class FlutterLearning extends StatefulWidget {
  const FlutterLearning({super.key});

  @override
  State<FlutterLearning> createState() => _FlutterLearningState();
}

class _FlutterLearningState extends State<FlutterLearning> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Learning'),
      ),
      body: Center(
          child: Container(
        child: Container(
          child: Column(
            children: [
              Text('Flutter Learning'),
              Text('Flutter Learning'),
            ],
          ),
        ),
      )),
    );
  }
}
