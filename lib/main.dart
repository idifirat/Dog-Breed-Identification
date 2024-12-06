import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'classifier.dart';

void main() {
  runApp(
    MaterialApp(
      home: Home(),
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.lightBlue[800],
        hintColor: Colors.cyan[600],
      ),
    ),
  );
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Classifier classifier = Classifier();
  final picker = ImagePicker();

  String dogBreed = "";
  String dogProb = "";
  File? image;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            height: size.height * 0.4,
            width: size.width,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: image == null
                      ? AssetImage("assets/bg_image.jpg") as ImageProvider
                      : FileImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            height: size.height * 0.65,
            width: size.width,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(36.0),
                  topRight: Radius.circular(36.0),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 40.0),
                  const Text(
                    "Dog Breed Identification",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Text(
                    dogBreed == ""
                        ? "Please select an image."
                        : "$dogProb% $dogBreed",
                    style: const TextStyle(
                      fontSize: 20.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.camera,
                                maxHeight: 224,
                                maxWidth: 224,
                                imageQuality: 100,
                              );
                              if (pickedFile != null) {
                                File selectedImage = File(pickedFile.path);
                                final outputs = await classifier
                                    .classifyImage(selectedImage);

                                setState(() {
                                  image = selectedImage;
                                  dogBreed = outputs[0];
                                  dogProb =
                                      (outputs[1] * 100).toStringAsFixed(2);
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                width: 2.0,
                                color: Colors.orange,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 35,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Take Photo",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxHeight: 224,
                                maxWidth: 224,
                                imageQuality: 100,
                              );
                              if (pickedFile != null) {
                                File selectedImage = File(pickedFile.path);
                                final outputs = await classifier
                                    .classifyImage(selectedImage);

                                setState(() {
                                  image = selectedImage;
                                  dogBreed = outputs[0];
                                  dogProb =
                                      (outputs[1] * 100).toStringAsFixed(2);
                                });
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                width: 2.0,
                                color: Colors.blue,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: const Icon(
                              Icons.photo,
                              size: 35,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Gallery",
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
