import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techpointchallenge/model/recognition.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/firestore/recognition_firestore.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import 'package:techpointchallenge/widgets/text_field.dart';

class UserRecognitionsWidget extends StatefulWidget {
  final User signedInUser;
  final User viewingUser;

  const UserRecognitionsWidget(
      {Key key, @required this.signedInUser, @required this.viewingUser})
      : super(key: key);

  @override
  _UserRecognitionsWidgetState createState() => _UserRecognitionsWidgetState();
}

class _UserRecognitionsWidgetState extends State<UserRecognitionsWidget> {
  bool addingRecognition = false;

  GlobalKey<FormState> formKey = GlobalKey();
  Recognition recognition = Recognition.fromNothing();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recognition>>(
        future: RecognitionFirestore.getRecognitionsForUser(
            widget.viewingUser.firebaseId),
        builder: (context, snapshot) {
          return GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1.5,
            children: getGridViewChildren(snapshot.data),
          );
        });
  }

  List<Widget> getGridViewChildren(List<Recognition> recognitions) {
    List<Widget> children = List();

    if (recognitions != null) {
      for (Recognition recognition in recognitions) {
        children.add(Container(
          padding: EdgeInsets.all(10),
          child: Material(
            color: Colors.deepPurple,
            borderRadius: BorderRadius.circular(40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(
                    text: recognition.message,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("- " + recognition.fromUserName),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
      }
    }

    if (widget.signedInUser.email != widget.viewingUser.email) {
      children.add(Container(
        padding: EdgeInsets.all(10),
        child: Material(
          borderRadius: BorderRadius.circular(40),
          color: Colors.deepPurple,
          child: addingRecognition
              ? Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(hintText: "Message"),
                          onSaved: (value) => recognition.message = value,
                        ),
                        FlatButton(
                          child: Text("Submit"),
                          onPressed: () async {
                            formKey.currentState.save();
                            recognition.postDate = DateTime.now();
                            recognition.fromUserId = widget.signedInUser.firebaseId;
                            recognition.toUserId = widget.viewingUser.firebaseId;
                            recognition.fromUserName = widget.signedInUser.name;
                            recognition.toUserName = widget.viewingUser.name;
                            await RecognitionFirestore.addRecognition(
                                recognition, widget.viewingUser.firebaseId);
                            setState(() {
                              addingRecognition = false;
                            });
                          },
                        )
                      ],
                    ),
                  ),
                )
              : InkWell(
                  onTap: () {
                    setState(() {
                      addingRecognition = true;
                    });
                  },
                  child: Center(
                      child: Icon(
                    Icons.add,
                    size: 40,
                    color: Colors.grey[200],
                  )),
                ),
        ),
      ));
    }
    return children;
  }
}
