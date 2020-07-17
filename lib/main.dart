import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:techpointchallenge/pages/account_page.dart';
import 'package:techpointchallenge/pages/auth_page.dart';
import 'package:techpointchallenge/pages/calendar_page.dart';
import 'package:techpointchallenge/pages/team_page.dart';
import 'package:techpointchallenge/services/authentication.dart';
import 'package:techpointchallenge/services/firestore/user_firestore.dart';
import 'package:techpointchallenge/widgets/logo.dart';
import 'services/globals.dart' as globals;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
          ChangeNotifierProvider(create: (context) => Authentication(),),
      ],
      child: MyApp(),
    )
  );

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Scheduling App',
      theme: ThemeData(
        textTheme: GoogleFonts.notoSerifTextTheme().copyWith(
          headline1: GoogleFonts.abrilFatface(fontSize: 38, color: Colors.white), //PAGE HEADER
          headline2: GoogleFonts.ebGaramond(fontSize: 34, color: Colors.white, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic), // MONTH
          bodyText1: GoogleFonts.lora(fontSize: 22, color: Colors.black), //CALENDAR DAYS
          bodyText2: GoogleFonts.lora(fontSize: 22, color: Colors.white), //DEFAULT
          button: GoogleFonts.lora(fontSize: 22, color: Colors.white), //BUTTON TEXT COLOR
        ),
        canvasColor: Color(0xff596e79),
        dialogBackgroundColor: Colors.white,
        accentColor: Color(0xffdfd3c3),
        backgroundColor: Colors.grey[300],
        hoverColor: Colors.grey[400],
        splashColor: Colors.lightBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<Authentication>(
        builder: (context, auth, child){
          if(auth.firebaseUser == null){
            return AuthPage();
          } else {
            return MultiProvider(
              providers: [
                StreamProvider(create: (context) => UserFirestore.getUserAsStream(auth.firebaseUser.uid),)
              ],
              child: MyHomePage()
            );
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int navIndex = 0;

  @override
  Widget build(BuildContext context) {
    double shortestSide = MediaQuery.of(context).size.shortestSide;
    globals.useMobileLayout = shortestSide < 600;

    List<Widget> pages = [
      CalendarPage(),
      TeamsPage(),
      AccountPage(),
    ];

    if (globals.useMobileLayout) {
      return Row(
        children: [
          Expanded(
            child: Scaffold(
              body: pages[navIndex],
              bottomNavigationBar: BottomNavigationBar(
                showSelectedLabels: false,
                showUnselectedLabels: false,
                selectedIconTheme: IconThemeData(color: Colors.white),
                selectedLabelStyle: TextStyle(color: Colors.white),
                backgroundColor: Theme.of(context).accentColor,
                onTap: (index) => setNavIndex(index),
                currentIndex: navIndex,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(MdiIcons.calendar),
                    title: Text("Calendar")
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(MdiIcons.accountGroup),
                    title: Text("Team")
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(MdiIcons.account),
                    title: Text("Account")
                  ),
                ],
              ),
            ),
          )
        ],
      );
    } else {
      return Row(
        children: [
          NavigationRail(
            leading: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Logo(),
            ),
            backgroundColor: Theme.of(context).accentColor,
            selectedIndex: navIndex,
            selectedLabelTextStyle: TextStyle(color: Colors.white),
            selectedIconTheme: IconThemeData(color: Colors.white),
            labelType: NavigationRailLabelType.all,
            onDestinationSelected: (index) => setNavIndex(index),
            destinations: [
              NavigationRailDestination(
                icon: Icon(MdiIcons.calendar),
                label: Text("Calendar")
              ),
              NavigationRailDestination(
                icon: Icon(MdiIcons.accountGroup),
                label: Text("Team")
              ),
              NavigationRailDestination(
                icon: Icon(MdiIcons.account),
                label: Text("Account")
              )
            ],
          ),
          Expanded(
            child: Scaffold(
              floatingActionButton: navIndex == 0 ? FloatingActionButton(child: Icon(Icons.add, color: Colors.lightBlue,),onPressed: (){}, backgroundColor: Colors.white,) : Container(),
              body: pages[navIndex],
            ),
          )
        ],
      );
    }
  }

  void setNavIndex(int index) {
    setState(() {
      navIndex = index;
    });
  }

}
