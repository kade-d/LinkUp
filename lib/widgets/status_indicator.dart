import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:techpointchallenge/model/user.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';

class StatusIndicatorOwner extends StatefulWidget {

  final User user;

  const StatusIndicatorOwner({Key key, @required this.user}) : super(key: key);

  @override
  _StatusIndicatorOwnerState createState() => _StatusIndicatorOwnerState();
}

class _StatusIndicatorOwnerState extends State<StatusIndicatorOwner> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: "Change Status",
      icon: CircleAvatar(backgroundColor: widget.user.status.toColor(),),
      itemBuilder: (context){
        return [
          PopupMenuItem(
            value: "Away",
            child: Text("Away"),
          ),
          PopupMenuItem(
            value: "Available",
            child: Text("Available"),
          )
        ];
      },
      onSelected: (value) async {
        widget.user.status = Status.fromString(value);
        await UserFirestore.updateUser(widget.user);
        setState(() {});
      },
    );
  }
}