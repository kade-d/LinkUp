import 'dart:html';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techpointchallenge/services/image_uploader.dart';

class CircularUploadPic extends StatefulWidget {

  final Function(File) onNewImageSelected;
  final String photoUrl;
  final double radius;
  final bool owner;

  const CircularUploadPic({Key key, @required this.onNewImageSelected, @required this.photoUrl, this.radius, @required this.owner}) : super(key: key);

  @override
  _CircularUploadPicState createState() => _CircularUploadPicState();
}

class _CircularUploadPicState extends State<CircularUploadPic> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.owner ? () async {
            File file = await ImageUploader.startFilePicker();
            widget.onNewImageSelected(file);
          } : null,
          onHover: (value) {
            setState(() => hovered = value);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                  ),
                  child: Material(
                    shape: CircleBorder(),
                    elevation: 3,
                    color: Colors.transparent,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(widget.photoUrl ?? "No image"),
                      radius: widget.radius ?? 30, ),
                  ),
                ),
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

class RectangularUploadPic extends StatefulWidget {

  final Function(File) onNewImageSelected;
  final String photoUrl;
  final bool owner;

  const RectangularUploadPic({Key key, @required this.onNewImageSelected, @required this.photoUrl, @required this.owner}) : super(key: key);

  @override
  RectangularUploadPicState createState() => RectangularUploadPicState();
}

class RectangularUploadPicState extends State<RectangularUploadPic> {

  bool hovered = false;

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return Container(
      child: Material(
        child: InkWell(
          onTap: widget.owner ? () async {
            File file = await ImageUploader.startFilePicker();
            widget.onNewImageSelected(file);
          } : null,
          onHover: (value) {
            setState(() => hovered = value);
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    color: widget.photoUrl == null ? Colors.grey[500] : Colors.transparent,
                    constraints: BoxConstraints(minWidth: size.width * .4),
                    child: Image(image: NetworkImage(widget.photoUrl ?? "No image"), height: size.height * .15, fit: BoxFit.fill,)
                  ),
                ),
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


