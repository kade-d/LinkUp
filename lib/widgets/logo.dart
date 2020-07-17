import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Logo extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(MdiIcons.homeOutline, color: Colors.black, size: 80,),
        Text("Link Up", style: TextStyle(color: Colors.black),)
      ],
    );
  }


}
