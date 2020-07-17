import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyText extends StatefulWidget {

  final String text;

  const MyText({Key key, @required this.text}) : super(key: key);

  @override
  _MyTextState createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).canvasColor
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(widget.text)
    );
  }
}
