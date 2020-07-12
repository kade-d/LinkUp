import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/firestore/org_firestore.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import 'dart:html';

import 'package:techpointchallenge/services/image_uploader.dart';
import 'package:techpointchallenge/services/storage/firebase_storage.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  GlobalKey<FormState> orgFormKey = GlobalKey();
  GlobalKey<FormState> coworkerFormKey = GlobalKey();

  Organization org = Organization.fromNothing();

  @override
  Widget build(BuildContext context) {
    bool orgPicHovered = false;

    User user = Provider.of<User>(context);
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Your organization",
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Consumer<Authentication>(
              builder: (context, auth, child) {
                return FutureBuilder<Organization>(
                  future:
                      OrgFireStore.getOrganizationFromUser(auth.firebaseUser),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.ownerId != null) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Material(
                                      shape: CircleBorder(),
                                      child: InkWell(
                                        onTap: () async {
                                          File file = await ImageUploader
                                              .startFilePicker();
                                          snapshot.data.photoUrl = await FirebaseStorage.uploadImage(file, "organizations/" + user.firebaseId);
                                          OrgFireStore.updateOrg(snapshot.data);
                                        },
                                        onHover: (value) {
                                          setState(() => orgPicHovered = value);
                                        },
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: <Widget>[
                                                Material(
                                                    shape: CircleBorder(),
                                                    child: Image.network(
                                                      snapshot.data.photoUrl ?? "No url",
                                                      fit: BoxFit.fill,
                                                      width: size.width * .1,
                                                      height: size.height * .1,
                                                    )),
                                                Visibility(
                                                  visible: orgPicHovered,
                                                  child: Icon(Icons.camera_alt),
                                                )
                                              ],
                                            )),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(snapshot.data.name),
                                  ),
                                ],
                              ),
                              snapshot.data.ownerId == user.firebaseId
                                  ? FlatButton.icon(
                                      icon: Icon(Icons.add),
                                      label: Text("Add coworkers"),
                                      onPressed: () async {
                                        addCoworkerToOrg(snapshot.data);
                                      })
                                  : Container(),
                              FlatButton.icon(
                                  icon: Icon(Icons.remove_circle),
                                  label: Text("Leave organization"),
                                  onPressed: () async {
                                    user.orgId = null;
                                    await UserFirestore.updateUser(user);
                                  })
                            ],
                          ),
                        );
                      } else {
                        return Text("You don't belong to an organization");
                      }
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                );
              },
            ),
            RaisedButton(
              child: Text("Create organization"),
              onPressed: () =>
                  createOrg(Provider.of<User>(context, listen: false)),
            )
          ],
        ),
      ),
    );
  }

  void createOrg(User user) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("New organization"),
            content: Form(
              key: orgFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onSaved: (value) => org.name = value,
                    decoration: InputDecoration(labelText: "Organization Name"),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text("Upload image"),
                    onPressed: () async {
                      File file = await ImageUploader.startFilePicker();
                      String url = await FirebaseStorage.uploadImage(
                          file, "organizations/" + user.firebaseId);
                      org.photoUrl = url;
                      await OrgFireStore.updateOrg(org);
                    },
                  )
                ],
              ),
            ),
            actions: [
              Material(
                color: Theme.of(context).buttonColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    orgFormKey.currentState.save();
                    org.userEmails = List<String>();
                    org.ownerId = user.firebaseId;
                    await OrgFireStore.createOrganization(org, user);
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Create Team"),
                  ),
                ),
              )
            ],
          );
        });
  }

  void addCoworkerToOrg(Organization organization) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add coworker"),
            content: Form(
              key: coworkerFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    onSaved: (value) => organization.userEmails.add(value),
                    decoration: InputDecoration(labelText: "Coworker email"),
                  ),
                ],
              ),
            ),
            actions: [
              Material(
                color: Theme.of(context).buttonColor,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    coworkerFormKey.currentState.save();
                    await OrgFireStore.updateOrg(organization);
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Add coworker"),
                  ),
                ),
              )
            ],
          );
        });
  }
}
