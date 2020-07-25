import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/pages/calendar_page.dart';
import 'package:techpointchallenge/widgets/recognition_widget.dart';
import 'package:techpointchallenge/services/globals.dart' as globals;

import 'about_user.dart';

class UserProfile extends StatefulWidget {

  final User viewingUser;
  final User signedInUser;

  const UserProfile({Key key, @required this.viewingUser, @required this.signedInUser}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    List<Widget> tabs = [
      Tab(text: "Schedule",),
      Tab(text: "Profile",),
      Tab(text: "Recognitions",),
    ];

    List<Widget> pages = [
      CalendarPage(aliasMode: true,),
      AboutUserWidget(viewingUser: widget.viewingUser, signedInUser: widget.signedInUser,),
      UserRecognitionsWidget(signedInUser: widget.signedInUser, viewingUser: widget.viewingUser,)
    ];

    return Dialog(
      backgroundColor: Theme.of(context).canvasColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(backgroundImage: NetworkImage(widget.viewingUser.photoUrl),),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.viewingUser.name),
                )
              ],
            ),
          ),
          DefaultTabController(
            initialIndex: 1,
            length: tabs.length,
            child: Container(
              width: globals.useMobileLayout ? null : size.width * .5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    unselectedLabelColor: Colors.black38,
                    indicatorColor: Colors.lightBlue,
                    labelColor: Theme.of(context).accentColor,
                    tabs: tabs,
                  ),
                  Provider(
                    create: (context){
                      return widget.viewingUser;
                    },
                    child: Container(
                      height: size.height * .5,
                      child: TabBarView(
                        children: pages,
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}



