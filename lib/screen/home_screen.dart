import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playtoday/components/navigation_drawer.dart';
import 'package:playtoday/services/popup_dialog.dart';

import 'details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser!;
  Stream<QuerySnapshot>? _documentsStream;
  late String username = '';

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
          });
        }
      }
    }).then((_) {
      if (username != '') {
        DateTime today = DateTime.now();
        DateFormat formatter = DateFormat('dd/MM/yyyy');
        String todayFormatted = formatter.format(today);

        _documentsStream = FirebaseFirestore.instance
            .collection('matches')
            .where('Players', arrayContains: username)
            .where('ReservDate', isLessThan: todayFormatted)
            .snapshots();
      }
    });
  }

  void _openDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyPopup();
      },
    );
  }

  void handlePress(bool isAdmin, fieldValue, id) {
    if (isAdmin) {
      FirebaseFirestore.instance.collection('matches').doc(id).delete();
    } else {
      List<dynamic>? list = [];
      FirebaseFirestore.instance
          .collection('matches')
          .doc(id)
          .get()
          .then((DocumentSnapshot snapshot) {
        list = fieldValue['Players'];
        list?.remove(username);
        FirebaseFirestore.instance
            .collection('matches')
            .doc(id)
            .update({'Players': list});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _documentsStream != null
        ? StreamBuilder<QuerySnapshot>(
            stream: _documentsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return Scaffold(
                appBar: AppBar(
                  title: const Text("Home Page"),
                  titleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                drawer: MyNavigationDrawer(),
                body: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(children: [
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            child: const Text(
                              'Your scheduled matches :',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child:
                                snapshot.hasData && snapshot.data!.docs.isEmpty
                                    ? Center(
                                        child: Column(
                                          children: const [
                                            Image(
                                                image: AssetImage(
                                                    'assets/noMatch.png')),
                                            Text(
                                              'You dont have matches, lets create one !',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: snapshot.data!.docs.length,
                                        itemBuilder: (context, index) {
                                          final document =
                                              snapshot.data!.docs[index];

                                          // Access the document fields using document.data() map
                                          final fieldValue = (document.data()
                                              as Map<String, dynamic>);

                                          return Card(
                                              key: fieldValue[document.id],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailsScreen(
                                                                parameter:
                                                                    fieldValue,
                                                                docId: document
                                                                    .id)),
                                                  );
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Row(
                                                    children: [
                                                      const Expanded(
                                                          flex: 1,
                                                          child: CircleAvatar(
                                                              radius: 40.00,
                                                              backgroundImage:
                                                                  NetworkImage(
                                                                      'https://e7.pngegg.com/pngimages/799/987/png-clipart-computer-icons-avatar-icon-design-avatar-heroes-computer-wallpaper.png'))),
                                                      Expanded(
                                                        flex: 2,
                                                        child: ListTile(
                                                          title: Text(
                                                            fieldValue['Admin'],
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          subtitle: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .symmetric(
                                                                      vertical:
                                                                          5),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    fieldValue[
                                                                        'ReservDate'],
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  Text(
                                                                    fieldValue[
                                                                        'ReservHour'],
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  Text(
                                                                    fieldValue[
                                                                        'StadeName'],
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                  Container(
                                                                    margin: const EdgeInsets
                                                                            .only(
                                                                        top: 5),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(8),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      color: fieldValue[
                                                                              'Public']
                                                                          ? const Color.fromARGB(
                                                                              255,
                                                                              35,
                                                                              177,
                                                                              40)
                                                                          : const Color.fromARGB(
                                                                              255,
                                                                              181,
                                                                              22,
                                                                              22),
                                                                    ),
                                                                    child: Text(
                                                                      fieldValue[
                                                                              'Public']
                                                                          ? 'Public'
                                                                          : 'Private',
                                                                      style: const TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              15),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateColor
                                                                  .resolveWith(
                                                                      (states) {
                                                            if (fieldValue[
                                                                    'Admin'] ==
                                                                username) {
                                                              return Colors.red;
                                                            } else {
                                                              return Colors
                                                                  .orange;
                                                            }
                                                          }),
                                                        ),
                                                        child: Text(
                                                          fieldValue['Admin'] ==
                                                                  username
                                                              ? 'Cancel'
                                                              : 'Leave',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 18),
                                                        ),
                                                        onPressed: () => {
                                                          handlePress(
                                                              fieldValue[
                                                                      'Admin'] ==
                                                                  username,
                                                              fieldValue,
                                                              document.id)
                                                        },
                                                      ))
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        }),
                          )
                        ])),
                  ]),
                ),
                floatingActionButton: FloatingActionButton(
                  backgroundColor: const Color.fromARGB(255, 5, 65, 168),
                  onPressed: () {
                    // Handle button press
                    _openDialog(context);
                  },
                  child: const Icon(Icons.add),
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat,
              );
            })
        : const Center(child: CircularProgressIndicator());
    ;
  }
}
