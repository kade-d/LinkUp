import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/organization.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/firestore/org_firestore.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import 'package:techpointchallenge/services/image_uploader.dart';
import 'package:techpointchallenge/services/storage/firebase_storage.dart';
import 'package:techpointchallenge/services/validator.dart';
import 'package:techpointchallenge/widgets/profile_view.dart';
import 'package:techpointchallenge/widgets/recognition_widget.dart';
import 'package:techpointchallenge/widgets/upload_picture_widget.dart';
import 'package:techpointchallenge/services/globals.dart' as globals;
import 'dart:html';


class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> orgFormKey = GlobalKey();
  GlobalKey<FormState> coworkerFormKey = GlobalKey();

  Organization org = Organization.fromNothing();

  TabController tabController;

  @override
  Widget build(BuildContext context) {

    final List<Widget> tabs = [
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
        child: Text("Members", style: Theme.of(context).textTheme.bodyText2,)),
      Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(border: Border.all(color: Colors.black38)),
        child: Text("Recognitions", style: Theme.of(context).textTheme.bodyText2,))
    ];

    User user = Provider.of<User>(context);
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: DefaultTabController(
        length: tabs.length,
        initialIndex: 0,
        child: Center(
          child: Column(
            children: [
              Text("Your Organization", style: Theme.of(context).textTheme.headline1,),
              Consumer<User>(
                builder: (context, user, child) {
                  if (user.orgId != null) {
                    return StreamBuilder<Organization>(
                      stream: OrgFireStore.getOrganization(user.email, user.orgId),
                      builder: (context, orgSnapshot) {
                        if (orgSnapshot.hasData) {
                          return Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  RectangularUploadPic(
                                    owner: user.firebaseId == orgSnapshot.data.ownerId,
                                    photoUrl: orgSnapshot.data.bannerPhotoUrl,
                                    onNewImageSelected: (file) async {
                                      orgSnapshot.data.bannerPhotoUrl = await FirebaseStorage.uploadImage(file, "organizations/" + orgSnapshot.data.ownerId);
                                      OrgFireStore.updateOrg(orgSnapshot.data);
                                    }
                                  ),
                                  CircularUploadPic(
                                    owner: user.firebaseId == orgSnapshot.data.ownerId,
                                    radius: 45,
                                    onNewImageSelected: (file) async {
                                      orgSnapshot.data.photoUrl = await FirebaseStorage.uploadImage(file, "organizations/" + orgSnapshot.data.ownerId);
                                      OrgFireStore.updateOrg(orgSnapshot.data);
                                    },
                                    photoUrl: orgSnapshot.data.photoUrl,
                                  ),
                                ],
                              ),
                              Text(orgSnapshot.data.name, style: Theme.of(context).textTheme.headline2,),
                              Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        TabBar(
                                          indicatorPadding: EdgeInsets.all(0),
                                          labelPadding: EdgeInsets.all(0),
                                          isScrollable: true,
                                          unselectedLabelColor: Colors.grey[700],
                                          labelColor: Colors.white,
                                          indicatorSize: TabBarIndicatorSize.tab,
                                          tabs: tabs,
                                          controller: tabController,
                                        ),
                                      ],
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.black38)),
                                      height: size.height * .4,
                                      child: TabBarView(
                                          controller: tabController,
                                          children: [
                                            FutureBuilder<List<User>>(
                                                future: UserFirestore.getUsersForOrg(orgSnapshot.data.ownerId, orgSnapshot.data.invitedUserEmails),
                                                builder: (context, membersSnapshot) {
                                                  if (membersSnapshot.hasData) {
                                                    return OrgMemberList(membersSnapshot.data, user);
                                                  }
                                                  return Center(child: Container(width: MediaQuery.of(context).size.width * .5,child: LinearProgressIndicator()));
                                                }),
                                            Center(
                                              child: OrgRecognitionsWidget(orgId: orgSnapshot.data.ownerId),
                                            )
                                          ]),
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                alignment: WrapAlignment.center,
                                children: [
                                  orgSnapshot.data.ownerId == user.firebaseId
                                    ? FlatButton.icon(
                                    textColor: Theme.of(context).textTheme.button.color,
                                    icon: Icon(Icons.add),
                                    label: Text("Add coworkers"),
                                    onPressed: () async {
                                      addCoworkerToOrg(orgSnapshot.data);
                                      setState(() {});
                                    })
                                    : Container(),
                                  FlatButton.icon(
                                    textColor: Theme.of(context).textTheme.button.color,
                                    icon: Icon(Icons.remove_circle),
                                    label: Text("Leave organization"),
                                    onPressed: () async {
                                      user.orgId = null;
                                      await UserFirestore.updateUser(user);
                                    })
                                ],
                              ),
                            ],
                          );
                        } else if (orgSnapshot.hasError) {
                          return Text(orgSnapshot.error.toString());
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("You don't belong to an organization", textAlign: TextAlign.center,),
                        ),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            StreamBuilder<List<Organization>>(
                                stream: OrgFireStore.getInvitedOrganizations(user),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return FlatButton(
                                      textColor: Theme.of(context).textTheme.button.color,
                                      child: Text("Invitations (" + snapshot.data.length.toString() + ")"),
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              var size = MediaQuery.of(context).size;
                                              return AlertDialog(
                                                  title: Text("Invitations"),
                                                  content: Container(
                                                    constraints: BoxConstraints.tight(globals.useMobileLayout ? Size(size.width * .9, size.height * .5) : Size(size.width * .25, size.height * .3)),
                                                    child: ListView.separated(
                                                      separatorBuilder: (context, index){
                                                        return Divider();
                                                      },
                                                      primary: false,
                                                      shrinkWrap: true,
                                                      itemCount: snapshot.data.length,
                                                      itemBuilder: (context, index) {
                                                        Organization invitedOrg = snapshot.data[index];
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                CircleAvatar(backgroundImage: NetworkImage(invitedOrg.photoUrl ?? "No photo")),
                                                                Padding(
                                                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                                                  child: Text(invitedOrg.name),
                                                                ),
                                                              ],
                                                            ),
                                                            Container(
                                                              constraints: BoxConstraints(minWidth: size.width * .1,),
                                                              child: Material(
                                                                color: Colors.green,
                                                                child: InkWell(
                                                                  onTap: () async {
                                                                    user.orgId = invitedOrg.ownerId;
                                                                    await UserFirestore.updateUser(user);
                                                                    Navigator.of(context).pop();
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: Icon(Icons.check),
                                                                  ),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    ),
                                                  ));
                                            });
                                      },
                                    );
                                  } else {
                                    return FlatButton(child: Text("Invitations (0)"), onPressed: (){},);
                                  }
                                }),
                            FlatButton(
                              textColor: Theme.of(context).textTheme.button.color,
                              child: Text("Create organization"),
                              onPressed: () => createOrg(Provider.of<User>(context, listen: false)),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
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
              MaterialButton(
                shape: StadiumBorder(),
                onPressed: () async {
                  orgFormKey.currentState.save();
                  org.invitedUserEmails = [user.email];
                  org.ownerId = user.firebaseId;
                  await OrgFireStore.createOrganization(org, user);
                  setState(() {});
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Create Team"),
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
                  Text("Invited"),
                  Container(
                    constraints: BoxConstraints.tight(Size(MediaQuery.of(context).size.width * .25, 160)),
                    child: ListView.builder(
                      primary: false,
                      shrinkWrap: true,
                      itemCount: organization.invitedUserEmails.length,
                      itemBuilder: (context, index){
                        return ListTile(
                          title: Text(organization.invitedUserEmails[organization.invitedUserEmails.length - index - 1]),
                        );
                      },
                    ),
                  ),
                  TextFormField(
                    validator: (value) => Validator.validateEmail(value),
                    onSaved: (value) => organization.invitedUserEmails.add(value),
                    decoration: InputDecoration(labelText: "Coworker email"),
                  ),
                ],
              ),
            ),
            actions: [
              MaterialButton(
                shape: StadiumBorder(),
                onPressed: () async {
                  if(coworkerFormKey.currentState.validate()){
                    coworkerFormKey.currentState.save();
                    await OrgFireStore.updateOrg(organization);
                    Navigator.of(context).pop();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_forward),
                ),
              )
            ],
          );
        });
  }
}

class OrgMemberList extends StatefulWidget {
  final List<User> orgMembers;
  final User signedInUser;

  OrgMemberList(this.orgMembers, this.signedInUser);

  @override
  _OrgMemberListState createState() => _OrgMemberListState();
}

class _OrgMemberListState extends State<OrgMemberList> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return ListView.separated(
      itemCount: widget.orgMembers.length,
      separatorBuilder: (context, index) {
        return Divider(
          color: Colors.black38,
        );
      },
      itemBuilder: (context, index) {
        User member = widget.orgMembers[index];
        return InkWell(
          onTap: () => showDialog(
              context: context,
              builder: (context) {
                return UserProfile(
                  signedInUser: widget.signedInUser,
                  viewingUser: widget.orgMembers[index],
                );
              }),
          child: ListTile(
            title: Row(
              children: [
                Text(member.name, style: Theme.of(context).textTheme.bodyText2,),
              ],
            ),
            leading: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(member.photoUrl ?? "No url"),
                  ),
                ),
                Positioned(
                  top: 30,
                  child: CircleAvatar(
                    maxRadius: 8,
                    backgroundColor: member.status.toColor(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
