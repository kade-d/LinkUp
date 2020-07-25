import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_web_view/easy_web_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/widgets/logo.dart';
import '../services/globals.dart' as globals;

class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<Authentication>(
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Logo(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: AutoSizeText(
                                "Breaking down barriers from home.",
                                maxLines: 1,
                                style: GoogleFonts.ptSerif(
                                    fontSize: 26, color: Colors.grey[700]),
                              ),
                            ),
                            SizedBox(
                              height: 100,
                            ),
                            SignInButton(
                              Buttons.GoogleDark,
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          title: Text("Privacy Policy"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                            EasyWebView(
                                              src: "https://firebasestorage.googleapis.com/v0/b/techpoint-sos-challenge.appspot.com/o/hosting%2Fprivacy_policy.html?alt=media&token=b431a377-8412-4363-9188-86d2d4fc90cf",
                                              width: 640,
                                              webAllowFullScreen: false,
                                              height: 320,
                                              onLoaded: () {},
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: RaisedButton(
                                                child: Text("Accept"),
                                                onPressed: () async {
                                                  await auth.signInWithGoogle();
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            )
                                          ]));
                                    });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              });
        },
      ),
    );
  }
}
