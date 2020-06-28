import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/pages/auth_page.dart';
import 'package:techpointchallenge/services/authentication.dart';
import '../services/globals.dart' as globals;

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Center(
        child: Consumer<Authentication>(
          builder: (context, auth, child){
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(auth.firebaseUser.photoUrl),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(auth.firebaseUser.email),
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
        ),
      ),
    );
  }
}
