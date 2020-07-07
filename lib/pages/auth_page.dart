import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/main.dart';
import 'package:techpointchallenge/pages/calendar_page.dart';
import 'package:techpointchallenge/services/authentication.dart';
import '../services/globals.dart' as globals;

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: Consumer<Authentication>(
          builder: (context, auth, child) {
            return FutureBuilder<bool>(
              future: auth.initializeCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data) {
                  return Center(
                    child: Text("Signing you in"),
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: SignInButton(
                          Buttons.GoogleDark,
                          onPressed: () async => await auth.signInWithGoogle(),
                        ),
                      ),
                    ],
                  );
                }
              });
          },
        ),
      ),
    );
  }
}
