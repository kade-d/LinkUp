import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techpointchallenge/services/image_uploader.dart';

class CircularUploadPic extends StatefulWidget {

  final Function(File) onNewImageSelected;
  final String photoUrl;
  final double radius;

  const CircularUploadPic({Key key, @required this.onNewImageSelected, @required this.photoUrl, this.radius}) : super(key: key);

  @override
  _CircularUploadPicState createState() => _CircularUploadPicState();
}

class _CircularUploadPicState extends State<CircularUploadPic> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        child: InkWell(
          onTap: () async {
            File file = await ImageUploader.startFilePicker();
            widget.onNewImageSelected(file);
          },
          onHover: (value) {
            setState(() => hovered = value);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: <Widget>[
                CircleAvatar(backgroundImage: NetworkImage(widget.photoUrl ?? "No image"), radius: widget.radius ?? 30,),
                Visibility(
                  visible: hovered,
                  child: Icon(Icons.camera_alt),
                )
              ],
            )),
        )),
    );
  }
}
