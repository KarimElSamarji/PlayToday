import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:playtoday/services/match_services.dart';

class DetailsScreen extends StatefulWidget {
  final Map<String, dynamic> parameter;
  final String docId;

  const DetailsScreen(
      {super.key, required this.parameter, required this.docId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late Map<String, dynamic> parameter;
  late String docId;
  late Stream<QuerySnapshot> _documentsStream;
  late String username = '';
  List<dynamic>? list = [];

  @override
  void initState() {
    parameter = widget.parameter;
    docId = widget.docId;
    list = parameter['Players'] as List<dynamic>?;
    super.initState();

    FirebaseFirestore.instance
        .collection('matches')
        .doc(docId)
        .get()
        .then((DocumentSnapshot snapshot) {
      setState(() {
        list = parameter['Players'];
      });
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
              checkReserved(list!, username, parameter['Admin']);
            });
          }
        }
      });
    });

    // Replace 'collectionPath' with the actual path to your Firestore collection
    _documentsStream = FirebaseFirestore.instance
        .collection('matches')
        .where('StadeName', isEqualTo: parameter)
        .snapshots();
  }

  void reservePlace() {
    setState(() {
      confirmPlace(list!, username, docId);
    });
  }

  void leavePlace(username, admin) {
    if (username != admin) {
      setState(() {
        quitMatch(list, username, docId);
      });
    } else {
      setState(() {
        Navigator.pop(context);
        deleteMatch(list!, docId);
      });
    }
    checkReserved(list!, username, admin);
  }

  void deletePlayer(playerName) {
    setState(() {
      removePlayer(list!, playerName, docId);
    });
  }

  bool checkFollowers(String name) {
    return name != username && username == parameter['Admin'];
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _documentsStream,
        builder: (context, snapshot) {
          // Render the documents
          return Scaffold(
              appBar: AppBar(
                title: const Text('Match Detail'),
                titleTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              body: Column(children: [
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Owner:  ${parameter['Admin']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                'Date:     ${parameter['ReservDate']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                'Time:    ${parameter['ReservHour']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                'Stade:   ${parameter['StadeName']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Row(
                                children: [
                                  Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: parameter['Public']
                                            ? const Color.fromARGB(
                                                255, 35, 177, 40)
                                            : const Color.fromARGB(
                                                255, 181, 22, 22),
                                      ),
                                      child: Text(
                                        parameter['Public']
                                            ? 'Public'
                                            : 'Private',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                  Container(
                                      margin: const EdgeInsets.all(5),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: parameter['Players'].length < 10
                                            ? const Color.fromARGB(
                                                255, 35, 177, 40)
                                            : const Color.fromARGB(
                                                255, 181, 22, 22),
                                      ),
                                      child: Text(
                                        parameter['Players'].length < 10
                                            ? '${list!.length} / 10'
                                            : 'Full',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      )),
                                  Expanded(
                                    child: Visibility(
                                      visible: parameter['Players'].length < 10,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: checkReserved(list,
                                                  username, parameter['Admin'])
                                              ? const Color.fromARGB(
                                                  255, 181, 22, 22)
                                              : const Color.fromARGB(
                                                  255, 35, 177, 40),
                                        ),
                                        onPressed: () {
                                          //handle press
                                          checkReserved(list, username,
                                                  parameter['Admin'])
                                              ? leavePlace(
                                                  username, parameter['Admin'])
                                              : reservePlace();
                                        },
                                        child: Text(
                                            checkReserved(list, username,
                                                    parameter['Admin'])
                                                ? (parameter['Admin'] ==
                                                        username
                                                    ? 'Cancel Match'
                                                    : 'Leave my place')
                                                : 'Reserve my place',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  )
                                ],
                              )
                            ],
                          ),
                        ))
                  ],
                )),
                Expanded(
                    flex: 3,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: const Text('Players',
                                style: TextStyle(
                                    color: Color.fromARGB(255, 5, 65, 168),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25)),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: parameter['Players'].length,
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                            flex: 1,
                                            child: CircleAvatar(
                                                radius: 30.00,
                                                backgroundImage: NetworkImage(
                                                    'https://images.lecho.be/view?iid=Elvis:2JO2Ny7-4zXBfiJNIvZbqQ&context=ONLINE&ratio=16/9&width=815'))),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            parameter['Players'][index],
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                            child: Visibility(
                                          visible: checkFollowers(
                                              parameter['Players'][index]),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              deletePlayer(
                                                  parameter['Players'][index]);
                                            },
                                            child: const Text('Remove',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15)),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ]))
              ]));
        });
  }
}
