// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers
import 'package:challenge/screens/listview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:challenge/api/firebase_api.dart';
import 'package:challenge/widget/button_widget.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  CollectionReference reports =
      FirebaseFirestore.instance.collection('reports');

  UploadTask? task;
  File? imageURI;
  final ImagePicker _picker = ImagePicker();
  var Latitude;
  var Longitude;
  List<XFile> _imageList = [];

  Future selectFile() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      setState(() {
        _imageList = images!;
      });
    } catch (e) {
      print(e);
    }
  }

  void determinePosition() async {
    var position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position);
    setState(() {
      Latitude = position.latitude;
      Longitude = position.longitude;
    });
  }

  void initState() {
    // TODO: implement initState
    super.initState();
    determinePosition();
  }

  Future _uploadReport(BuildContext context) async {
    if (_imageList.length == 0) return;

    final _id = DateTime.now().millisecondsSinceEpoch;
    var _imageURL = [];
    for (var i = 0; i < _imageList.length; i++) {
      var file = File(_imageList[i].path);
      final fileName = basename(file.path);
      final destination = '$_id/$fileName';
      task = FirebaseApi.uploadFile(destination, file);

      if (task == null) return;

      final snapshot = await task!.whenComplete(() {});
      final urlDownload = await snapshot.ref.getDownloadURL();
      _imageURL.add(urlDownload);
    }

    reports
        .add({
          "address": "180 Cao Thắng, Q.10, TP.HCM",
          "optional": "Room 8, Floor 5",
          "imagesURL": _imageURL,
          "details": "",
          "lat": Latitude,
          "long": Longitude,
          "time": _id,
          "id": _id,
          "logs": [],
          "resolve": false
        })
        .then((value) => {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ListViewPage()),
              // )
            })
        .catchError((onError) => {print('Create report failed!!!')});
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _moreDetials = TextEditingController();
    Size size = MediaQuery.of(context).size;
    print(size.width);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Child Abusing Report',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255), fontSize: 24)),
        backgroundColor: Color(0xff219653),
        bottomOpacity: 0.0,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(33),
          child: Column(children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: prefer_const_constructors
                Icon(
                  Icons.my_location,
                  color: Colors.black,
                  size: 24.0,
                  semanticLabel: 'Text to announce in accessibility modes',
                ),
                Container(
                  child: const Padding(padding: EdgeInsets.only(left: 10)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.2),
                    Text("Address", style: TextStyle(fontSize: 16)),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Text('180 Cao Thắng, Q.10, TP.HCM'),
                  ],
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: prefer_const_constructors
                Icon(
                  Icons.my_location,
                  color: Colors.black,
                  size: 24.0,
                ),
                Container(
                  child: const Padding(padding: EdgeInsets.only(left: 10)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.2),
                    Text("Room, floor,...(Optional)",
                        style: TextStyle(fontSize: 16)),
                    SizedBox(
                      height: size.height * 0.03,
                    ),
                    Text('Room 8, Floor 5'),
                  ],
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: prefer_const_constructors
                Icon(
                  Icons.description,
                  color: Colors.black,
                  size: 24.0,
                ),
                Container(
                  child: const Padding(padding: EdgeInsets.only(left: 10)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    SizedBox(height: 2.2),
                    Text("Envidences (Videos, photos, audios)",
                        style: TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: prefer_const_constructors
                Container(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(85, 85),
                        primary: Color(0xffE5E5E5),
                        onPrimary: Color.fromARGB(255, 0, 0, 0),
                      ),
                      onPressed: () => {selectFile()},
                      child: Icon(Icons.add)),
                ),
                Row(
                  children: [
                    _imageList.length == 0
                        ? Text("")
                        : Row(children: <Widget>[
                            for (var i = 0; i < _imageList.length; i++)
                              Image.file(File(_imageList[i].path), height: 85)
                          ])
                  ],
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ignore: prefer_const_constructors
                Icon(
                  Icons.edit,
                  color: Colors.black,
                  size: 24.0,
                ),
                Container(
                  child: const Padding(padding: EdgeInsets.only(left: 10)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 2.2),
                    Text("More details", style: TextStyle(fontSize: 16)),
                  ],
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            TextFormField(
              controller: _moreDetials,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                  // ignore: unnecessary_const
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 60.0, horizontal: 5.0),
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            Container(
                child: Text(
                    'BY SUBMITTING THE REPORT, I HEREBY CONFIRM THAT THE ABOVE INFORMATION IS TRUE AND CORRECT',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            SizedBox(
              height: size.height * 0.03,
            ),
            Container(
              // width: 340.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xff219653),
                    onPrimary: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.all(8.0),
                  ),
                  onPressed: () {
                    _uploadReport(context);
                  },
                  child: Align(
                    alignment: Alignment.center,
                    child: Text("REPORT",
                        style: TextStyle(fontSize: 20.0),
                        textAlign: TextAlign.center),
                  )),
            )
          ]),
        ),
      ),
    );
  }
}
