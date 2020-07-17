import 'package:flutter/cupertino.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/widgets/text_field.dart';

class AboutUserWidget extends StatefulWidget {

  final User user;

  const AboutUserWidget({Key key, @required this.user}) : super(key: key);

  @override
  _AboutUserWidgetState createState() => _AboutUserWidgetState();
}

class _AboutUserWidgetState extends State<AboutUserWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Email"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyText(text: widget.user.email,),
              ),
            ],
          ),
          Row(
            children: [
              Text("Title"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyText(text: widget.user.jobTitle ?? "No title"),
              ),
            ],
          ),
          Row(
            children: [
              Text("About"),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MyText(text: widget.user.bio ?? "No bio"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}