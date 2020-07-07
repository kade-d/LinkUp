import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/pages/auth_page.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import '../services/globals.dart' as globals;

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
                        InkWell(
                          onTap: () => print("tapped"),
                          onHover: (value) {
                            setState(() => accountPicHovered = value);
                          },
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: <Widget>[
                                  Material(
                                    shape: CircleBorder(),
                                    child: Image.network(user.photoUrl, fit: BoxFit.fill,)),
                                  Visibility(
                                    visible: accountPicHovered,
                                    child: Icon(Icons.camera_alt),
                                  )
                                ],
                              )),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(user.email ?? "No email"),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10)),
                        height: 1,
                        width: MediaQuery.of(context).size.width * .9,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * .5,
                      child: !editMode
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Align(
                                        alignment: Alignment.center,
                                        child: Text(user.name ?? "No name")),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FlatButton.icon(
                                        label: Text("Edit"),
                                        icon: Icon(MdiIcons.pencil),
                                        onPressed: () => setState(
                                            () => editMode = !editMode),
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.jobTitle ?? "Such empty"),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user.bio ?? "Such empty"),
                                ),
                              ],
                            )
                          : Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        FlatButton.icon(
                                          label: Text("Edit"),
                                          icon: Icon(MdiIcons.pencil),
                                          onPressed: () => setState(
                                              () => editMode = !editMode),
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      initialValue: user.name,
                                      decoration:
                                          InputDecoration(hintText: "Name"),
                                      onSaved: (value) =>
                                          setState(() => user.name = value),
                                    ),
                                    TextFormField(
                                      initialValue: user.bio,
                                      decoration:
                                          InputDecoration(hintText: "About me"),
                                      onSaved: (value) =>
                                          setState(() => user.bio = value),
                                    ),
                                    TextFormField(
                                      initialValue: user.jobTitle,
                                      decoration: InputDecoration(
                                          hintText: "Position Title"),
                                      onSaved: (value) =>
                                          setState(() => user.jobTitle = value),
                                    ),
                                    TextFormField(
                                      initialValue: user.photoUrl,
                                      decoration:
                                          InputDecoration(hintText: "Photo"),
                                      onSaved: (value) =>
                                          setState(() => user.photoUrl = value),
                                    ),
                                    RaisedButton(
                                      child: Text("Submit changes"),
                                      onPressed: () async =>
                                          await submitForm(user),
                                    )
                                  ],
                                ),
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
    formKey.currentState.save();
    await UserFirestore.updateUser(user);
    editMode = false;
    setState(() {});
  }
}
