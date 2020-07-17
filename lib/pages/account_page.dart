import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/assets/survey_questions.dart';
import 'package:techpointchallenge/model/survey/survey_question.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import 'package:techpointchallenge/services/storage/firebase_storage.dart';
import 'package:techpointchallenge/services/validator.dart';
import 'package:techpointchallenge/widgets/upload_picture_widget.dart';
import '../services/globals.dart' as globals;
import 'dart:html';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {

  GlobalKey<FormState> formKey = GlobalKey();
  bool accountPicHovered = false;
  bool editMode = false;

  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Center(
        child: Consumer<Authentication>(
          builder: (context, auth, child) {
            return Consumer<User>(
              builder: (context, user, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularUploadPic(
                          onNewImageSelected: (file) async {
                            user.photoUrl = await FirebaseStorage.uploadImage(file, "users/" + user.firebaseId.toString());
                            UserFirestore.updateUser(user);
                          },
                          photoUrl: user.photoUrl,
                          radius: 60,
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(user.name ?? "No name"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
                        height: 1,
                        width: MediaQuery.of(context).size.width * .9,
                      ),
                    ),
                    Container(
                      width: globals.useMobileLayout ? MediaQuery.of(context).size.width * .9 :  MediaQuery.of(context).size.width * .5,
                      child: !editMode
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    FlatButton.icon(
                                      textColor: Theme.of(context).textTheme.button.color,
                                      label: Text("Tell us more"),
                                      icon: Icon(MdiIcons.clipboardOutline),
                                      onPressed: () => showDialog(context: context, builder: (context) => SurveyWidget()),
                                    ),
                                    FlatButton.icon(
                                      textColor: Theme.of(context).textTheme.button.color,
                                      label: Text("Edit"),
                                      icon: Icon(MdiIcons.pencil),
                                      onPressed: () => setState(
                                          () => editMode = !editMode),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.email ?? "No email"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.jobTitle ?? "No title"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.bio ?? "No bio",),
                                ),
                              ],
                            )
                          : Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    FlatButton.icon(
                                      textColor: Theme.of(context).textTheme.button.color,
                                      label: Text("Edit"),
                                      icon: Icon(MdiIcons.pencil),
                                      onPressed: () => setState(
                                          () => editMode = !editMode),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  validator: (value) => Validator.validateShortLength(value),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  initialValue: user.name,
                                  decoration: InputDecoration(hintText: "Name"),
                                  onSaved: (value) => setState(() => user.name = value)
                                ),
                                TextFormField(
                                  validator: (value) => Validator.validateLongLength(value),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  initialValue: user.bio,
                                  decoration: InputDecoration(hintText: "About me"),
                                  onSaved: (value) => setState(() => user.bio = value),
                                ),
                                TextFormField(
                                  validator: (value) => Validator.validateShortLength(value),
                                  style: Theme.of(context).textTheme.bodyText2,
                                  initialValue: user.jobTitle,
                                  decoration: InputDecoration(hintText: "Position Title"),
                                  onSaved: (value) => setState(() => user.jobTitle = value),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                    shape: StadiumBorder(),
                                    textColor: Theme.of(context).textTheme.button.color,
                                    child: Text("Submit changes"),
                                    onPressed: () async => await submitForm(user),
                                  ),
                                )
                              ],
                            ),
                          ),
                    ),
                    RaisedButton(
                      onPressed: () async => await auth.signOut(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(80.0)),
                      padding: const EdgeInsets.all(0.0),
                      child: Ink(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              colors: [Color(0xffaa0000), Color(0xffcc0000)]),
                          borderRadius: BorderRadius.all(Radius.circular(80.0)),
                        ),
                        child: Container(
                          constraints: const BoxConstraints(
                              maxWidth: 130.0,
                              minWidth: 88,
                              minHeight: 36), // min sizes for Material buttons
                          alignment: Alignment.center,
                          child: const Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> submitForm(User user) async {
    if(formKey.currentState.validate()){
      formKey.currentState.save();
      await UserFirestore.updateUser(user);
      setState(() {
        editMode = false;
      });
    }
  }

}

class SurveyWidget extends StatefulWidget {
  @override
  _SurveyWidgetState createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {

  int questionIndex = 0;

  HashMap<String, String> surveyResponse = HashMap();

  @override
  Widget build(BuildContext context) {

    List<SurveyQuestion> surveyQuestions = SurveyQuestions.getSurveyQuestions();

    List<Widget> pages = surveyQuestions
      .map((surveyQuestion) {
        return SurveyQuestionWidget(
          surveyQuestion: surveyQuestion,
          addResponse: addResponse,
          surveyResponse: surveyResponse,
        );
    }).toList();

    return Dialog(child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          pages[questionIndex],
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              questionIndex > 0 ? RaisedButton(child: Text("Back"), onPressed:  () => setQuestionIndex(questionIndex - 1)) : Container(),
              questionIndex + 1 < surveyQuestions.length ?
              RaisedButton(child: Text("Next"), onPressed: surveyResponse[surveyQuestions[questionIndex].question] != null ? () {
                setQuestionIndex(questionIndex + 1);
              } : null)
                : RaisedButton(child: Text("Complete"), onPressed: (){},)
            ],
          )
        ],
      ),
    ));

  }

  void addResponse(String question, String answer){
    setState(() {
      surveyResponse[question] = answer;
    });
  }

  void setQuestionIndex(int index){
    setState(() {
      questionIndex = index;
    });
  }

}

class SurveyQuestionWidget extends StatefulWidget {

  final SurveyQuestion surveyQuestion;
  final HashMap<String, String> surveyResponse;
  final Function(String, String) addResponse;

  const SurveyQuestionWidget({Key key, this.surveyQuestion, this.addResponse, this.surveyResponse}) : super(key: key);

  @override
  _SurveyQuestionWidgetState createState() => _SurveyQuestionWidgetState();
}

class _SurveyQuestionWidgetState extends State<SurveyQuestionWidget> {



  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.surveyQuestion.question, style: TextStyle(color: Colors.black),),
        Column(
          children: widget.surveyQuestion.answerOptions
            .map((answer) => FlatButton(
              color: widget.surveyResponse[widget.surveyQuestion.question] == answer ? Colors.green : Colors.white,
              child: Text(answer),
              onPressed: () => widget.addResponse(widget.surveyQuestion.question, answer),))
            .toList(),
        ),
      ],
    );
  }
}



