import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
class EnhanceScreen extends StatefulWidget {
  final File image;
  EnhanceScreen(this.image, {super.key});

  @override
  State<EnhanceScreen> createState() => _RecognizerScreenState();
}

class _RecognizerScreenState extends State<EnhanceScreen> {
  late img.Image inputImage;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inputImage = img.decodeImage(widget.image.readAsBytesSync())!;
    enhanceImage();
  }

  enhanceImage() {
    img.Image temp = img.decodeImage(widget.image.readAsBytesSync())!;
    inputImage = img.adjustColor(temp, brightness: brightness);
    inputImage = img.contrast(inputImage, contrast: contrast);
    setState(() {
      inputImage;
    });
  }

  double contrast = 150;
  double brightness = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          'Enhance',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          InkWell(
            onTap: () async {
              final result =
                await ImageGallerySaverPlus.saveImage(Uint8List.fromList(img.encodePng(inputImage)));              print(result);
              SnackBar sn = const SnackBar(content: Text('Saved'));
              ScaffoldMessenger.of(context).showSnackBar(sn);
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.save_alt),
            ),
          ),
          InkWell(
            onTap: () async {
              final editedImage = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageFilters(
                    image: Uint8List.fromList(img.encodePng(inputImage)), // <-- Uint8List of image
                  ),
                ),
              );
              inputImage = img.decodeImage(editedImage)!;
              setState(() {
                inputImage;
              });
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.filter),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(10),color: Colors.grey,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/1.5,
                    margin: const EdgeInsets.all(15),
                    child: Image.memory(
                        Uint8List.fromList(img.encodeBmp(inputImage)))),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20,right: 10),
                child: Row(
                  children: [
                    const Icon(Icons.contrast,size: 30,color: Colors.blueAccent,),
                    Expanded(
                      child: Slider(value: contrast, onChanged: (v){
                        contrast = v;
                        enhanceImage();
                        setState(() {
                          contrast;
                        });
                      },min: 80,max: 200,divisions: 12,
                        label: contrast.toStringAsFixed(2),activeColor: Colors.blueAccent,),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20,right: 10),
                child: Row(
                  children: [
                    const Icon(Icons.brightness_5,size: 30,color: Colors.blueAccent,),
                    Expanded(
                      child: Slider(value: brightness, onChanged: (v){
                        brightness = v;
                        enhanceImage();
                        setState(() {
                          brightness;
                        });
                      },min: 1,max: 10,divisions: 10,
                        label: brightness.toStringAsFixed(2),activeColor: Colors.blueAccent,),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
