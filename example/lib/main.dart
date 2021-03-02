import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  final controller = CustomImageCropController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Column(children: [
                          Expanded(child: Container()),
                          Image(
                            image: image,
                          ),
                          RaisedButton(
                            child: Text('Back'),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(child: Container()),
                        ]),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
