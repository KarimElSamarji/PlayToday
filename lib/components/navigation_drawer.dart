import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:playtoday/screen/home_screen.dart';
import 'package:playtoday/screen/search_screen.dart';
import 'package:playtoday/screen/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:playtoday/screen/home_screen.dart';

import '../provider/dark_theme_provider.dart';

class MyNavigationDrawer extends StatefulWidget {
  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  IconData darkIcon = Icons.dark_mode_outlined;
  late String username = '';
  late String email = '';
  IconData lightIcon = Icons.light_mode_outlined;

  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Document exists, you can access its data
        var data = snapshot.data();
        if (data is Map<String, dynamic>) {
          setState(() {
            username = data['username'];
            email = data['email'];
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          buildHeader(context),
          buildMenuItems(context),
          buildFooter(context),
        ],
      )),
    );
  }

  Widget buildHeader(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);

    final user = FirebaseAuth.instance.currentUser!;

    return (Container(
      color: themeState.getDarkTheme
          ? Color.fromARGB(255, 5, 65, 168)
          : Colors.black,
      padding: EdgeInsets.only(
        top: 24 + MediaQuery.of(context).padding.top,
        bottom: 24,
      ),
      child: Column(children: [
        const CircleAvatar(
          radius: 52,
          backgroundImage: AssetImage('assets/karimRounded.png'),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(username,
            style: const TextStyle(fontSize: 28, color: Colors.white)),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        )
      ]),
    ));
  }

  Widget buildMenuItems(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);

    return Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.home_outlined,
            color: Color.fromARGB(255, 5, 65, 168),
          ),
          title: const Text('Home'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.search_outlined,
            color: Color.fromARGB(255, 5, 65, 168),
          ),
          title: const Text('Search'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchSreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.settings_outlined,
            color: Color.fromARGB(255, 5, 65, 168),
          ),
          title: const Text('Settings'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        SwitchListTile(
          secondary: Icon(
            themeState.getDarkTheme ? darkIcon : lightIcon,
            color: const Color.fromARGB(255, 5, 65, 168),
          ),
          title: const Text('Dark Mode'),
          onChanged: (bool value) {
            themeState.setDarkTheme = value;
          },
          value: themeState.getDarkTheme,
        ),
      ],
    );
  }
}

Widget buildFooter(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 250,
    ),
    child: Column(
      children: [
        ListTile(
          leading: const Icon(
            Icons.logout,
            color: Colors.red,
          ),
          title: const Text(
            'Logout',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
        ),
      ],
    ),
  );
}
