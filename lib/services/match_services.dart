import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

bool checkReserved(list, username, admin) {
  bool isReserved = false;
  isReserved = list!.contains(username);
  return isReserved;
}

void confirmPlace(list, username, docId) {
  list?.add(username);
  FirebaseFirestore.instance
      .collection('matches')
      .doc(docId)
      .update({'Players': list});
}

void quitMatch(list, username, docId) {
  list?.remove(username);
  FirebaseFirestore.instance
      .collection('matches')
      .doc(docId)
      .update({'Players': list});
}

void deleteMatch(list, docId) {
  FirebaseFirestore.instance.collection('matches').doc(docId).delete();
}

void createMatch(context, username, selectedDateFormatted, formattedTime,
    selectedOption, stade) async {
  try {
    await FirebaseFirestore.instance.collection('matches').add({
      'Admin': username,
      'ReservDate': selectedDateFormatted,
      'ReservHour': formattedTime,
      'Public': selectedOption == 'Public',
      'Players': [username],
      'StadeName': stade
    });

    // Show a success message or perform any other desired actions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Match created successfully!'),
      ),
    );

    Navigator.of(context).pop(); // Close the dialog
  } catch (e) {
    // Show an error message or perform any other desired error handling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Failed to create match. Please try again.'),
      ),
    );
  }
}

void removePlayer(list, playername, docId) {
  list?.remove(playername);
  FirebaseFirestore.instance
      .collection('matches')
      .doc(docId)
      .update({'Players': list});
}
