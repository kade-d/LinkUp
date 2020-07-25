import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/widgets/text_field.dart';

class AboutUserWidget extends StatefulWidget {

  final User viewingUser;
  final User signedInUser;

  const AboutUserWidget({Key key, this.viewingUser, this.signedInUser,}) : super(key: key);

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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyText(text: widget.viewingUser.email,),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyText(text: widget.viewingUser.jobTitle ?? "No title"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyText(text: widget.viewingUser.bio ?? "No bio"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: getCommonInterests(),
              ),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> getCommonInterests(){

    List<Widget> children = List();

    HashMap<String, String> viewerResponses = widget.viewingUser.surveyResponses;
    HashMap<String, String> signedInResponses = widget.signedInUser.surveyResponses;

    if(widget.viewingUser.firebaseId != widget.signedInUser.firebaseId){
      for(String question in viewerResponses.keys){
        if(viewerResponses[question] == signedInResponses[question] && viewerResponses[question] != null){

          String interestString;

          switch(question){
            case "What is your favorite number?":
              interestString = "both have " + viewerResponses[question] + " as your favorite number!";
              break;
            case "What is your favorite color?":
              interestString = "both have " + viewerResponses[question] + " as your favorite color!";
              break;
            default:
              interestString = "both answered " + viewerResponses[question] + " to " + question;
          }

          children.add(
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("You " + interestString),
            )
          );
        }
      }
    }

    return children;

  }

}