import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:example/resultScreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Custom crop example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CustomImageCropController controller;

  @override
  void initState() {
    controller = CustomImageCropController();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        brightness: Brightness.dark,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomImageCrop(
              cropController: controller,
              image: AssetImage('assets/test.png'),
            ),
          ),
          Row(
            children: [
              IconButton(icon: Icon(Icons.refresh), onPressed: controller.reset),
              IconButton(icon: Icon(Icons.zoom_in), onPressed: () => controller.addTransition(CropImageData(scale: 1.5))),
              IconButton(icon: Icon(Icons.zoom_out), onPressed: () => controller.addTransition(CropImageData(scale: 0.75))),
              IconButton(icon: Icon(Icons.rotate_left), onPressed: () => controller.addTransition(CropImageData(angle: -pi / 4))),
              IconButton(icon: Icon(Icons.rotate_right), onPressed: () => controller.addTransition(CropImageData(angle: pi / 4))),
              IconButton(
                icon: Icon(Icons.crop),
                onPressed: () async {
                  final image = await controller.onCropImage();
                  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResultScreen(image: image)));
                },
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
