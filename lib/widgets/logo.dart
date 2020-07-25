import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Logo extends StatelessWidget {

  final double width;

  const Logo({Key key, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.asset("assets/logo.png", width: width ?? 500,);
  }
}

