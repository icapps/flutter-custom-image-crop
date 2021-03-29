import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final MemoryImage image;

  const ResultScreen({this.image, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        brightness: Brightness.dark,
      ),
      body: Center(
        child: Column(
          children: [
            Spacer(),
            Image(
              image: image,
            ),
            ElevatedButton(
              child: Text('Back'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
