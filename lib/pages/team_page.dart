import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/firestore/org_firestore.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {

  GlobalKey<FormState> formKey = GlobalKey();

  Organization org = Organization("", "", "", List());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Your organization", style: Theme.of(context).textTheme.headline1,),
            ),
            Consumer<Authentication>(
              builder: (context, auth, child) {
                org.ownerId = auth.firebaseUser.uid;
                return FutureBuilder<Organization>(
                  future: OrgFireStore.getOrganizationFromUser(auth.firebaseUser),
                  builder: (context, snapshot){
                    if(snapshot.hasData){
                      if(snapshot.data.ownerId != null){
                        return Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                children: [
                                  Material(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data.photoUrl,
                                      progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress,),
                                      errorWidget: (context, url, error) => Icon(Icons.error),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(snapshot.data.name),
                                  ),
                                ],
                              ),
                              Consumer<User>(
                                builder: (context, user, child) {
                                  return FlatButton.icon(
                                    icon: Icon(Icons.remove_circle),
                                    label: Text("Leave organization"),
                                    onPressed: () async {
                                      user.orgId = null;
                                      await UserFirestore.updateUser(user);
                                    }
                                  );
                               }
                              )
                            ],
                          ),
                        );
                      } else {
                        return Text("You don't belong to an organization");
                      }
                    } else if(snapshot.hasError){
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
              onPressed: () => createOrg(Provider.of<User>(context, listen: false)),
            )
          ],
        ),
      ),
    );
  }

  void createOrg(User user){
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("New organization"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onSaved: (value) => org.name = value,
                  decoration: InputDecoration(labelText: "Organization Name"),
                ),
                TextFormField(
                  onSaved: (value) => org.photoUrl = value,
                  decoration: InputDecoration(labelText: "Org pic"),
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
                  formKey.currentState.save();
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
      }
    );
  }
}

